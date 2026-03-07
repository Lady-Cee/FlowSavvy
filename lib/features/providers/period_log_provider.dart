import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/period_log.dart';

class PeriodLogProvider with ChangeNotifier {
  final List<PeriodLog> _logs = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<PeriodLog> get logs => [..._logs];

  /// 🔑 Generate a user-specific SharedPreferences key
  String _getPrefsKey(String uid) => "${uid}_period_logs";

  /// 🔄 Sort logs and recalculate cycle lengths
  void _sortAndRecalculate() {
    _logs.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
    for (int i = 0; i < _logs.length; i++) {
      if (i == 0) {
        _logs[i].cycleLength = null;
      } else {
        _logs[i].cycleLength =
            _logs[i].startDate.difference(_logs[i - 1].startDate).inDays;
      }
    }
  }

  /// 🔄 Load logs from cache and Firestore
  Future<void> loadLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = _getPrefsKey(user.uid);

    // Load from offline cache first
    final cachedJson = prefs.getStringList(key) ?? [];
    _logs.clear();
    _logs.addAll(cachedJson.map((e) => PeriodLog.fromMap(jsonDecode(e))));
    _sortAndRecalculate();
    notifyListeners();

    // Load from Firestore
    try {
      final snapshot = await _firestore
          .collection('period_log')
          .where('uid', isEqualTo: user.uid)
          .get();

      final firestoreLogs =
      snapshot.docs.map((doc) => PeriodLog.fromMap(doc.data())).toList();

      if (firestoreLogs.isNotEmpty) {
        _logs.clear();
        _logs.addAll(firestoreLogs);
        _sortAndRecalculate();
        await _saveToLocal(user.uid);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print("Error loading Firestore logs: $e");
    }
  }

  /// ✅ Add new log (offline + Firestore)
  Future<void> addLog(PeriodLog log) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _logs.add(log);
    _sortAndRecalculate();
    notifyListeners();
    await _saveToLocal(user.uid);

    try {
      await _firestore.collection('period_log').add({
        'uid': user.uid,
        ...log.toMap(),
      });
    } catch (e) {
      if (kDebugMode) print("Error saving log to Firestore: $e");
    }
  }

  /// ✅ Remove log
  Future<void> removeLog(int index) async {
    if (index < 0 || index >= _logs.length) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final log = _logs.removeAt(index);
    _sortAndRecalculate();
    notifyListeners();
    await _saveToLocal(user.uid);

    try {
      final snapshot = await _firestore
          .collection('period_log')
          .where('uid', isEqualTo: user.uid)
          .where('startDate', isEqualTo: log.startDate.toIso8601String())
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) print("Error removing log from Firestore: $e");
    }
  }

  /// ✅ Offline caching
  Future<void> _saveToLocal(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPrefsKey(uid);
    final logsJson = _logs.map((log) => jsonEncode(log.toMapOffline())).toList();
    await prefs.setStringList(key, logsJson);
  }

  /// ✅ Reset logs (e.g., on logout)
  Future<void> resetLogs() async {
    _logs.clear();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getPrefsKey(user.uid));
    }
    notifyListeners();
  }

  /// 🔑 Computed: Latest log
  PeriodLog? get latestLog => _logs.isNotEmpty ? _logs.first : null;

  /// 🔑 Computed: Predicted next period
  DateTime? get predictedNextPeriod =>
      latestLog != null && latestLog!.startDate != null && latestLog!.cycleLength != null
          ? latestLog!.startDate.add(Duration(days: latestLog!.cycleLength!))
          : null;

  /// 🔑 Computed: Predicted ovulation (mid-cycle)
  DateTime? get predictedOvulation =>
      latestLog != null && latestLog!.startDate != null && latestLog!.cycleLength != null
          ? latestLog!.startDate.add(Duration(days: (latestLog!.cycleLength! ~/ 2)))
          : null;

  /// 🔑 Computed: Cycle phase based on last period
  String get cyclePhase {
    if (latestLog == null || latestLog!.startDate == null || latestLog!.cycleLength == null) {
      return 'Unknown';
    }
    final day = DateTime.now().difference(latestLog!.startDate).inDays % latestLog!.cycleLength! + 1;
    if (day <= 5) return 'Menstrual';
    if (day <= 11) return 'Follicular';
    if (day <= 17) return 'Ovulation';
    if (day <= 28) return 'Luteal';
    return 'Unknown';
  }

  /// 🔑 Computed: Fertile window (±3 days around ovulation)
  DateTime? get fertileWindowStart =>
      predictedOvulation != null ? predictedOvulation!.subtract(const Duration(days: 3)) : null;

  DateTime? get fertileWindowEnd =>
      predictedOvulation != null ? predictedOvulation!.add(const Duration(days: 3)) : null;
}
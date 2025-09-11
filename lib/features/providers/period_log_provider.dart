import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/period_log.dart';

class PeriodLogProvider with ChangeNotifier {
  final List<PeriodLog> _logs = [];

  List<PeriodLog> get logs => [..._logs];

  final _firestore = FirebaseFirestore.instance;
  final String _prefsKey = "period_logs";

  /// ✅ Save logs to local cache
  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = _logs.map((log) => jsonEncode(log.toMap())).toList();
    await prefs.setStringList(_prefsKey, logsJson);
  }

  /// ✅ Load logs from local cache
  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getStringList(_prefsKey) ?? [];
    _logs.clear();
    _logs.addAll(logsJson.map((log) => PeriodLog.fromMap(jsonDecode(log))));
    _recalculateCycles();
    notifyListeners();
  }

  /// ✅ Load logs (first from cache, then Firestore)
  Future<void> loadLogs() async {
    await _loadFromLocal();

    try {
      final snapshot = await _firestore.collection('period_log').get();
      final firestoreLogs =
      snapshot.docs.map((doc) => PeriodLog.fromMap(doc.data())).toList();

      if (firestoreLogs.isNotEmpty) {
        _logs.clear();
        _logs.addAll(firestoreLogs);
        _recalculateCycles();
        await _saveToLocal();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading Firestore logs: $e");
      }
    }
  }

  /// ✅ Add new log
  Future<void> addLog(PeriodLog log) async {
    _logs.add(log);

    // Sort and recalc cycles
    _logs.sort((a, b) => a.startDate.compareTo(b.startDate));
    _recalculateCycles();
    _logs.sort((a, b) => b.startDate.compareTo(a.startDate));

    notifyListeners();
    await _saveToLocal();

    // Firestore save
    try {
      await _firestore.collection('period_log').add(log.toMap());
    } catch (e) {
      if (kDebugMode) {
        print("Error saving log to Firestore: $e");
      }
    }
  }

  /// ✅ Remove log
  Future<void> removeLog(int index) async {
    if (index < 0 || index >= _logs.length) return;
    final log = _logs[index];
    _logs.removeAt(index);

    _recalculateCycles();
    notifyListeners();
    await _saveToLocal();

    try {
      final snapshot = await _firestore
          .collection('period_log')
          .where('startDate', isEqualTo: log.startDate.toIso8601String())
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error removing log from Firestore: $e");
      }
    }
  }

  /// ✅ Cycle length calculation
  void _recalculateCycles() {
    for (int i = 0; i < _logs.length; i++) {
      if (i == 0) {
        _logs[i].cycleLength = null;
      } else {
        final prevStart = _logs[i - 1].startDate;
        final currentStart = _logs[i].startDate;
        _logs[i].cycleLength = currentStart.difference(prevStart).inDays;
      }
    }
  }
}



// import 'package:flutter/foundation.dart';
// import '../models/period_log.dart';
//
// class PeriodLogProvider with ChangeNotifier {
//   final List<PeriodLog> _logs = [];
//
//   List<PeriodLog> get logs => [..._logs];
//
//   void addLog(PeriodLog log) {
//     _logs.add(log);
//     _logs.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
//
//     // After sorting, update cycle length for each except the first (index 0)
//     for (int i = 1; i < _logs.length; i++) {
//       _logs[i].cycleLength = _logs[i].startDate.difference(_logs[i - 1].startDate).inDays;
//     }
//
//     notifyListeners();
//   }
//
//
// // void addLog(PeriodLog log) {
//   //   _logs.add(log);
//   //   _logs.sort((a, b) => b.startDate.compareTo(a.startDate));
//   //   notifyListeners();
//   // }
// }
//
//
// // import 'package:flutter/foundation.dart';
// // import '../models/period_log.dart';
// //
// // class PeriodLogProvider with ChangeNotifier {
// //   final List<PeriodLog> _logs = [];
// //
// //   List<PeriodLog> get logs => [..._logs]; // No sorting here; we sort once in addLog()
// //
// //   void addLog(PeriodLog log) {
// //     _logs.add(log);
// //     _logs.sort((a, b) => b.startDate.compareTo(a.startDate)); // Sort only when adding
// //     notifyListeners();
// //   }
// //
// //   /// Returns the cycle length in days between the current log and the previous one.
// //   /// Assumes the logs are already sorted in descending order.
// //   int? getCycleLengthForLog(int index) {
// //     // Work with already sorted logs
// //     if (index == 0 || index >= _logs.length) return null;
// //     final current = _logs[index];
// //     final previous = _logs[index - 1];
// //     return current.startDate.difference(previous.startDate).inDays;
// //   }
// // }

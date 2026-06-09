// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../models/period_log.dart';
//
// class PeriodLogProvider with ChangeNotifier {
//   final List<PeriodLog> _logs = [];
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   List<PeriodLog> get logs => [..._logs];
//
//   /// 🔑 Generate a user-specific SharedPreferences key
//   String _getPrefsKey(String uid) => "${uid}_period_logs";
//
//   /// 🔄 Sort logs and recalculate cycle lengths
//   void _sortAndRecalculate() {
//     _logs.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first
//     for (int i = 0; i < _logs.length; i++) {
//       if (i == 0) {
//         _logs[i].cycleLength = null;
//       } else {
//         _logs[i].cycleLength =
//             _logs[i].startDate.difference(_logs[i - 1].startDate).inDays;
//       }
//     }
//   }
//
//   /// 🔄 Load logs from cache and Firestore
//   Future<void> loadLogs() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     final prefs = await SharedPreferences.getInstance();
//     final key = _getPrefsKey(user.uid);
//
//     // Load from offline cache first
//     final cachedJson = prefs.getStringList(key) ?? [];
//     _logs.clear();
//     _logs.addAll(cachedJson.map((e) => PeriodLog.fromMap(jsonDecode(e))));
//     _sortAndRecalculate();
//     notifyListeners();
//
//     // Load from Firestore
//     try {
//       final snapshot = await _firestore
//           .collection('period_log')
//           .where('uid', isEqualTo: user.uid)
//           .get();
//
//       final firestoreLogs =
//       snapshot.docs.map((doc) => PeriodLog.fromMap(doc.data())).toList();
//
//       if (firestoreLogs.isNotEmpty) {
//         _logs.clear();
//         _logs.addAll(firestoreLogs);
//         _sortAndRecalculate();
//         await _saveToLocal(user.uid);
//         notifyListeners();
//       }
//     } catch (e) {
//       if (kDebugMode) print("Error loading Firestore logs: $e");
//     }
//   }
//
//   /// ✅ Add new log (offline + Firestore)
//   Future<void> addLog(PeriodLog log) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     _logs.add(log);
//     _sortAndRecalculate();
//     notifyListeners();
//     await _saveToLocal(user.uid);
//
//     try {
//       await _firestore.collection('period_log').add({
//         'uid': user.uid,
//         ...log.toMap(),
//       });
//     } catch (e) {
//       if (kDebugMode) print("Error saving log to Firestore: $e");
//     }
//   }
//
//   /// ✅ Remove log
//   Future<void> removeLog(int index) async {
//     if (index < 0 || index >= _logs.length) return;
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     final log = _logs.removeAt(index);
//     _sortAndRecalculate();
//     notifyListeners();
//     await _saveToLocal(user.uid);
//
//     try {
//       final snapshot = await _firestore
//           .collection('period_log')
//           .where('uid', isEqualTo: user.uid)
//           .where('startDate', isEqualTo: log.startDate.toIso8601String())
//           .get();
//
//       for (var doc in snapshot.docs) {
//         await doc.reference.delete();
//       }
//     } catch (e) {
//       if (kDebugMode) print("Error removing log from Firestore: $e");
//     }
//   }
//
//   /// ✅ Offline caching
//   Future<void> _saveToLocal(String uid) async {
//     final prefs = await SharedPreferences.getInstance();
//     final key = _getPrefsKey(uid);
//     final logsJson = _logs.map((log) => jsonEncode(log.toMapOffline())).toList();
//     await prefs.setStringList(key, logsJson);
//   }
//
//   /// ✅ Reset logs (e.g., on logout)
//   Future<void> resetLogs() async {
//     _logs.clear();
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_getPrefsKey(user.uid));
//     }
//     notifyListeners();
//   }
//
//   /// 🔑 Computed: Latest log
//   PeriodLog? get latestLog => _logs.isNotEmpty ? _logs.first : null;
//
//   /// 🔑 Computed: Predicted next period (auto-advances monthly)
//   DateTime? get predictedNextPeriod {
//     if (latestLog == null || latestLog!.startDate == null || latestLog!.cycleLength == null) {
//       return null;
//     }
//
//     DateTime predicted = latestLog!.startDate.add(Duration(days: latestLog!.cycleLength!));
//     final today = DateTime.now();
//
//     // Keep adding cycle length until we get a future date
//     while (predicted.isBefore(today)) {
//       predicted = predicted.add(Duration(days: latestLog!.cycleLength!));
//     }
//
//     return predicted;
//   }
//
//   /// 🔑 Computed: Predicted ovulation (mid-cycle, synced with next period)
//   DateTime? get predictedOvulation {
//     final nextPeriod = predictedNextPeriod;
//     if (nextPeriod == null || latestLog == null || latestLog!.cycleLength == null) {
//       return null;
//     }
//
//     // Ovulation is ~14 days before next period (standard cycle midpoint)
//     return nextPeriod.subtract(Duration(days: (latestLog!.cycleLength! ~/ 2)));
//   }
//
//   /// 🔑 Computed: Cycle phase based on last period
//   String get cyclePhase {
//     if (latestLog == null || latestLog!.startDate == null || latestLog!.cycleLength == null) {
//       return 'Unknown';
//     }
//     final day = DateTime.now().difference(latestLog!.startDate).inDays % latestLog!.cycleLength! + 1;
//     if (day <= 5) return 'Menstrual';
//     if (day <= 11) return 'Follicular';
//     if (day <= 17) return 'Ovulation';
//     if (day <= 28) return 'Luteal';
//     return 'Unknown';
//   }
//
//   /// 🔑 Computed: Fertile window (±3 days around ovulation)
//   DateTime? get fertileWindowStart =>
//       predictedOvulation != null ? predictedOvulation!.subtract(const Duration(days: 3)) : null;
//
//   DateTime? get fertileWindowEnd =>
//       predictedOvulation != null ? predictedOvulation!.add(const Duration(days: 3)) : null;
// }

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/period_log.dart';

class PeriodLogProvider with ChangeNotifier {
  final List<PeriodLog> _logs = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Default cycle length (can be overridden)
  int _defaultCycleLength = 28;

  // Track if logs have been loaded
  bool _logsLoaded = false;

  List<PeriodLog> get logs => [..._logs];

  /// 🔑 Set default cycle length (from user profile)
  void setDefaultCycleLength(int length) {
    if (kDebugMode) print('🔄 Setting default cycle length to: $length');
    _defaultCycleLength = length;
    notifyListeners();
  }

  /// 🔑 Generate a user-specific SharedPreferences key
  String _getPrefsKey(String uid) => "${uid}_period_logs";

  /// 🔄 Sort logs and recalculate cycle lengths
  void _sortAndRecalculate() {
    _logs.sort((a, b) => b.startDate.compareTo(a.startDate)); // newest first

    for (int i = 0; i < _logs.length; i++) {
      if (i < _logs.length - 1) {
        // Gap between this log and the next older one
        _logs[i].cycleLength =
            _logs[i].startDate.difference(_logs[i + 1].startDate).inDays;
      } else {
        // Oldest log — no previous log to compare, use default
        _logs[i].cycleLength = _defaultCycleLength;
      }
    }
  }
  /// 🔄 Load logs from cache and Firestore
  Future<void> loadLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (kDebugMode) print('❌ No user logged in');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _getPrefsKey(user.uid);

    // Load from offline cache first
    final cachedJson = prefs.getStringList(key) ?? [];
    _logs.clear();
    _logs.addAll(cachedJson.map((e) => PeriodLog.fromMap(jsonDecode(e))));
    _sortAndRecalculate();
    if (kDebugMode) print('📝 Loaded ${_logs.length} period logs from cache');
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
        if (kDebugMode) print('📝 Loaded ${_logs.length} period logs from Firestore');
        notifyListeners();
      } else {
        if (kDebugMode) print('⚠️ No period logs found in Firestore');
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error loading Firestore logs: $e");
    }

    _logsLoaded = true;
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
      if (kDebugMode) print('✅ New period log added');
    } catch (e) {
      if (kDebugMode) print("❌ Error saving log to Firestore: $e");
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
      if (kDebugMode) print("❌ Error removing log from Firestore: $e");
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
    _logsLoaded = false;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getPrefsKey(user.uid));
    }
    notifyListeners();
  }

  /// 🔑 Computed: Latest log (with auto-load)
  PeriodLog? get latestLog {
    // If logs haven't been loaded yet, try to load them
    if (!_logsLoaded) {
      if (kDebugMode) print('⚠️ Logs not loaded yet, attempting to load...');
      loadLogs();
    }
    return _logs.isNotEmpty ? _logs.first : null;
  }

  /// 🔑 Helper: Get the most recent calculated cycle length from logs
  int? _getLastCalculatedCycleLength() {
    for (var log in _logs) {
      if (log.cycleLength != null && log.cycleLength! > 0) {
        return log.cycleLength;
      }
    }
    return null;
  }

  /// 🔑 Get effective cycle length (calculated, default, or 28)
  int _getEffectiveCycleLength() {
    final calculated = _getLastCalculatedCycleLength();
    final effective = calculated ?? _defaultCycleLength;
    if (kDebugMode) {
      print('📊 Cycle Length - Calculated: $calculated, Default: $_defaultCycleLength, Effective: $effective');
    }
    return effective;
  }

  /// 🔑 Computed: Predicted next period (auto-advances monthly)
  DateTime? get predictedNextPeriod {
    if (latestLog == null) {
      if (kDebugMode) print('⚠️ No latest log found');
      return null;
    }

    if (latestLog!.startDate == null) {
      if (kDebugMode) print('⚠️ Latest log has no start date');
      return null;
    }

    final cycleLength = _getEffectiveCycleLength();
    DateTime predicted = latestLog!.startDate!.add(Duration(days: cycleLength));
    final today = DateTime.now();

    if (kDebugMode) {
      print('📅 Latest Period: ${latestLog!.startDate}');
      print('📅 Initial Prediction: $predicted');
      print('📅 Today: $today');
    }

    // Keep adding cycle length until we get a future date
    int iterations = 0;
    while (predicted.isBefore(today) && iterations < 100) {
      predicted = predicted.add(Duration(days: cycleLength));
      iterations++;
    }

    if (kDebugMode) {
      print('📅 Final Prediction (after $iterations iterations): $predicted');
      print('📅 Days until next period: ${predicted.difference(today).inDays}');
    }

    return predicted;
  }

  /// 🔑 Computed: Predicted ovulation (mid-cycle, synced with next period)
  DateTime? get predictedOvulation {
    final nextPeriod = predictedNextPeriod;
    if (nextPeriod == null) {
      return null;
    }

    final cycleLength = _getEffectiveCycleLength();
    final ovulation = nextPeriod.subtract(Duration(days: (cycleLength ~/ 2)));
    if (kDebugMode) {
      print('💗 Predicted Ovulation: $ovulation');
    }
    return ovulation;
  }

  /// 🔑 Computed: Cycle phase based on last period
  String get cyclePhase {
    if (latestLog == null || latestLog!.startDate == null) {
      return 'Unknown';
    }

    final cycleLength = _getEffectiveCycleLength();
    final day = DateTime.now().difference(latestLog!.startDate!).inDays % cycleLength + 1;
    String phase;
    if (day <= 5) phase = 'Menstrual';
    else if (day <= 11) phase = 'Follicular';
    else if (day <= 17) phase = 'Ovulation';
    else if (day <= 28) phase = 'Luteal';
    else phase = 'Unknown';

    if (kDebugMode) {
      print('🔄 Cycle Phase: Day $day of $cycleLength = $phase');
    }
    return phase;
  }

  /// 🔑 Computed: Fertile window (±3 days around ovulation)
  DateTime? get fertileWindowStart =>
      predictedOvulation != null ? predictedOvulation!.subtract(const Duration(days: 3)) : null;

  DateTime? get fertileWindowEnd =>
      predictedOvulation != null ? predictedOvulation!.add(const Duration(days: 3)) : null;
}
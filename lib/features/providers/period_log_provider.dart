import 'package:flutter/foundation.dart';
import '../models/period_log.dart';

class PeriodLogProvider with ChangeNotifier {
  final List<PeriodLog> _logs = [];

  List<PeriodLog> get logs => [..._logs];

  void addLog(PeriodLog log) {
    _logs.add(log);

    // Sort logs by startDate in ascending order so we calculate cycles correctly
    _logs.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Recalculate cycle lengths for all logs
    for (int i = 0; i < _logs.length; i++) {
      if (i == 0) {
        _logs[i].cycleLength = null; // First log has no cycle
      } else {
        final prevStart = _logs[i - 1].startDate;
        final currentStart = _logs[i].startDate;
        _logs[i].cycleLength = currentStart.difference(prevStart).inDays;
      }
    }

    // (Optional) If you want newest log to show first in the UI:
    _logs.sort((a, b) => b.startDate.compareTo(a.startDate));

    notifyListeners();
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

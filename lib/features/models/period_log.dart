import 'package:intl/intl.dart';

class PeriodLog {
  final DateTime startDate;
  final DateTime endDate;
  final String flowIntensity;
  final String? note;
  int? cycleLength;

  PeriodLog({
    required this.startDate,
    required this.endDate,
    required this.flowIntensity,
    this.note,
    this.cycleLength,
  });

  String get monthLabel => DateFormat('MMMM yyyy').format(startDate);
  String get month => DateFormat('MMMM').format(startDate);

  // ✅ Convert to Map for Firestore & SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'flowIntensity': flowIntensity,
      'note': note,
      'cycleLength': cycleLength,
    };
  }

  // ✅ Create from Map
  factory PeriodLog.fromMap(Map<String, dynamic> map) {
    return PeriodLog(
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      flowIntensity: map['flowIntensity'],
      note: map['note'],
      cycleLength: map['cycleLength'],
    );
  }
}



// import 'package:intl/intl.dart';
//
// class PeriodLog {
//   final DateTime startDate;
//   final DateTime endDate;
//   final String flowIntensity;
//   final String? note;
//
//   PeriodLog({
//     required this.startDate,
//     required this.endDate,
//     required this.flowIntensity,
//     this.note,
//   });
//
//   String get monthLabel => DateFormat('MMMM yyyy').format(startDate);
//   String get month => DateFormat('MMMM').format(startDate);
// }
//
//
// // import 'package:intl/intl.dart';
// //
// // class PeriodLog {
// //   final DateTime startDate;
// //   final DateTime endDate;
// //   final String flowIntensity;
// //   final String? note;
// //
// //   PeriodLog({
// //     required this.startDate,
// //     required this.endDate,
// //     required this.flowIntensity,
// //     this.note,
// //   });
// //
// //   /// This returns the month and year of the start date (e.g., "April 2025")
// //   String get monthLabel => DateFormat('MMMM yyyy').format(startDate);
// //
// //   /// This returns just the month (e.g., "April")
// //   String get month => DateFormat('MMMM').format(startDate);
// // }
// //

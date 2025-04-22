import 'package:intl/intl.dart';

class PeriodLog {
  final DateTime startDate;
  final DateTime endDate;
  final String flowIntensity;
  final String? note;
  int? cycleLength; // <-- New field

  PeriodLog({
    required this.startDate,
    required this.endDate,
    required this.flowIntensity,
    this.note,
    this.cycleLength,
  });

  String get monthLabel => DateFormat('MMMM yyyy').format(startDate);
  String get month => DateFormat('MMMM').format(startDate);
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

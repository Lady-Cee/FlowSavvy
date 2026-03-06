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

  /// Returns month + year label (e.g., "April 2026")
  String get monthLabel => DateFormat('MMMM yyyy').format(startDate);

  /// Returns just the month (e.g., "April")
  String get month => DateFormat('MMMM').format(startDate);

  /// ✅ Convert log to Map for Firestore
  Map<String, dynamic> toMap({String? uid}) {
    return {
      if (uid != null) 'uid': uid, // associate with current user
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'flowIntensity': flowIntensity,
      'note': note,
      'cycleLength': cycleLength,
    };
  }

  /// ✅ Convert log to Map for offline caching (no UID needed)
  Map<String, dynamic> toMapOffline() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'flowIntensity': flowIntensity,
      'note': note,
      'cycleLength': cycleLength,
    };
  }

  /// ✅ Create PeriodLog from Map (Firestore or SharedPreferences)
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
class ProfileCompleteModel {
  final int age;
  final int cycleLength;
  final int periodLength;
  final DateTime Date;
  final DateTime firstDayOfLastPeriod;

  ProfileCompleteModel({
    required this.age,
    required this.cycleLength,
    required this.periodLength,
   required this.Date,
    required this.firstDayOfLastPeriod,
  });

  /// Convert to Map for local database storage
  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'periodDate': Date.toIso8601String(),
      'lastPeriodDate': firstDayOfLastPeriod.toIso8601String(),
    };
  }

  /// Create from Map (for reading from local database)
  factory ProfileCompleteModel.fromMap(Map<String, dynamic> map) {
    return ProfileCompleteModel(
      age: map['age'],
      cycleLength: map['cycleLength'],
      periodLength: map['periodLength'],
      Date: DateTime.parse(map['periodDate']),
      firstDayOfLastPeriod: DateTime.parse(map['lastPeriodDate']),
    );
  }
}

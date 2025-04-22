import 'package:flutter/material.dart';

class UserProfileModel {
  final String name;
  final int age;
  final int cycleLength;
  final DateTime lastPeriodDate;
  final DateTime? predictedNextPeriod;
  final DateTime? predictedOvulation;

  UserProfileModel({
    required this.name,
    required this.age,
    required this.cycleLength,
    required this.lastPeriodDate,
    this.predictedNextPeriod,
    this.predictedOvulation,
  });

  // Convert a UserProfileModel instance into a Map for saving in the database
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'cycleLength': cycleLength,
      'lastPeriodDate': lastPeriodDate.toIso8601String(),
      'predictedNextPeriod': predictedNextPeriod?.toIso8601String(),
      'predictedOvulation': predictedOvulation?.toIso8601String(),
    };
  }

  // Create a UserProfileModel from a Map (for reading from the database)
  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'],
      age: map['age'],
      cycleLength: map['cycleLength'],
      lastPeriodDate: DateTime.parse(map['lastPeriodDate']),
      predictedNextPeriod: map['predictedNextPeriod'] != null
          ? DateTime.parse(map['predictedNextPeriod'])
          : null,
      predictedOvulation: map['predictedOvulation'] != null
          ? DateTime.parse(map['predictedOvulation'])
          : null,
    );
  }
}


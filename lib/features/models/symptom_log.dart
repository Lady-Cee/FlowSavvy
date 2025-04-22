import 'package:flutter/foundation.dart';

class SymptomLog {
  final DateTime date;
  final List<String> symptoms;
  final List<String> mood;
  final int painLevel;
  final List<String> medications;
  final List<String> remedies;
  final String motivation;

  SymptomLog({
    required this.date,
    required this.symptoms,
    required this.mood,
    required this.painLevel,
    required this.medications,
    required this.remedies,
    required this.motivation,
  });
}


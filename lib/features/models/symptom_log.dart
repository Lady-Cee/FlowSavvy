import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomLog {
  final String id;
  final DateTime date;
  final List<String> symptoms;
  final List<String> mood;
  final int painLevel;
  final List<String> remedies;
  final String motivation;

  SymptomLog({
    required this.id,
    required this.date,
    required this.symptoms,
    required this.mood,
    required this.painLevel,
    required this.remedies,
    required this.motivation,
  });

  // copyWith helper
  SymptomLog copyWith({
    String? id,
    DateTime? date,
    List<String>? symptoms,
    List<String>? mood,
    int? painLevel,
    List<String>? remedies,
    String? motivation,
  }) {
    return SymptomLog(
      id: id ?? this.id,
      date: date ?? this.date,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      painLevel: painLevel ?? this.painLevel,
      remedies: remedies ?? this.remedies,
      motivation: motivation ?? this.motivation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.millisecondsSinceEpoch,
      'symptoms': symptoms,
      'mood': mood,
      'painLevel': painLevel,
      'remedies': remedies,
      'motivation': motivation,
    };
  }

  factory SymptomLog.fromMap(Map<String, dynamic> map) {
    return SymptomLog(
      id: map['id'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      mood: List<String>.from(map['mood'] ?? []),
      painLevel: map['painLevel'] ?? 0,
      remedies: List<String>.from(map['remedies'] ?? []),
      motivation: map['motivation'] ?? '',
    );
  }

  factory SymptomLog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SymptomLog(
      id: doc.id,
      date: DateTime.fromMillisecondsSinceEpoch(data['date']),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      mood: List<String>.from(data['mood'] ?? []),
      painLevel: data['painLevel'] ?? 0,
      remedies: List<String>.from(data['remedies'] ?? []),
      motivation: data['motivation'] ?? '',
    );
  }
}
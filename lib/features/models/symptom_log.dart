import 'package:cloud_firestore/cloud_firestore.dart';

class SymptomLog {
  final String id; // Firestore document ID
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

  /// 🔹 Firestore -> model
  factory SymptomLog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SymptomLog(
      id: doc.id,
      date: (data['date'] as Timestamp).toDate(),
      symptoms: List<String>.from(data['symptoms'] ?? []),
      mood: List<String>.from(data['mood'] ?? []),
      painLevel: data['painLevel'] ?? 0,
      remedies: List<String>.from(data['remedies'] ?? []),
      motivation: data['motivation'] ?? '',
    );
  }

  /// 🔹 Map -> model (for offline SharedPreferences)
  factory SymptomLog.fromMap(Map<String, dynamic> map) {
    return SymptomLog(
      id: map['id'] ?? '', // optional fallback
      date: DateTime.parse(map['date']),
      symptoms: List<String>.from(map['symptoms'] ?? []),
      mood: List<String>.from(map['mood'] ?? []),
      painLevel: map['painLevel'] ?? 0,
      remedies: List<String>.from(map['remedies'] ?? []),
      motivation: map['motivation'] ?? '',
    );
  }

  /// 🔹 Model -> Map (for offline SharedPreferences)
  Map<String, dynamic> toMapOffline() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'symptoms': symptoms,
      'mood': mood,
      'painLevel': painLevel,
      'remedies': remedies,
      'motivation': motivation,
    };
  }

  /// 🔹 Model -> Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'date': Timestamp.fromDate(date),
      'symptoms': symptoms,
      'mood': mood,
      'painLevel': painLevel,
      'remedies': remedies,
      'motivation': motivation,
    };
  }
}
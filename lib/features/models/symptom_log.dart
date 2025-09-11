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
}

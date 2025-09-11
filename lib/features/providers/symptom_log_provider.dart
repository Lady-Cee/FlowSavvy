import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/symptom_log.dart';

class SymptomLogProvider with ChangeNotifier {
  final List<SymptomLog> _logs = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<SymptomLog> get logs => [..._logs];

  /// Load logs from Firestore
  Future<void> fetchLogs() async {
    final snapshot = await _firestore
        .collection('symptom_log')
        .orderBy('date', descending: true)
        .get();

    _logs.clear();
    _logs.addAll(snapshot.docs.map((doc) => SymptomLog.fromDoc(doc)).toList());
    notifyListeners();
  }

  /// Add log to Firestore + local list
  Future<void> addLog(SymptomLog log) async {
    final docRef = await _firestore.collection('symptom_log').add(log.toMap());
    final newLog = SymptomLog(
      id: docRef.id,
      date: log.date,
      symptoms: log.symptoms,
      mood: log.mood,
      painLevel: log.painLevel,
      remedies: log.remedies,
      motivation: log.motivation,
    );

    _logs.insert(0, newLog); // newest first
    notifyListeners();
  }

  /// Remove log
  Future<void> removeLog(String id) async {
    await _firestore.collection('symptom_log').doc(id).delete();
    _logs.removeWhere((log) => log.id == id);
    notifyListeners();
  }
}



// import 'package:flutter/material.dart';
// import '../models/symptom_log.dart';
//
// class SymptomLogProvider with ChangeNotifier {
//   final List<SymptomLog> _logs = [];
//
//   List<SymptomLog> get logs => [..._logs];
//
//   void addLog(SymptomLog log) {
//     _logs.add(log);
//     notifyListeners();
//   }
// }

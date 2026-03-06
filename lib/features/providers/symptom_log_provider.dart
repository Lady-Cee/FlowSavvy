import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/symptom_log.dart';

class SymptomLogProvider with ChangeNotifier {
  final List<SymptomLog> _logs = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<SymptomLog> get logs => [..._logs];

  /// 🔹 Load logs from Firestore + cache offline
  Future<void> fetchLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '${user.uid}_symptom_logs';

    try {
      final snapshot = await _firestore
          .collection('symptom_log')
          .where('uid', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      _logs.clear();
      _logs.addAll(snapshot.docs.map((doc) => SymptomLog.fromDoc(doc)).toList());

      // save offline
      final jsonList = _logs.map((log) => jsonEncode(log.toMap())).toList();
      await prefs.setStringList(key, jsonList);

      notifyListeners();
    } catch (e) {
      // fallback: load from SharedPreferences if offline
      final cachedLogs = prefs.getStringList(key);
      if (cachedLogs != null) {
        _logs.clear();
        _logs.addAll(
            cachedLogs.map((e) => SymptomLog.fromMap(jsonDecode(e))).toList());
        notifyListeners();
      }
    }
  }

  /// 🔹 Add log to Firestore + local list + offline cache
  Future<void> addLog(SymptomLog log) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await _firestore.collection('symptom_log').add({
      'uid': user.uid,
      ...log.toMap(),
    });

    final newLog = SymptomLog(
      id: docRef.id,
      date: log.date,
      symptoms: log.symptoms,
      mood: log.mood,
      painLevel: log.painLevel,
      remedies: log.remedies,
      motivation: log.motivation,
    );

    _logs.insert(0, newLog);
    await _saveLogsToPrefs(user.uid); // update offline cache
    notifyListeners();
  }

  /// 🔹 Remove log from Firestore + list + offline cache
  Future<void> removeLog(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('symptom_log').doc(id).delete();
    _logs.removeWhere((log) => log.id == id);
    await _saveLogsToPrefs(user.uid); // update offline cache
    notifyListeners();
  }

  /// 🔹 Helper: save current logs to SharedPreferences
  Future<void> _saveLogsToPrefs(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${uid}_symptom_logs';
    final jsonList = _logs.map((log) => jsonEncode(log.toMap())).toList();
    await prefs.setStringList(key, jsonList);
  }

  /// 🔹 Reset logs on logout / switch user
  void resetLogs() async {
    _logs.clear();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${user.uid}_symptom_logs');
    }
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

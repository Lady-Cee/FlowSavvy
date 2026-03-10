import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/symptom_log.dart';

class SymptomLogProvider with ChangeNotifier {
  final List<SymptomLog> _logs = [];
  final Set<String> _hiddenIds = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Only returns logs that aren't hidden
  List<SymptomLog> get logs =>
      _logs.where((log) => !_hiddenIds.contains(log.id)).toList();

  // ───────── FETCH ─────────
  Future<void> fetchLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '${user.uid}_symptom_logs';

    // load offline cache first
    final cachedLogs = prefs.getStringList(key);
    if (cachedLogs != null) {
      _logs.clear();
      _logs.addAll(cachedLogs.map((e) => SymptomLog.fromMap(jsonDecode(e))));
      notifyListeners();
    }

    // sync Firestore in background
    try {
      final snapshot = await _firestore
          .collection('symptom_log')
          .where('uid', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _logs.clear();
        _logs.addAll(snapshot.docs.map((doc) => SymptomLog.fromDoc(doc)));
        await _saveLogsToPrefs(user.uid);
        notifyListeners();
      }
    } catch (_) {
      // offline cache already loaded
    }
  }

  // ───────── ADD ─────────
  Future<void> addLog(SymptomLog log) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = await _firestore.collection('symptom_log').add({
      'uid': user.uid,
      ...log.toMap(),
    });

    final newLog = log.copyWith(id: docRef.id);
    _logs.insert(0, newLog);
    await _saveLogsToPrefs(user.uid);
    notifyListeners();
  }

  // ───────── SOFT DELETE ─────────
  void hideLog(String id) {
    _hiddenIds.add(id);
    notifyListeners();
  }

  void restoreLog(String id) {
    _hiddenIds.remove(id);
    notifyListeners();
  }

  // ───────── HARD DELETE ─────────
  Future<void> removeLog(String id) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _hiddenIds.remove(id);
    _logs.removeWhere((log) => log.id == id);

    try {
      await _firestore.collection('symptom_log').doc(id).delete();
    } catch (_) {
      // Firestore failed — still removed locally
    }

    await _saveLogsToPrefs(user.uid);
    notifyListeners();
  }

  // ───────── HELPERS ─────────
  Future<void> _saveLogsToPrefs(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${uid}_symptom_logs';
    final visibleLogs = _logs.where((log) => !_hiddenIds.contains(log.id));
    final jsonList = visibleLogs.map((log) => jsonEncode(log.toMap())).toList();
    await prefs.setStringList(key, jsonList);
  }

  Future<void> resetLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    _logs.clear();
    _hiddenIds.clear();
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${user.uid}_symptom_logs');
    }
    notifyListeners();
  }
}
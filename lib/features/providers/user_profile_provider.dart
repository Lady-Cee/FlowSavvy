import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profilel.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfileModel? _userProfile;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserProfileModel? get userProfile => _userProfile;

  /// 🔑 Get UID safely
  String? get _uid => _auth.currentUser?.uid;

  /// 🔄 Load profile (offline first)
  Future<void> loadUserProfile() async {
    final uid = _uid;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('${uid}_user_name');
    final age = prefs.getInt('${uid}_user_age');
    final cycleLength = prefs.getInt('${uid}_user_cycle_length');
    final lastPeriodString = prefs.getString('${uid}_user_last_period');

    /// 📱 Load from local storage first (offline-first)
    if (name != null &&
        age != null &&
        cycleLength != null &&
        lastPeriodString != null) {
      final lastPeriod = DateTime.parse(lastPeriodString);

      final updatedProfile = _calculatePredictions(
        name: name,
        age: age,
        cycleLength: cycleLength,
        lastPeriod: lastPeriod,
      );

      _userProfile = updatedProfile;
      notifyListeners();
      return; // 🔥 Stop here if local data exists
    }

    /// ☁️ If no local data, fetch from Firestore
    final doc =
    await _firestore.collection('users_profile').doc(uid).get();

    if (doc.exists) {
      final data = doc.data()!;

      final lastPeriod = DateTime.parse(data['lastPeriodDate']);

      final updatedProfile = _calculatePredictions(
        name: data['name'],
        age: data['age'],
        cycleLength: data['cycleLength'],
        lastPeriod: lastPeriod,
      );

      _userProfile = updatedProfile;

      /// Save locally for offline use
      await _saveToPrefs(updatedProfile);

      notifyListeners();
    }
  }

  /// 💾 Save profile
  Future<void> saveUserProfile(
      String name,
      int age,
      int cycleLength,
      DateTime lastPeriodDate,
      ) async {
    final uid = _uid;
    if (uid == null) return;

    final profile = _calculatePredictions(
      name: name,
      age: age,
      cycleLength: cycleLength,
      lastPeriod: lastPeriodDate,
    );

    _userProfile = profile;
    notifyListeners();

    /// Save locally first
    await _saveToPrefs(profile);

    /// Sync to Firestore
    await _firestore.collection('users_profile').doc(uid).set({
      'name': profile.name,
      'age': profile.age,
      'cycleLength': profile.cycleLength,
      'lastPeriodDate': profile.lastPeriodDate.toIso8601String(),
      'predictedNextPeriod':
      profile.predictedNextPeriod?.toIso8601String(),
      'predictedOvulation':
      profile.predictedOvulation?.toIso8601String(),
    }, SetOptions(merge: true));
  }

  /// 🔮 Cycle prediction logic
  UserProfileModel _calculatePredictions({
    required String name,
    required int age,
    required int cycleLength,
    required DateTime lastPeriod,
  }) {
    final nextPeriod = lastPeriod.add(Duration(days: cycleLength));

    // Ovulation is ~14 days before next period
    final ovulationDate = nextPeriod.subtract(const Duration(days: 14));

    return UserProfileModel(
      name: name,
      age: age,
      cycleLength: cycleLength,
      lastPeriodDate: lastPeriod,
      predictedNextPeriod: nextPeriod,
      predictedOvulation: ovulationDate,
    );

  }

  /// 💾 Save to SharedPreferences using UID
  Future<void> _saveToPrefs(UserProfileModel profile) async {
    final uid = _uid;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('${uid}_user_name', profile.name);
    await prefs.setInt('${uid}_user_age', profile.age);
    await prefs.setInt('${uid}_user_cycle_length', profile.cycleLength);
    await prefs.setString(
        '${uid}_user_last_period', profile.lastPeriodDate.toIso8601String());
    await prefs.setString(
        '${uid}_user_predicted_next_period',
        profile.predictedNextPeriod!.toIso8601String());
    await prefs.setString(
        '${uid}_user_predicted_ovulation',
        profile.predictedOvulation!.toIso8601String());
  }

  /// 🧹 Clear data on logout
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = _uid;

    if (uid == null) return;

    await prefs.remove('${uid}_user_name');
    await prefs.remove('${uid}_user_age');
    await prefs.remove('${uid}_user_cycle_length');
    await prefs.remove('${uid}_user_last_period');
    await prefs.remove('${uid}_user_predicted_next_period');
    await prefs.remove('${uid}_user_predicted_ovulation');

    _userProfile = null;
    notifyListeners();
  }

  void resetProfile() {
    _userProfile = null;
    notifyListeners();
  }

  String getCyclePhase() {
    if (_userProfile == null) return '';

    final today = DateTime.now();
    final lastPeriod = _userProfile!.lastPeriodDate;
    final cycleLength = _userProfile!.cycleLength;

    final daysSinceLastPeriod = today.difference(lastPeriod).inDays;
    final cycleDay = (daysSinceLastPeriod % cycleLength) + 1;

    if (cycleDay <= 5) {
      return 'Menstrual Phase';
    } else if (cycleDay <= 13) {
      return 'Follicular Phase';
    } else if (cycleDay == 14) {
      return 'Ovulation';
    } else {
      return 'Luteal Phase';
    }
  }

  DateTime? get fertileWindowStart {
    if (_userProfile == null) return null;

    final ovulation = _userProfile!.predictedOvulation!;
    return ovulation.subtract(const Duration(days: 4));
  }

  DateTime? get fertileWindowEnd {
    if (_userProfile == null) return null;

    final ovulation = _userProfile!.predictedOvulation!;
    return ovulation.add(const Duration(days: 1));
  }
}
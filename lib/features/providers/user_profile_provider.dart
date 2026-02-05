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

  /// 🔄 Ensure predictions are always recalculated when loading
  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('user_name');
    final age = prefs.getInt('user_age');
    final cycleLength = prefs.getInt('user_cycle_length');
    final lastPeriodString = prefs.getString('user_last_period');

    if (name != null && age != null && cycleLength != null && lastPeriodString != null) {
      final lastPeriod = DateTime.parse(lastPeriodString);

      // 🔑 Always recalc predictions when loading
      final updatedProfile = _calculatePredictions(
        name: name,
        age: age,
        cycleLength: cycleLength,
        lastPeriod: lastPeriod,
      );

      _userProfile = updatedProfile;
      await _saveToPrefs(updatedProfile);
    } else {
      _userProfile = null;
    }

    notifyListeners();

    // 🔄 Sync with Firestore if logged in
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users_profile').doc(user.uid).get();
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
        await _saveToPrefs(updatedProfile);
        notifyListeners();
      }
    }
  }

  /// Save the profile
  Future<void> saveUserProfile(
      String name,
      int age,
      int cycleLength,
      DateTime lastPeriodDate,
      ) async {
    final profile = _calculatePredictions(
      name: name,
      age: age,
      cycleLength: cycleLength,
      lastPeriod: lastPeriodDate,
    );

    _userProfile = profile;
    notifyListeners();

    await _saveToPrefs(profile);

    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users_profile').doc(user.uid).set({
        'name': profile.name,
        'age': profile.age,
        'cycleLength': profile.cycleLength,
        'lastPeriodDate': profile.lastPeriodDate.toIso8601String(),
        'predictedNextPeriod': profile.predictedNextPeriod?.toIso8601String(),
        'predictedOvulation': profile.predictedOvulation?.toIso8601String(),
      }, SetOptions(merge: true));
    }
  }

  /// 🔮 Core calculation logic
  UserProfileModel _calculatePredictions({
    required String name,
    required int age,
    required int cycleLength,
    required DateTime lastPeriod,
  }) {
    final now = DateTime.now();
    final daysSinceLast = now.difference(lastPeriod).inDays;
    final cyclesPassed = (daysSinceLast / cycleLength).floor();

    // shift last period forward to the most recent cycle
    final updatedLastPeriod = lastPeriod.add(Duration(days: cyclesPassed * cycleLength));
    final nextPeriod = updatedLastPeriod.add(Duration(days: cycleLength));
    final ovulationDate = updatedLastPeriod.add(Duration(days: (cycleLength / 2).round()));

    return UserProfileModel(
      name: name,
      age: age,
      cycleLength: cycleLength,
      lastPeriodDate: updatedLastPeriod,
      predictedNextPeriod: nextPeriod,
      predictedOvulation: ovulationDate,
    );
  }

  Future<void> _saveToPrefs(UserProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', profile.name);
    await prefs.setInt('user_age', profile.age);
    await prefs.setInt('user_cycle_length', profile.cycleLength);
    await prefs.setString('user_last_period', profile.lastPeriodDate.toIso8601String());
    await prefs.setString('user_predicted_next_period', profile.predictedNextPeriod!.toIso8601String());
    await prefs.setString('user_predicted_ovulation', profile.predictedOvulation!.toIso8601String());
  }
}

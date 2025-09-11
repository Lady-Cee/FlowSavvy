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

  /// Load the profile from local storage first,
  /// then try to sync with Firebase if logged in.
  Future<void> loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();

    final name = prefs.getString('user_name');
    final age = prefs.getInt('user_age');
    final cycleLength = prefs.getInt('user_cycle_length');
    final lastPeriodString = prefs.getString('user_last_period');
    final nextPeriodString = prefs.getString('user_predicted_next_period');
    final ovulationString = prefs.getString('user_predicted_ovulation');

    if (name != null && age != null && cycleLength != null && lastPeriodString != null) {
      _userProfile = UserProfileModel(
        name: name,
        age: age,
        cycleLength: cycleLength,
        lastPeriodDate: DateTime.parse(lastPeriodString),
        predictedNextPeriod: nextPeriodString != null ? DateTime.parse(nextPeriodString) : null,
        predictedOvulation: ovulationString != null ? DateTime.parse(ovulationString) : null,
      );
    } else {
      _userProfile = null;
    }

    notifyListeners();

    // 🔄 If user is logged in, try to fetch from Firestore
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final fetchedProfile = UserProfileModel(
          name: data['name'],
          age: data['age'],
          cycleLength: data['cycleLength'],
          lastPeriodDate: DateTime.parse(data['lastPeriodDate']),
          predictedNextPeriod: data['predictedNextPeriod'] != null
              ? DateTime.parse(data['predictedNextPeriod'])
              : null,
          predictedOvulation: data['predictedOvulation'] != null
              ? DateTime.parse(data['predictedOvulation'])
              : null,
        );

        _userProfile = fetchedProfile;
        await _saveToPrefs(fetchedProfile); // keep local copy updated
        notifyListeners();
      }
    }
  }

  /// Save the profile locally and push to Firebase if logged in
  Future<void> saveUserProfile(
      String name,
      int age,
      int cycleLength,
      DateTime lastPeriodDate,
      ) async {
    final predictedNextPeriod = lastPeriodDate.add(Duration(days: cycleLength));
    final predictedOvulation = lastPeriodDate.add(Duration(days: (cycleLength / 2).round()));

    final profile = UserProfileModel(
      name: name,
      age: age,
      cycleLength: cycleLength,
      lastPeriodDate: lastPeriodDate,
      predictedNextPeriod: predictedNextPeriod,
      predictedOvulation: predictedOvulation,
    );

    _userProfile = profile;
    notifyListeners();

    // Save locally
    await _saveToPrefs(profile);

    // Push to Firestore if logged in
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

  /// Helper to persist locally
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

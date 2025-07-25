import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/db_helper.dart'; // Assuming this is where you handle DB operations
import '../models/user_profilel.dart'; // Import your UserProfileModel

class UserProfileProvider with ChangeNotifier {
  UserProfileModel? _userProfile;

  UserProfileModel? get userProfile => _userProfile;

  // Load the user profile from the database
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
      _userProfile = null; // Clear if missing
    }

    notifyListeners(); // Always notify listeners even if values haven't changed
  }


  // Save the user profile to the database and update the local state
  Future<void> saveUserProfile(
      String name,
      int age,
      int cycleLength,
      DateTime lastPeriodDate,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    // Calculate predictions
    final predictedNextPeriod = lastPeriodDate.add(Duration(days: cycleLength));
    final predictedOvulation = lastPeriodDate.add(Duration(days: (cycleLength / 2).round()));

    // Save or overwrite all fields
    await prefs.setString('user_name', name);
    await prefs.setInt('user_age', age);
    await prefs.setInt('user_cycle_length', cycleLength);
    await prefs.setString('user_last_period', lastPeriodDate.toIso8601String());
    await prefs.setString('user_predicted_next_period', predictedNextPeriod.toIso8601String());
    await prefs.setString('user_predicted_ovulation', predictedOvulation.toIso8601String());

    // Update the provider state
    _userProfile = UserProfileModel(
      name: name,
      age: age,
      cycleLength: cycleLength,
      lastPeriodDate: lastPeriodDate,
      predictedNextPeriod: predictedNextPeriod,
      predictedOvulation: predictedOvulation,
    );

    notifyListeners();
  }

}


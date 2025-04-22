import 'package:flutter/material.dart';
import '../db/db_helper.dart'; // Assuming this is where you handle DB operations
import '../models/user_profilel.dart'; // Import your UserProfileModel

class UserProfileProvider with ChangeNotifier {
  UserProfileModel? _userProfile;

  UserProfileModel? get userProfile => _userProfile;

  // Load the user profile from the database
  Future<void> loadUserProfile() async {
    _userProfile = await DBHelper.instance.getUserProfile();
    notifyListeners();
  }

  // Save the user profile to the database and update the local state
  Future<void> saveUserProfile(
      String name,
      int age,
      int cycleLength,
      DateTime lastPeriodDate,
      ) async {
    // Calculate predicted next period and ovulation date
    final predictedNextPeriod = lastPeriodDate.add(Duration(days: cycleLength));
    final predictedOvulation = predictedNextPeriod.subtract(Duration(days: 14));

    // Create the user profile
    _userProfile = UserProfileModel(
      name: name,
      age: age,
      cycleLength: cycleLength,
      lastPeriodDate: lastPeriodDate,
      predictedNextPeriod: predictedNextPeriod,
      predictedOvulation: predictedOvulation,
    );

    // Save the profile to the database
    await DBHelper.instance.insertOrUpdateUserProfile(_userProfile!);

    // Notify listeners of the updated profile
    notifyListeners();
  }
}


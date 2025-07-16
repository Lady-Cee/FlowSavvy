import 'package:flutter/material.dart';
import '../models/profile_complete_model.dart';

class ProfileCompleteProvider extends ChangeNotifier {
  ProfileCompleteModel? _profile;

  /// Getter for current profile data
  ProfileCompleteModel? get profile => _profile;

  /// Save or update the profile
  void setProfile(ProfileCompleteModel profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Clear stored profile (optional)
  void clearProfile() {
    _profile = null;
    notifyListeners();
  }

  /// Check if profile is completed
  bool get isProfileComplete => _profile != null;
}


import 'package:flutter/material.dart';
import '../services/firebase_auth_services.dart';

class AuthProvider with ChangeNotifier {
  final FireBaseAuthService _authService;

  AuthProvider(this._authService);

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    return await _authService.login(email, password);
  }

  Future<String?> signUp(String email, String password, String firstName, String surname) async {
    return await _authService.signUp(email, password, firstName, surname);
  }

  Future<String?> resetPassword(String email) async {
    return await _authService.resetPassword(email);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  // Optional: expose current user
  get currentUser => _authService.currentUser;
}

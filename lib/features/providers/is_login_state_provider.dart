import 'package:flutter/material.dart';

class IsLoginStateProvider extends ChangeNotifier {
  bool _isLogin = true;

  bool get isLogin => _isLogin;

  void toggle() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  void setLogin() {
    _isLogin = true;
    notifyListeners();
  }

  void setSignup() {
    _isLogin = false;
    notifyListeners();
  }
}

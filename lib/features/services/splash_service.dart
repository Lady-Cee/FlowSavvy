import 'package:shared_preferences/shared_preferences.dart';

class SplashService {
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunchedBefore = prefs.getBool('hasLaunchedBefore') ?? false;


    if (!hasLaunchedBefore) {
      await prefs.setBool('hasLaunchedBefore', true);
      return true;
    }
    return false;
  }

}

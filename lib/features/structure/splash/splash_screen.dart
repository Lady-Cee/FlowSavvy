import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow_savvy/features/account/login/login_screen.dart';
import 'package:flow_savvy/features/structure/home/screen/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberMe') ?? false;

    // Optional delay so the splash screen shows briefly
    await Future.delayed(const Duration(seconds: 2));

    if (remember) {
      Navigator.pushNamed(context, '/home');
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/images2.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12, top: 100, bottom: 100),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  width: MediaQuery.sizeOf(context).width * 0.8,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                const Text(
                  "Your companion for holistic menstrual health — understand and predict your cycle and ovulation, track symptoms, monitor mood and pain levels, log medications and remedies, and receive personalized motivation to navigate your cycle with clarity and confidence.",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                const Text(
                  "Be period-smart — understand, predict, track, and thrive with FlowSavvy!",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.06),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade400,
                      foregroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Get Started ✌️",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                        const Icon(Icons.arrow_forward)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

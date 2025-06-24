import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/splash_service.dart';
import '../../widgets/splash_item.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAnimationSequence();
  }

  void _startAnimationSequence() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentIndex < 4) {
        setState(() {
          _currentIndex++;
        });
      } else {
        timer.cancel();
        _decideNext();
      }
    });
  }

  Future<void> _decideNext() async {
    final splashService = context.read<SplashService>();

    final isFirstTime = await splashService.isFirstLaunch();
    if (isFirstTime) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      final route = await splashService.getNextRoute();
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      SplashItem(image: 'assets/images/splash_screen/splash1.png'),
      SplashItem(image: 'assets/images/splash_screen/splash2.png'),
      SplashItem(image: 'assets/images/splash_screen/splash3.png'),
      SplashItem(image: 'assets/images/splash_screen/splash4.png'),
      SplashItem(image: 'assets/images/splash_screen/splash5.png'),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        children: List.generate(screens.length, (index) {
          return AnimatedOpacity(
            opacity: _currentIndex == index ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: screens[index],
          );
        }),
      ),
    );
  }
}

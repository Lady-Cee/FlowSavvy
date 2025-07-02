import 'package:flutter/material.dart';

import '../utils/app_strings.dart';
import 'custom_header.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStrings appStrings = AppStrings();

    return SafeArea(
      child: Column(
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.5, // Show top half only
              child: Image.asset(
                "assets/images/onboarding/onboarding6.png",
                height: 250, // set fixed height
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 25),
          CustomHeader(
            title: appStrings.loginHeaderText,
            subTitle: appStrings.loginSubtitleText,
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }
}

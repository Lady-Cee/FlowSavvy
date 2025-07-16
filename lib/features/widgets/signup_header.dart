import 'package:flutter/material.dart';

import '../utils/app_strings.dart';
import 'custom_header.dart';

class SignupHeader extends StatelessWidget {
  const SignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStrings appStrings = AppStrings();

    return SafeArea(
      child: Column(
        children: [
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.5,
              child: Image.asset(
                "assets/images/onboarding/onboarding5.png",
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 25),
          CustomHeader(
            title: appStrings.signupHeaderText,
            subTitle: appStrings.signupSubtitleText,
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }
}


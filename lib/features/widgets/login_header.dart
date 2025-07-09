import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flow_savvy/features/widgets/custom_header.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppStrings appStrings = AppStrings();

    return Column(
      children: [
        // Image.asset(""),
        CustomHeader(title: appStrings.loginHeaderText, subTitle: appStrings.loginSubtitleText)
      ],
    );
  }
}




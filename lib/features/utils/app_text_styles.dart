import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';


class AppTextStyles {
  static TextStyle largeTextSemiBold(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      height: 1.4,
      color: theme.colorScheme.inversePrimary,
    );
  }

  static TextStyle mediumTextSemiBold(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 1.4,
      color: theme.colorScheme.inversePrimary,
    );
  }

  static TextStyle smallTextSemiBold(BuildContext context) {
    final theme = Theme.of(context);
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 1.4,
      //color: theme.colorScheme.surface,
      color: theme.colorScheme.inversePrimary,
    );
  }

  static TextStyle smallTextRegular(BuildContext context) {
    final appTheme = Provider.of<AppTheme>(context, listen: false);
    return TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.4,
      color: appTheme.lightMode.colorScheme.inversePrimary,
    );
  }
}

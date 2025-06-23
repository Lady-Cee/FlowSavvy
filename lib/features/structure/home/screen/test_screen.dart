import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flow_savvy/features/utils/constants.dart';
import 'package:flow_savvy/features/widgets/custom_header.dart';
import 'package:flow_savvy/features/widgets/custom_text_field.dart';
import 'package:flow_savvy/features/widgets/long_custom_button.dart';
import 'package:flutter/material.dart';

import '../../../widgets/login_sign_up_switch.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool isLogin = true;
  TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AppStrings appStrings = AppStrings();
    return Scaffold(
      body: Padding(
        padding: AppConstants.scaffoldPadding,
        child: Center(
            child: Column(
          children: [
            CustomHeader(
                title: appStrings.onboardingHeaderTitle1,
                subTitle: appStrings.onboardingHeaderSubTitle1),
            SizedBox(
              height: 10,
            ),
            LongCustomButton(onTap: () {}, title: 'Button'),
            SizedBox(
              height: 10,
            ),
            LoginSignupSwitch(
              isLoginSelected: isLogin,
              onToggle: (value) {
                setState(() {
                  isLogin = value;
                });
              },
            ),
            const SizedBox(height: 20),
            isLogin ? Text('Login') : Text('SignUp'),
            SizedBox(
              height: 10,
            ),
            CustomTextField(
              hintText: 'Enter Name',
              controller: _nameController,
              isObscure: false,
              isOptionalLeadingIcon: true,
              optionalLeadingIcon: Icons.email,
            ),
            SizedBox(height: 10,),
            CustomTextField(
              hintText: 'Enter Password',
              controller: _nameController,
              isObscure: true,
              isOptionalLeadingIcon: true,
              optionalLeadingIcon: Icons.lock,
            ),
          ],
        )),
      ),
    );
  }
}

import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flow_savvy/features/utils/constants.dart';
import 'package:flow_savvy/features/widgets/custom_header.dart';
import 'package:flow_savvy/features/widgets/custom_text_field.dart';
import 'package:flow_savvy/features/widgets/login_header.dart';
import 'package:flow_savvy/features/widgets/long_custom_button.dart';
import 'package:flow_savvy/features/widgets/signup_header.dart';
import 'package:flutter/material.dart';

import '../../../account/login/login_screen.dart';
import '../../../account/signup/signup_screen.dart';
import '../../../widgets/login_sign_up_switch.dart';

//import '../../../widgets/login_sign_up_switch.dart';

class LoginSignUpScreen extends StatefulWidget {
  const LoginSignUpScreen ({super.key});

  @override
  State<LoginSignUpScreen> createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen> {
  bool isLogin = true;
  //
  // // Login controllers
  // final TextEditingController _loginEmailController = TextEditingController();
  // final TextEditingController _loginPasswordController = TextEditingController();

  // Signup controllers
  final TextEditingController _signupNameController = TextEditingController();
  final TextEditingController _signupEmailController = TextEditingController();
  final TextEditingController _signupPasswordController = TextEditingController();
  final TextEditingController _signupConfirmPasswordController = TextEditingController();

  // Widget _buildSignupForm() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.stretch,
  //     children: [
  //       CustomTextField(
  //         hintText: 'Enter Full Name',
  //         controller: _signupNameController,
  //         isObscure: false,
  //         isOptionalLeadingIcon: true,
  //         optionalLeadingIcon: Icons.person,
  //       ),
  //       const SizedBox(height: 20),
  //       CustomTextField(
  //         hintText: 'Enter Email',
  //         controller: _signupEmailController,
  //         isObscure: false,
  //         isOptionalLeadingIcon: true,
  //         optionalLeadingIcon: Icons.email,
  //       ),
  //       const SizedBox(height: 20),
  //       CustomTextField(
  //         hintText: 'Enter Password',
  //         controller: _signupPasswordController,
  //         isObscure: true,
  //         isOptionalLeadingIcon: true,
  //         optionalLeadingIcon: Icons.lock,
  //       ),
  //       const SizedBox(height: 20),
  //       CustomTextField(
  //         hintText: 'Confirm Password',
  //         controller: _signupConfirmPasswordController,
  //         isObscure: true,
  //         isOptionalLeadingIcon: true,
  //         optionalLeadingIcon: Icons.lock,
  //       ),
  //       const SizedBox(height: 40),
  //       LongCustomButton(
  //         onTap: () {
  //           // Handle signup
  //           //Navigator.pushNamed(context, '/profileCompleteScreen');
  //         },
  //         title: 'Create Account',
  //       ),
  //     ],
  //   );
  // }



  @override
  Widget build(BuildContext context) {
    final AppStrings appStrings = AppStrings();

    return Scaffold(
      body: Padding(
        padding: AppConstants.scaffoldPadding,
        child: Center(
            child: Column(
              children: [
                isLogin ? LoginHeader() : SignupHeader(),
                SizedBox(
                  height: 10,
                ),

        // LongCustomButton(onTap: () {}, title: 'Button'),
                // SizedBox(
                //   height: 10,
                // ),
                LoginSignupSwitch(
                  isLoginSelected: isLogin,
                  onToggle: (value) {
                    setState(() {
                      isLogin = value;
                    });
                  },
                ),

                isLogin ? Expanded(child: LoginScreen ()) : Flexible(child: SignupScreen()),
                // const SizedBox(height: 20),
                // isLogin ? Text('Login') : Text('SignUp'),
                SizedBox(height: 25),

                // isLogin ? LoginScreen() : _buildSignupForm(),
                // const SizedBox(height: 30),
              ],
            )),
      ),
    );
  }
}



// import 'package:flow_savvy/features/utils/app_strings.dart';
// import 'package:flow_savvy/features/utils/app_text_styles.dart';
// import 'package:flow_savvy/features/utils/constants.dart';
// import 'package:flow_savvy/features/widgets/custom_header.dart';
// import 'package:flow_savvy/features/widgets/custom_text_field.dart';
// import 'package:flow_savvy/features/widgets/login_header.dart';
// import 'package:flow_savvy/features/widgets/long_custom_button.dart';
// import 'package:flow_savvy/features/widgets/signup_header.dart';
// import 'package:flutter/material.dart';
//
// import 'login_sign_up_switch.dart';
//
// //import '../../../widgets/login_sign_up_switch.dart';
//
// class LoginSignUpScreen extends StatefulWidget {
//   const LoginSignUpScreen ({super.key});
//
//   @override
//   State<LoginSignUpScreen> createState() => _LoginSignUpScreenState();
// }
//
// class _LoginSignUpScreenState extends State<LoginSignUpScreen> {
//   bool isLogin = true;
//   TextEditingController _nameController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final AppStrings appStrings = AppStrings();
//     return Scaffold(
//       body: Padding(
//         padding: AppConstants.scaffoldPadding,
//         child: Center(
//             child: Column(
//               children: [
//                 isLogin ? LoginHeader() : SignupHeader(),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 LongCustomButton(onTap: () {}, title: 'Button'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 LoginSignupSwitch(
//                   isLoginSelected: isLogin,
//                   onToggle: (value) {
//                     setState(() {
//                       isLogin = value;
//                     });
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 isLogin ? Text('Login') : Text('SignUp'),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 CustomTextField(
//                   hintText: 'Enter Name',
//                   controller: _nameController,
//                   isObscure: false,
//                   isOptionalLeadingIcon: true,
//                   optionalLeadingIcon: Icons.email,
//                 ),
//                 SizedBox(height: 10,),
//                 CustomTextField(
//                   hintText: 'Enter Password',
//                   controller: _nameController,
//                   isObscure: true,
//                   isOptionalLeadingIcon: true,
//                   optionalLeadingIcon: Icons.lock,
//                 ),
//               ],
//             )),
//       ),
//     );
//   }
// }

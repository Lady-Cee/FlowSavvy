import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flow_savvy/features/utils/constants.dart';
import 'package:flow_savvy/features/widgets/custom_header.dart';
import 'package:flow_savvy/features/widgets/custom_text_field.dart';
import 'package:flow_savvy/features/widgets/login_header.dart';
import 'package:flow_savvy/features/widgets/long_custom_button.dart';
import 'package:flow_savvy/features/widgets/signup_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../signup/signup_screen.dart';
import '../../providers/is_login_state_provider.dart';
import '../../widgets/login_sign_up_switch.dart';

//import '../../../widgets/login_sign_up_switch.dart';

class LoginSignUpScreen extends StatefulWidget {
  const LoginSignUpScreen ({super.key});

  @override
  State<LoginSignUpScreen> createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen> {
  // bool isLogin = true;


  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<IsLoginStateProvider>().isLogin;

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

                LoginSignupSwitch(
                  isLoginSelected: isLogin,
                  onToggle: (value) {
                    context.read<IsLoginStateProvider>().toggle();
                  },
                ),

                isLogin ? Expanded(child: LoginScreen ()) : Flexible(child: SignupScreen()),

                SizedBox(height: 25),
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

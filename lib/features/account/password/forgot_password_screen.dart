import 'package:flow_savvy/features/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/long_custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  void resetPassword()async{
    String email = emailController.text.trim();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final message = await authProvider.resetPassword(email);

    if (message == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent to $email!"), backgroundColor: Theme.of(context).colorScheme.primary,),
      );
      emailController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message),  backgroundColor: Theme.of(context).colorScheme.primary,),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reset Password"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [

          CustomTextField(
          hintText: 'Enter Email',
          controller: emailController,
          isObscure: false,
          isOptionalLeadingIcon: true,
          optionalLeadingIcon: Icons.email,
        ),
          const SizedBox(height: 20),
            // SizedBox(height: 20),
            // ElevatedButton(
            //   onPressed: () => resetPassword(),
            //   child: Text("Reset Password"),
            // ),
            LongCustomButton(
              onTap: () => resetPassword(),
              title: 'Reset Password',
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Remember your password? ",
                    style: AppTextStyles.smallTextRegular(context)),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/loginSignUpScreen');
                  },
                  child: Text(
                    "Login",
                    style: AppTextStyles.smallTextSemiBold(context).copyWith(
                        color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flow_savvy/features/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/long_custom_button.dart';
import '../login/login_signup_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();

  void resetPassword() async {
    String email = emailController.text.trim();

    // Simple validation if the field is empty
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter your email address"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final message = await authProvider.resetPassword(email);

    if (!mounted) return;

    if (message == null) {
      // 🔑 Show custom theme-matched dialog popup
      showDialog(
        context: context,
        barrierDismissible: false, // Force user to tap OK
        builder: (BuildContext dialogContext) {
          final primaryColor = Theme.of(context).colorScheme.primary;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.mark_email_read_outlined, color: primaryColor),
                const SizedBox(width: 10),
                Text(
                  "Check Your Inbox",
                  style: AppTextStyles.mediumTextSemiBold(context),
                ),
              ],
            ),
            content: Text(
              "Password reset email has been sent to:\n\n$email\n\nPlease check your inbox and follow the instructions to reset your password.",
              style: AppTextStyles.smallTextRegular(context),
            ),
            actions: [
              LongCustomButton(
                onTap: () {
                  Navigator.of(dialogContext).pop(); // Close dialog
                  emailController.clear();
                  // Optional: Navigate back to login screen after success
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginSignUpScreen()),
                  );
                },
                title: 'OK',
              ),
            ],
          );
        },
      );
    } else {
      // Show error snackbar if something went wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
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

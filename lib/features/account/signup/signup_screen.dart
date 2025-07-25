import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/is_login_state_provider.dart';
import '../../services/firebase_auth_services.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/long_custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final firstNameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // final FireBaseAuthService _authService = FireBaseAuthService();

  bool _obscureText = true;
  bool _obscureText1 = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _toggleVisibility1() {
    setState(() {
      _obscureText1 = !_obscureText1;
    });
  }

  void signUpUser() async {
    final firstName = firstNameController.text.trim();
    final surname = surnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;


    if (firstName.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields", style: TextStyle(color: Colors.red),)),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match", style: TextStyle(color: Colors.red),)),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.signUp(email, password, firstName, surname);

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup successful! Please log in."),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Provider.of<IsLoginStateProvider>(context, listen: false).setLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result, style: TextStyle(color: Colors.red),)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  appBar: AppBar(title: Text("Sign Up")),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            children: [
              CustomTextField(
                hintText: 'Enter First Name',
                controller: firstNameController,
                isObscure: false,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.person,
              ),
              SizedBox(height: 20),
              CustomTextField(
                hintText: 'Enter Surname',
                controller: surnameController,
                isObscure: false,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.person,
              ),
              SizedBox(height: 20),
              CustomTextField(
                hintText: 'Enter Email',
                controller: emailController,
                isObscure: false,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.email,
              ),
              SizedBox(height: 20),
              CustomTextField(
                hintText: 'Enter Password',
                controller: passwordController,
                isObscure: true,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.lock,

              ),
              SizedBox(height: 20),
              CustomTextField(
                hintText: 'Confirm Password',
                controller: confirmPasswordController,
                isObscure: true,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.lock,
              ),
              SizedBox(height: 40),
              LongCustomButton(
                onTap: () => signUpUser() ,
                title: "Sign Up",
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: () {
                     // Navigator.pushNamed(context, '/loginSignUpScreen');
                      Provider.of<IsLoginStateProvider>(context, listen: false).setLogin();
                    },
                    child: Text(
                      "Login",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          );

        }
      ),
    );
  }
}

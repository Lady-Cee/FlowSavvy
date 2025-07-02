import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/long_custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // final emailController = TextEditingController();
  // final passwordController = TextEditingController();


  // Login controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadLoginPreferences();
    _checkLoginStatus();
  }

  Future<void> _loadLoginPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberMe') ?? false;
    final savedEmail = prefs.getString('rememberedEmail') ?? '';

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.toggleRememberMe(remember);

    if (remember) {
      _loginEmailController.text = savedEmail;
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberMe') ?? false;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (remember && authProvider.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/profileCompleteScreen');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  // void _showMessage(String message) {
  //   final isDark = Theme.of(context).brightness == Brightness.dark;
  //   final snackBarBackground = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFFFE9E4);
  //   final snackBarTextColor = isDark ? Colors.white : Colors.black;
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(
  //         message,
  //         style: TextStyle(
  //           color: snackBarTextColor,
  //           fontSize: 14,
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //       backgroundColor: snackBarBackground,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       duration: const Duration(seconds: 3),
  //       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     ),
  //   );
  // }


  void loginUser() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter both email and password.');
      return;
    }

    setState(() => _isLoading = true);
    final error = await authProvider.login(email, password);
    setState(() => _isLoading = false);

    final prefs = await SharedPreferences.getInstance();

    if (error == null) {
      await prefs.setBool('rememberMe', authProvider.rememberMe);
      if (authProvider.rememberMe) {
        await prefs.setString('rememberedEmail', email);
      } else {
        await prefs.remove('rememberedEmail');
      }
      Navigator.pushReplacementNamed(context, '/profileCompleteScreen');
    } else {
      _showMessage(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      //appBar: AppBar(title: Text("Login")),
      body: LayoutBuilder(
        builder: (context, constraints){
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  hintText: 'Enter Email',
                  controller: _loginEmailController,
                  isObscure: false,
                  isOptionalLeadingIcon: true,
                  optionalLeadingIcon: Icons.email,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  hintText: 'Enter Password',
                  controller: _loginPasswordController,
                  isObscure: true,
                  isOptionalLeadingIcon: true,
                  optionalLeadingIcon: Icons.lock,
                ),

                SizedBox(height: 10),
                Row(
                  children: [
                    Checkbox(
                      value: authProvider.rememberMe,
                      onChanged: (val) {
                        authProvider.toggleRememberMe(val ?? false);
                      },
                    ),
                    SizedBox(width: 5),
                    Text("Remember me",
                        style: AppTextStyles.smallTextRegular(context)),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/forgotPassword');
                      },
                      child: Text(
                        "Forgot Password?",
                        style: AppTextStyles.smallTextSemiBold(context).copyWith(
                          color: Colors.blue,
                        ),
                      ),

                    ),
                  ],
                ),
                SizedBox(height: 30),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    :  LongCustomButton(
                  onTap: loginUser,
                  title: 'Login',
                ),

                // ElevatedButton(
                //   onPressed: loginUser,
                //   child: Text("Login"),
                // ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: AppTextStyles.smallTextRegular(context)
                      ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        //Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        "Sign Up",
                        style: AppTextStyles.smallTextSemiBold(context).copyWith(
                          color: Colors.blue,
                        ),
                      ),

                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

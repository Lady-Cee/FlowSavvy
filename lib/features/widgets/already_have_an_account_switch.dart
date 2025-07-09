import 'package:flutter/material.dart';

class AlreadyHaveAnAccountSwitch extends StatelessWidget {
  const AlreadyHaveAnAccountSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Column();
  }
}




class LoginSignUpConfirmation extends StatelessWidget {
  final String title;
  final String subTitle;
  final Function() onTap;

  const LoginSignUpConfirmation({super.key, required this.title, required this.subTitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: Text(
            "Sign up",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    );
  }
}

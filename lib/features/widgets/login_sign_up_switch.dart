import 'package:flutter/material.dart';

/// simply having two expanded buttons in a row in a container.
/// The active one retains the surface color while the inactive one is transparent hence creating a switch like effect.
class LoginSignupSwitch extends StatelessWidget {
  final bool isLoginSelected;
  final Function(bool isLogin) onToggle;

  const LoginSignupSwitch({
    super.key,
    required this.isLoginSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Login Side
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isLoginSelected
                      ? Theme.of(context).colorScheme.surface
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontWeight:
                        isLoginSelected ? FontWeight.bold : FontWeight.normal,
                    color: isLoginSelected
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ),
          // Signup Side
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isLoginSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Signup',
                  style: TextStyle(
                    fontWeight:
                        !isLoginSelected ? FontWeight.bold : FontWeight.normal,
                    color: !isLoginSelected ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

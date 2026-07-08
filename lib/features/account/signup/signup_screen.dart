import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/schools_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/is_login_state_provider.dart';
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
  final contactNameController = TextEditingController();
  final contactPhoneController = TextEditingController();

  bool _obscureText = true;
  bool _obscureText1 = true;
  SchoolData? _selectedSchool;

  void _toggleVisibility() => setState(() => _obscureText = !_obscureText);
  void _toggleVisibility1() => setState(() => _obscureText1 = !_obscureText1);

  void signUpUser() async {
    final firstName = firstNameController.text.trim();
    final surname = surnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (firstName.isEmpty ||
        surname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields',
              style: TextStyle(color: Colors.red)),
        ),
      );
      return;
    }

    if (_selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a school',
              style: TextStyle(color: Colors.red)),
        ),
      );
      return;
    }

    if (_selectedSchool == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a school',
            style: TextStyle(color: Colors.red))),
      );
      return;
    }

    if (contactNameController.text.trim().isEmpty ||
        contactPhoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter contact name and phone number',
            style: TextStyle(color: Colors.red))),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match',
              style: TextStyle(color: Colors.red)),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.signUp(
      email,
      password,
      firstName,
      surname,
      _selectedSchool!.name,
      _selectedSchool!.lga,
      contactNameController.text.trim(),
      contactPhoneController.text.trim(),
    );

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Signup successful! Please log in.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Provider.of<IsLoginStateProvider>(context, listen: false).setLogin();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result, style: const TextStyle(color: Colors.red))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              CustomTextField(
                hintText: 'Enter First Name',
                controller: firstNameController,
                isObscure: false,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.person,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Enter Surname',
                controller: surnameController,
                isObscure: false,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.person,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Enter Email',
                controller: emailController,
                isObscure: false,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.email,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Enter Password',
                controller: passwordController,
                isObscure: _obscureText,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.lock,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Confirm Password',
                controller: confirmPasswordController,
                isObscure: _obscureText1,
                isOptionalLeadingIcon: true,
                optionalLeadingIcon: Icons.lock,
              ),
              const SizedBox(height: 20),

              // School dropdown
              DropdownButtonFormField<SchoolData>(
                value: _selectedSchool,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: 'Select School',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: kSchools
                    .map((school) => DropdownMenuItem(
                  value: school,
                  child: Text(school.name, overflow: TextOverflow.ellipsis,),
                ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedSchool = value),
              ),

              // Show LGA and contact info once school is selected
              if (_selectedSchool != null) ...[
                const SizedBox(height: 16),
                // LGA auto-fills, read only
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text('LGA: ${_selectedSchool!.lga}',
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Contact name — user types this
                CustomTextField(
                  hintText: 'Contact Name',
                  controller: contactNameController,
                  isObscure: false,
                  isOptionalLeadingIcon: true,
                  optionalLeadingIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                // Contact phone — user types this
                CustomTextField(
                  hintText: 'Contact Phone Number',
                  controller: contactPhoneController,
                  isObscure: false,
                  isOptionalLeadingIcon: true,
                  optionalLeadingIcon: Icons.phone_outlined,
                ),
              ],

              const SizedBox(height: 40),
              LongCustomButton(
                onTap: signUpUser,
                title: 'Sign Up',
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? '),
                  GestureDetector(
                    onTap: () => Provider.of<IsLoginStateProvider>(context,
                        listen: false)
                        .setLogin(),
                    child: const Text('Login',
                        style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
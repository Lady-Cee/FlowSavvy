import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/schools_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/is_login_state_provider.dart';
import '../../providers/symptom_log_provider.dart';
import '../../providers/user_profile_provider.dart';
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
  bool _isLoading = false;
  String? _selectedLga;
  SchoolData? _selectedSchool;

  // ignore: unused_element
  void _toggleVisibility() => setState(() => _obscureText = !_obscureText);
  // ignore: unused_element
  void _toggleVisibility1() => setState(() => _obscureText1 = !_obscureText1);

  @override
  void dispose() {
    firstNameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.red)),
      ),
    );
  }

  void signUpUser() async {
    // Ignore extra taps while signing up
    if (_isLoading) return;

    final firstName = firstNameController.text.trim();
    final surname = surnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    final notInSchool = isNotInSchool(_selectedSchool);

    if (firstName.isEmpty ||
        surname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('Please fill all fields');
      return;
    }

    if (_selectedLga == null) {
      _showError('Please select an LGA');
      return;
    }

    if (_selectedSchool == null) {
      _showError('Please select a school');
      return;
    }

    if (contactNameController.text.trim().isEmpty ||
        contactPhoneController.text.trim().isEmpty) {
      _showError('Please enter contact name and phone number');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
      return;
    }

    // Grab everything that needs context BEFORE any await
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loginStateProvider =
    Provider.of<IsLoginStateProvider>(context, listen: false);
    final profileProvider =
    Provider.of<UserProfileProvider>(context, listen: false);
    final logProvider =
    Provider.of<SymptomLogProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    setState(() => _isLoading = true);

    try {
      final result = await authProvider.signUp(
        email,
        password,
        firstName,
        surname,
        notInSchool ? 'Not in school' : _selectedSchool!.name, // changed
        _selectedLga!, // changed (was _selectedSchool!.lga)
        contactNameController.text.trim(),
        contactPhoneController.text.trim(),
        inSchool: !notInSchool,
      );

      if (!mounted) return;

      // Sign up failed: show the error and stay on this screen
      if (result != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(result, style: const TextStyle(color: Colors.red)),
          ),
        );
        return;
      }

      // Account created. Log the user in straight away.
      final loginError = await authProvider.login(email, password);

      if (!mounted) return;

      // Auto-login failed for some reason: fall back to the old behaviour
      // (account exists, send them to the login screen).
      if (loginError != null) {
        messenger.showSnackBar(
          SnackBar(
            content: const Text('Signup successful! Please log in.'),
            backgroundColor: primaryColor,
          ),
        );
        loginStateProvider.setLogin();
        return;
      }

      // Same steps the login screen runs, so the home screen shows this
      // user's data and not stale or empty data.
      await profileProvider.loadUserProfile();
      await logProvider.fetchLogs();

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: const Text('Welcome! Your account has been created.'),
          backgroundColor: primaryColor,
        ),
      );

      navigator.pushReplacementNamed('/home');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notInSchoolSelected = isNotInSchool(_selectedSchool); // add this

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

              // LGA dropdown
              DropdownButtonFormField<String>(
                value: _selectedLga,
                isExpanded: true,
                menuMaxHeight: 350,
                decoration: InputDecoration(
                  hintText: 'Select LGA',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [kNotInSchoolLabel, ...kLgas]
                    .map((lga) => DropdownMenuItem<String>(
                  value: lga,
                  child: Text(
                    lga,
                    style: lga == kNotInSchoolLabel
                        ? const TextStyle(fontWeight: FontWeight.w600)
                        : null,
                  ),
                ))
                    .toList(),
                onChanged: (value) => setState(() {
                  _selectedLga = value;
                  // Not in school -> school is filled in automatically; otherwise reset
                  _selectedSchool =
                  value == kNotInSchoolLabel ? kNotInSchool : null;
                }),
              ),
              const SizedBox(height: 20),

              // School dropdown (only schools in the chosen LGA)
              DropdownButtonFormField<SchoolData>(
                key: ValueKey(_selectedLga), // clean reset when LGA changes
                value: _selectedSchool,
                isExpanded: true,
                menuMaxHeight: 350,
                decoration: InputDecoration(
                  hintText: _selectedLga == null
                      ? 'Select LGA first'
                      : 'Select School',
                  prefixIcon: const Icon(Icons.school),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _selectedLga == null
                    ? <DropdownMenuItem<SchoolData>>[]
                    : _selectedLga == kNotInSchoolLabel
                    ? [
                  const DropdownMenuItem<SchoolData>(
                    value: kNotInSchool,
                    child: Text(kNotInSchoolLabel),
                  ),
                ]
                    : schoolsInLga(_selectedLga!)
                    .map((school) => DropdownMenuItem<SchoolData>(
                  value: school,
                  child: Text(school.name,
                      overflow: TextOverflow.ellipsis),
                ))
                    .toList(),
                onChanged:
                (_selectedLga == null || _selectedLga == kNotInSchoolLabel)
                    ? null // disabled: nothing to choose
                    : (value) => setState(() => _selectedSchool = value),
              ),

              // Show contact info once a school is selected
              if (_selectedSchool != null) ...[
                const SizedBox(height: 16),
                // Contact name - user types this
                CustomTextField(
                  hintText: notInSchoolSelected
                      ? 'Parent/Guardian Name'
                      : 'Contact Name',
                  controller: contactNameController,
                  isObscure: false,
                  isOptionalLeadingIcon: true,
                  optionalLeadingIcon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                // Contact phone - user types this
                CustomTextField(
                  hintText: notInSchoolSelected
                      ? 'Parent/Guardian Phone Number'
                      : 'Contact Phone Number',
                  controller: contactPhoneController,
                  isObscure: false,
                  isOptionalLeadingIcon: true,
                  optionalLeadingIcon: Icons.phone_outlined,
                ),
              ],

              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : LongCustomButton(
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
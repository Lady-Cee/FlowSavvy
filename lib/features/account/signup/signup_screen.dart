import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/schools_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/is_login_state_provider.dart';
import '../../providers/symptom_log_provider.dart';
import '../../providers/user_profile_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  static const Color _deepViolet = Color(0xFF6D28D9);
  static const Color _violet = Color(0xFF8E5CF7);
  static const Color _teal = Color(0xFF14B8A6);

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
  String? _errorMessage;
  String? _selectedLga;
  SchoolData? _selectedSchool;

  // Shakes the button area when something is wrong
  late final AnimationController _shake;
  // Makes the arrow on the button nudge forward
  late final AnimationController _nudge;

  void _toggleVisibility() => setState(() => _obscureText = !_obscureText);
  void _toggleVisibility1() => setState(() => _obscureText1 = !_obscureText1);

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _nudge = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    contactNameController.dispose();
    contactPhoneController.dispose();
    _shake.dispose();
    _nudge.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOGIC
  // ---------------------------------------------------------------------------

  /// Shows the error inside the form (above the button) and shakes it.
  void _showError(String message) {
    setState(() => _errorMessage = message);
    _shake.forward(from: 0);
  }

  /// How many of the 9 required fields are filled in (for the progress bar).
  int _filledCount() {
    var count = 0;
    if (firstNameController.text.trim().isNotEmpty) count++;
    if (surnameController.text.trim().isNotEmpty) count++;
    if (emailController.text.trim().isNotEmpty) count++;
    if (passwordController.text.isNotEmpty) count++;
    if (confirmPasswordController.text.isNotEmpty) count++;
    if (_selectedLga != null) count++;
    if (_selectedSchool != null) count++;
    if (contactNameController.text.trim().isNotEmpty) count++;
    if (contactPhoneController.text.trim().isNotEmpty) count++;
    return count;
  }

  static const int _totalFields = 9;

  /// 0 (empty) to 4 (strong).
  int _passwordScore(String p) {
    if (p.isEmpty) return 0;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[a-z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    return s;
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

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      _showError('Passwords do not match');
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

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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

      // Sign up failed: show the error and stay on this screen
      if (result != null) {
        if (mounted) _showError(result);
        return;
      }

      // Account created. Log the user in straight away.
      final loginError = await authProvider.login(email, password);

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

      // Lets the browser / phone offer to save the password
      TextInput.finishAutofillContext();

      messenger.showSnackBar(
        SnackBar(
          content: const Text('Welcome! Your account has been created.'),
          backgroundColor: primaryColor,
        ),
      );

      navigator.pushReplacementNamed('/home');
    } catch (e) {
      debugPrint('SIGNUP ERROR: $e');
      if (mounted) {
        _showError('Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  /// Fade + slide in (used on the first items only).
  Widget _entrance(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 110),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 20),
          child: c,
        ),
      ),
      child: child,
    );
  }

  OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: scheme.primary),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: scheme.primary.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: _border(Colors.transparent),
      enabledBorder: _border(Colors.transparent),
      disabledBorder: _border(Colors.transparent),
      focusedBorder: _border(scheme.primary, 1.6),
    );
  }

  /// Modern filled text field with a floating label and a leading icon.
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? formatters,
    Iterable<String>? autofillHints,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction ?? TextInputAction.next,
      inputFormatters: formatters,
      autofillHints: autofillHints,
      enabled: !_isLoading,
      // Rebuild so the progress bar and hints stay up to date
      onChanged: (_) => setState(() => _errorMessage = null),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: _decoration(label: label, icon: icon, suffixIcon: suffixIcon),
    );
  }

  Widget _eyeButton(bool obscure, VoidCallback onTap) {
    final scheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: obscure ? 'Show password' : 'Hide password',
      onPressed: onTap,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          key: ValueKey(obscure),
          color: scheme.primary,
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color accent) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withOpacity(0.14),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildProgress(ColorScheme scheme) {
    final filled = _filledCount();
    final value = filled / _totalFields;
    final percent = (value * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                filled == _totalFields
                    ? Icons.check_circle_rounded
                    : Icons.auto_awesome,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filled == _totalFields
                      ? 'All set. Ready to sign up!'
                      : 'Let\'s set you up',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: value),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            builder: (context, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: scheme.primary.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4-segment strength meter shown under the password field.
  Widget _buildStrengthMeter() {
    final p = passwordController.text;
    if (p.isEmpty) return const SizedBox(width: double.infinity);

    final tooShort = p.length < 6;
    final level = tooShort ? 1 : _passwordScore(p).clamp(1, 4);
    const colors = [
      Color(0xFFEF4444), // weak
      Color(0xFFF97316), // fair
      Color(0xFFFFB020), // good
      Color(0xFF16A34A), // strong
    ];
    const labels = ['Weak', 'Fair', 'Good', 'Strong'];
    final color = colors[level - 1];
    final label = tooShort ? 'Too short' : labels[level - 1];

    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 5,
                decoration: BoxDecoration(
                  color: i < level ? color : color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            if (i < 3) const SizedBox(width: 5),
          ],
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// "Passwords match" / "do not match" hint under the confirm field.
  Widget _buildMatchHint() {
    final confirm = confirmPasswordController.text;
    if (confirm.isEmpty) return const SizedBox(width: double.infinity);

    final matches = confirm == passwordController.text;
    final color = matches ? const Color(0xFF16A34A) : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Row(
        children: [
          Icon(
            matches ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            matches ? 'Passwords match' : 'Passwords do not match',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme scheme) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: _errorMessage == null
          ? const SizedBox(width: double.infinity)
          : Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          decoration: BoxDecoration(
            color: scheme.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: scheme.error.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline_rounded,
                  color: scheme.error, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: scheme.error,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close_rounded,
                    size: 18, color: scheme.error),
                onPressed: () => setState(() => _errorMessage = null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupButton(ColorScheme scheme) {
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [scheme.primary, Color.lerp(scheme.primary, _deepViolet, 0.65)!],
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(_isLoading ? 0.15 : 0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _isLoading ? null : signUpUser,
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.8,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _nudge,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(5 * _nudge.value, 0),
                        child: child,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notInSchoolSelected = isNotInSchool(_selectedSchool);

    return Scaffold(
      body: AutofillGroup(
        child: Column(
          children: [
            // Pinned progress card: stays visible while the form scrolls
            _entrance(0, _buildProgress(scheme)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                children: [

                  // ── About you ──
                  _entrance(
                    1,
                    _sectionHeader(Icons.person_rounded, 'About you', scheme.primary),
                  ),
                  const SizedBox(height: 14),
                  _entrance(
                    2,
                    _field(
                      controller: firstNameController,
                      label: 'First name',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.name,
                      autofillHints: const [AutofillHints.givenName],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: surnameController,
                    label: 'Surname',
                    icon: Icons.badge_outlined,
                    keyboardType: TextInputType.name,
                    autofillHints: const [AutofillHints.familyName],
                  ),

                  // ── Account ──
                  const SizedBox(height: 26),
                  _sectionHeader(Icons.lock_rounded, 'Your account', _violet),
                  const SizedBox(height: 14),
                  _field(
                    controller: emailController,
                    label: 'Email address',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscure: _obscureText,
                    autofillHints: const [AutofillHints.newPassword],
                    suffixIcon: _eyeButton(_obscureText, _toggleVisibility),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    alignment: Alignment.topCenter,
                    child: _buildStrengthMeter(),
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: confirmPasswordController,
                    label: 'Confirm password',
                    icon: Icons.verified_user_outlined,
                    obscure: _obscureText1,
                    autofillHints: const [AutofillHints.newPassword],
                    suffixIcon: _eyeButton(_obscureText1, _toggleVisibility1),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    alignment: Alignment.topCenter,
                    child: _buildMatchHint(),
                  ),

                  // ── School & contact ──
                  const SizedBox(height: 26),
                  _sectionHeader(Icons.school_rounded, 'School & contact', _teal),
                  const SizedBox(height: 14),

                  // LGA dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedLga,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    borderRadius: BorderRadius.circular(16),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: scheme.primary),
                    decoration:
                    _decoration(label: 'Select LGA', icon: Icons.location_on),
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
                    onChanged: _isLoading
                        ? null
                        : (value) => setState(() {
                      _selectedLga = value;
                      _errorMessage = null;
                      // Not in school -> school is filled in automatically; otherwise reset
                      _selectedSchool =
                      value == kNotInSchoolLabel ? kNotInSchool : null;
                    }),
                  ),
                  const SizedBox(height: 14),

                  // School dropdown (only schools in the chosen LGA)
                  DropdownButtonFormField<SchoolData>(
                    key: ValueKey(_selectedLga), // clean reset when LGA changes
                    value: _selectedSchool,
                    isExpanded: true,
                    menuMaxHeight: 350,
                    borderRadius: BorderRadius.circular(16),
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: scheme.primary),
                    decoration: _decoration(
                      label: _selectedLga == null
                          ? 'Select LGA first'
                          : 'Select school',
                      icon: Icons.school,
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
                    onChanged: (_isLoading ||
                        _selectedLga == null ||
                        _selectedLga == kNotInSchoolLabel)
                        ? null // disabled: nothing to choose
                        : (value) => setState(() {
                      _selectedSchool = value;
                      _errorMessage = null;
                    }),
                  ),

                  // Contact info appears once a school is selected
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    alignment: Alignment.topCenter,
                    child: _selectedSchool == null
                        ? const SizedBox(width: double.infinity)
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        if (notInSchoolSelected)
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 4, bottom: 12),
                            child: Text(
                              'Please add a parent or guardian we can contact.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: scheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ),
                        // Contact name - user types this
                        _field(
                          controller: contactNameController,
                          label: notInSchoolSelected
                              ? 'Parent/Guardian name'
                              : 'Contact name',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 14),
                        // Contact phone - user types this
                        _field(
                          controller: contactPhoneController,
                          label: notInSchoolSelected
                              ? 'Parent/Guardian phone number'
                              : 'Contact phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          formatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+ ]')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Error banner + button (shake when something is wrong)
                  AnimatedBuilder(
                    animation: _shake,
                    builder: (context, child) {
                      final dx = math.sin(_shake.value * math.pi * 6) *
                          10 *
                          (1 - _shake.value);
                      return Transform.translate(offset: Offset(dx, 0), child: child);
                    },
                    child: Column(
                      children: [
                        _buildErrorBanner(scheme),
                        _buildSignupButton(scheme),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Switch back to login
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: scheme.onSurface.withOpacity(0.15)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Already a member?',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: scheme.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: scheme.onSurface.withOpacity(0.15)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => Provider.of<IsLoginStateProvider>(context,
                        listen: false)
                        .setLogin(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      foregroundColor: scheme.primary,
                      side: BorderSide(
                          color: scheme.primary.withOpacity(0.45), width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.login_rounded, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Log in instead',
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
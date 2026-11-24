import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../providers/is_login_state_provider.dart';
import '../../providers/symptom_log_provider.dart';
import '../../providers/user_profile_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  static const Color _deepViolet = Color(0xFF6D28D9);

  // Login controllers
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
  TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Shakes the form when a login fails
  late final AnimationController _shake;
  // Makes the arrow on the login button nudge forward
  late final AnimationController _nudge;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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

    _loadLoginPreferences();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _shake.dispose();
    _nudge.dispose();
    super.dispose();
  }

  Future<void> _loadLoginPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

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
    if (!mounted) return;

    final remember = prefs.getBool('rememberMe') ?? false;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (remember && authProvider.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// Shows the error inside the form (and shakes it) instead of a snackbar
  /// that can end up hidden behind the keyboard.
  void _showError(String message) {
    setState(() => _errorMessage = message);
    _shake.forward(from: 0);
  }

  Future<void> loginUser() async {
    if (_isLoading) return;

    // Grab everything that needs context BEFORE any await
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider =
    Provider.of<UserProfileProvider>(context, listen: false);
    final logProvider =
    Provider.of<SymptomLogProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError('Please enter both email and password.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final error = await authProvider.login(email, password);

      if (error != null) {
        if (mounted) _showError(error);
        return;
      }

      // 🔹 Load the correct user's profile and logs (only after a good login)
      await profileProvider.loadUserProfile();
      await logProvider.fetchLogs();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', authProvider.rememberMe);
      if (authProvider.rememberMe) {
        await prefs.setString('rememberedEmail', email);
      } else {
        await prefs.remove('rememberedEmail');
      }

      // Lets the browser / phone offer to save the password
      TextInput.finishAutofillContext();

      navigator.pushReplacementNamed('/home');
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
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

  /// Fade + slide in. Later items take slightly longer, so the form builds up.
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

  /// Modern filled text field with a floating label and a leading icon.
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    Iterable<String>? autofillHints,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      autofillHints: autofillHints,
      enabled: !_isLoading,
      onChanged: (_) {
        if (_errorMessage != null) setState(() => _errorMessage = null);
      },
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: scheme.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: scheme.primary.withOpacity(0.05),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        disabledBorder: border(Colors.transparent),
        focusedBorder: border(scheme.primary, 1.6),
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
        padding: const EdgeInsets.only(top: 14),
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

  Widget _buildLoginButton(ColorScheme scheme) {
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
            onTap: _isLoading ? null : loginUser,
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
                      'Login',
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
    final authProvider = Provider.of<AuthProvider>(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: AutofillGroup(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 4, bottom: 24),
          children: [
            // Form (shakes when a login fails)
            AnimatedBuilder(
              animation: _shake,
              builder: (context, child) {
                final dx =
                    math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value);
                return Transform.translate(offset: Offset(dx, 0), child: child);
              },
              child: Column(
                children: [
                  _entrance(
                    0,
                    _field(
                      controller: _loginEmailController,
                      label: 'Email address',
                      icon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _entrance(
                    1,
                    _field(
                      controller: _loginPasswordController,
                      label: 'Password',
                      icon: Icons.lock_rounded,
                      obscure: _obscureText,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => loginUser(),
                      autofillHints: const [AutofillHints.password],
                      suffixIcon: IconButton(
                        tooltip: _obscureText ? 'Show password' : 'Hide password',
                        onPressed: _toggleVisibility,
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            key: ValueKey(_obscureText),
                            color: scheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildErrorBanner(scheme),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Remember me + forgot password
            _entrance(
              2,
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () =>
                        authProvider.toggleRememberMe(!authProvider.rememberMe),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: authProvider.rememberMe,
                            activeColor: scheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            onChanged: (val) {
                              authProvider.toggleRememberMe(val ?? false);
                            },
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.pushNamed(context, '/forgotPassword');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 8),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Login button
            _entrance(3, _buildLoginButton(scheme)),

            const SizedBox(height: 22),

            // "or" divider
            _entrance(
              4,
              Row(
                children: [
                  Expanded(
                    child: Divider(color: scheme.onSurface.withOpacity(0.15)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'New here?',
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
            ),

            const SizedBox(height: 14),

            // Switch to sign up
            _entrance(
              5,
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  Provider.of<IsLoginStateProvider>(context,
                      listen: false)
                      .setSignup();
                },
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
                    Icon(Icons.person_add_alt_1_rounded, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
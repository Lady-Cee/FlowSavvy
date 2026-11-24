import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/is_login_state_provider.dart';
import '../login/login_signup_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  static const Color _deepViolet = Color(0xFF6D28D9);
  static const int _cooldownSeconds = 30;

  final emailController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  /// The address the reset link was sent to. When set, the success view shows.
  String? _sentTo;

  int _cooldown = 0;
  Timer? _timer;

  // Floating icon, background blobs and the nudging arrow
  late final AnimationController _float;
  // Shakes the form when something is wrong
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    _float.dispose();
    _shake.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOGIC
  // ---------------------------------------------------------------------------

  void _showError(String message) {
    setState(() => _errorMessage = message);
    _shake.forward(from: 0);
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = _cooldownSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldown--;
        if (_cooldown <= 0) t.cancel();
      });
    });
  }

  /// Sends the reset email. Also used by "Resend email".
  Future<void> resetPassword({bool resend = false}) async {
    if (_isLoading) return;

    final email = resend ? (_sentTo ?? '') : emailController.text.trim();

    // Simple validation
    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final message = await authProvider.resetPassword(email);
      if (!mounted) return;

      if (message == null) {
        // Success: switch to the "check your inbox" view
        setState(() => _sentTo = email);
        _startCooldown();
      } else {
        _showError(message);
      }
    } catch (e) {
      debugPrint('RESET PASSWORD ERROR: $e');
      if (mounted) _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Back to the login screen.
  void _goToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.read<IsLoginStateProvider>().setLogin();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginSignUpScreen()),
      );
    }
  }

  void _useDifferentEmail() {
    _timer?.cancel();
    setState(() {
      _sentTo = null;
      _cooldown = 0;
      _errorMessage = null;
    });
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  Widget _blob(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }

  Widget _buildHeader(bool sent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating icon
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, -6 * _float.value),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                      Colors.white.withOpacity(0.12 + 0.12 * _float.value),
                      blurRadius: 14 + 12 * _float.value,
                      spreadRadius: 1 + 2 * _float.value,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                sent ? Icons.mark_email_read_rounded : Icons.lock_reset_rounded,
                key: ValueKey(sent),
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Column(
              key: ValueKey(sent),
              children: [
                Text(
                  sent ? 'Email sent! 📬' : 'Forgot password? 🔑',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sent
                      ? 'Follow the link we sent you to set a new password'
                      : 'No worries. We\'ll email you a link to reset it',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(ColorScheme scheme) {
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: emailController,
      enabled: !_isLoading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.email],
      onSubmitted: (_) => resetPassword(),
      onChanged: (_) {
        if (_errorMessage != null) setState(() => _errorMessage = null);
      },
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Email address',
        prefixIcon:
        Icon(Icons.alternate_email_rounded, color: scheme.primary),
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

  Widget _gradientButton({
    required ColorScheme scheme,
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool loading = false,
  }) {
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
            color: scheme.primary.withOpacity(loading ? 0.15 : 0.4),
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
            onTap: loading ? null : onTap,
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: Center(
                child: loading
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
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedBuilder(
                      animation: _float,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(5 * _float.value, 0),
                        child: child,
                      ),
                      child: Icon(icon, color: Colors.white, size: 22),
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

  /// "Remembered it?" divider + back to login.
  Widget _buildBackToLogin(ColorScheme scheme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: scheme.onSurface.withOpacity(0.15)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Remembered it?',
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
          onPressed: _isLoading ? null : _goToLogin,
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
                'Back to login',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// The email form.
  Widget _buildForm(ColorScheme scheme) {
    return Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter the email you signed up with and we\'ll send you a reset link.',
          style: TextStyle(
            fontSize: 13.5,
            height: 1.4,
            color: scheme.onSurface.withOpacity(0.65),
          ),
        ),
        const SizedBox(height: 18),
        AnimatedBuilder(
          animation: _shake,
          builder: (context, child) {
            final dx =
                math.sin(_shake.value * math.pi * 6) * 10 * (1 - _shake.value);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Column(
            children: [
              _buildEmailField(scheme),
              _buildErrorBanner(scheme),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _gradientButton(
          scheme: scheme,
          label: 'Send reset link',
          icon: Icons.send_rounded,
          onTap: () => resetPassword(),
          loading: _isLoading,
        ),
        const SizedBox(height: 26),
        _buildBackToLogin(scheme),
      ],
    );
  }

  /// Shown after the email has been sent.
  Widget _buildSuccess(ColorScheme scheme) {
    final canResend = _cooldown <= 0 && !_isLoading;

    return Column(
      key: const ValueKey('success'),
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: scheme.onSurface.withOpacity(0.75),
              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
            ),
            children: [
              const TextSpan(text: 'We sent a password reset link to\n'),
              TextSpan(
                text: _sentTo ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Tip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.primary.withOpacity(0.15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: scheme.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Can\'t see it? Check your spam or junk folder, and make sure the email address is spelled correctly.',
                  style: TextStyle(fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),

        _buildErrorBanner(scheme),
        const SizedBox(height: 20),

        _gradientButton(
          scheme: scheme,
          label: 'Back to login',
          icon: Icons.arrow_forward_rounded,
          onTap: _goToLogin,
        ),
        const SizedBox(height: 10),

        // Resend with a cooldown
        TextButton(
          onPressed: canResend ? () => resetPassword(resend: true) : null,
          child: _isLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          )
              : Text(
            _cooldown > 0
                ? 'Resend email in ${_cooldown}s'
                : 'Resend email',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _useDifferentEmail,
          child: Text(
            'Use a different email',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final sent = _sentTo != null;
    final gradientEnd = Color.lerp(scheme.primary, _deepViolet, 0.65)!;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, gradientEnd],
            ),
          ),
          child: Stack(
            children: [
              // Floating background blobs
              AnimatedBuilder(
                animation: _float,
                builder: (context, _) => Stack(
                  children: [
                    Positioned(
                      top: -50 + 12 * _float.value,
                      right: -40,
                      child: _blob(190, 0.10),
                    ),
                    Positioned(
                      top: 90 - 10 * _float.value,
                      left: -60,
                      child: _blob(150, 0.07),
                    ),
                  ],
                ),
              ),

              SafeArea(
                bottom: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        // Back button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                tooltip: 'Back',
                                icon: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 18),
                                onPressed: _goToLogin,
                              ),
                            ),
                          ),
                        ),

                        // Header collapses while the keyboard is open
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                          child: keyboardOpen
                              ? const SizedBox(width: double.infinity, height: 4)
                              : _buildHeader(sent),
                        ),

                        // White sheet
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOutCubic,
                            builder: (context, v, child) => Opacity(
                              opacity: v.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(0, (1 - v) * 60),
                                child: child,
                              ),
                            ),
                            child: Container(
                              width: double.infinity,
                              padding:
                              const EdgeInsets.fromLTRB(24, 26, 24, 0),
                              decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(34),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 24,
                                    offset: const Offset(0, -6),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.only(bottom: 24),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: sent
                                      ? _buildSuccess(scheme)
                                      : _buildForm(scheme),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
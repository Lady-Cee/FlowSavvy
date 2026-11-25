import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../signup/signup_screen.dart';
import '../../providers/is_login_state_provider.dart';

class LoginSignUpScreen extends StatefulWidget {
  const LoginSignUpScreen({super.key});

  @override
  State<LoginSignUpScreen> createState() => _LoginSignUpScreenState();
}

class _LoginSignUpScreenState extends State<LoginSignUpScreen>
    with SingleTickerProviderStateMixin {
  /// Brand name shown in the header. Change it here if needed.
  static const String _appName = 'PeriodReal';

  static const Color _deepViolet = Color(0xFF6D28D9);

  // Drives the floating logo and the soft background blobs
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
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

  /// Logo, app name and a greeting that changes with login / sign up.
  Widget _buildHeader(bool isLogin) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating logo
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
                      color: Colors.white.withOpacity(0.12 + 0.12 * _float.value),
                      blurRadius: 14 + 12 * _float.value,
                      spreadRadius: 1 + 2 * _float.value,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
            child: const Icon(Icons.water_drop_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: AnimatedSwitcher(
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
                key: ValueKey(isLogin),
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _appName.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLogin ? 'Welcome back 👋' : 'Create your account 🌸',
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
                    isLogin
                        ? 'Log in to track your cycle, access menstrual health resources, request pads or manage your organisation\'s support activities.'
                        : 'Join PeriodReal to access menstrual health resources, track your cycle, request pads, connect with experts or register your organisation to support girls and women with menstrual health services.',
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
          ),
        ],
      ),
    );
  }

  /// Sliding pill switch between Login and Sign Up.
  Widget _buildSwitch(bool isLogin, ColorScheme scheme) {
    final pillGradient = LinearGradient(
      colors: [scheme.primary, Color.lerp(scheme.primary, _deepViolet, 0.65)!],
    );

    Widget label(String text, bool selected, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: selected
                    ? Colors.white
                    : scheme.onSurface.withOpacity(0.6),
              ),
              child: Text(text),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          // Sliding highlight
          AnimatedAlign(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: pillGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              label(
                'Login',
                isLogin,
                    () => context.read<IsLoginStateProvider>().setLogin(),
              ),
              label(
                'Sign Up',
                !isLogin,
                    () => context.read<IsLoginStateProvider>().setSignup(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isLogin = context.watch<IsLoginStateProvider>().isLogin;
    final scheme = Theme.of(context).colorScheme;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

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
                        // Header collapses while the keyboard is open, so the
                        // form gets all the room it needs.
                        AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          alignment: Alignment.topCenter,
                          child: keyboardOpen
                              ? const SizedBox(width: double.infinity, height: 8)
                              : _buildHeader(isLogin),
                        ),

                        // White sheet holding the switch and the forms
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
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                              child: Column(
                                children: [
                                  _buildSwitch(isLogin, scheme),
                                  const SizedBox(height: 16),

                                  // The login and sign up screens have their
                                  // own Scaffold; make it transparent so the
                                  // sheet colour shows through.
                                  Expanded(
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        scaffoldBackgroundColor:
                                        Colors.transparent,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration:
                                        const Duration(milliseconds: 300),
                                        child: KeyedSubtree(
                                          key: ValueKey(isLogin),
                                          child: isLogin
                                              ? const LoginScreen()
                                              : const SignupScreen(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
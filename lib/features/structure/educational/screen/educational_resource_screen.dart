import 'package:flow_savvy/features/structure/educational/screen/faq_screen.dart';
import 'package:flow_savvy/features/structure/educational/screen/roles_screen.dart';
import 'package:flow_savvy/features/structure/gemini/gemini_search_screen.dart';
import 'package:flutter/material.dart';

import 'essential_info_screen.dart';
import 'hygiene__tips_screen.dart';
import 'myths_screen.dart';

/// One learning topic shown as a colourful tile.
class _Lesson {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color colorA; // gradient start
  final Color colorB; // gradient end
  final WidgetBuilder screen;

  const _Lesson({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colorA,
    required this.colorB,
    required this.screen,
  });
}

class EducationalResourceScreen extends StatefulWidget {
  @override
  _EducationalResourceScreenState createState() =>
      _EducationalResourceScreenState();
}

class _EducationalResourceScreenState extends State<EducationalResourceScreen>
    with SingleTickerProviderStateMixin {
  // Drives the floating icons and the glow around the PeriodBot avatar
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // DATA
  // ---------------------------------------------------------------------------

  final _myths = _Lesson(
    title: 'Myths vs Facts',
    subtitle: 'Separate fact from fiction',
    icon: Icons.question_answer_rounded,
    colorA: const Color(0xFFFF4D8D),
    colorB: const Color(0xFFFF8A5B),
    screen: (_) => MythsScreen(),
  );

  final _essential = _Lesson(
    title: 'Essential Information',
    subtitle: 'The basics, explained',
    icon: Icons.info_rounded,
    colorA: const Color(0xFF3B82F6),
    colorB: const Color(0xFF06B6D4),
    screen: (_) => EssentialInfoScreen(),
  );

  final _hygiene = _Lesson(
    title: 'Hygiene Tips',
    subtitle: 'Stay fresh and healthy',
    icon: Icons.clean_hands_rounded,
    colorA: const Color(0xFF14B8A6),
    colorB: const Color(0xFF10B981),
    screen: (_) => HygieneTipsScreen(),
  );

  final _roles = _Lesson(
    title: 'Our Roles',
    subtitle: 'Everyone has a part to play',
    icon: Icons.groups_rounded,
    colorA: const Color(0xFF8E5CF7),
    colorB: const Color(0xFFD946EF),
    screen: (_) => RolesScreen(),
  );

  final _faqs = _Lesson(
    title: 'FAQs',
    subtitle: 'Quick answers to common questions',
    icon: Icons.help_rounded,
    colorA: const Color(0xFFFFB020),
    colorB: const Color(0xFFFF6B3D),
    screen: (_) => FaqScreen(),
  );

  void _open(WidgetBuilder builder) {
    Navigator.push(context, MaterialPageRoute(builder: builder));
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  /// Fade + slide in. Later items take slightly longer, so the screen builds up.
  Widget _entrance(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 120),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 24),
          child: c,
        ),
      ),
      child: child,
    );
  }

  /// PeriodBot hero card: dark gradient, glowing bot avatar, and a search
  /// bar look-alike. Tapping anywhere on it opens PeriodBot.
  Widget _buildBotCard() {
    return _Pressable(
      onTap: () => _open((_) => GeminiSearchScreen()),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E1065), Color(0xFF6D28D9), Color(0xFFDB2777)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6D28D9).withOpacity(0.4),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Floating sparkles
            Positioned(
              right: 4,
              top: 0,
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, _) => Transform.translate(
                  offset: Offset(0, -5 * _float.value),
                  child: Icon(Icons.auto_awesome,
                      size: 26, color: Colors.white.withOpacity(0.65)),
                ),
              ),
            ),
            Positioned(
              right: 44,
              top: 34,
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, _) => Transform.translate(
                  offset: Offset(0, 4 * _float.value),
                  child: Icon(Icons.auto_awesome,
                      size: 14, color: Colors.white.withOpacity(0.45)),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Bot avatar with a breathing glow
                    AnimatedBuilder(
                      animation: _float,
                      builder: (context, child) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white
                                  .withOpacity(0.15 + 0.15 * _float.value),
                              blurRadius: 10 + 14 * _float.value,
                              spreadRadius: 1 + 3 * _float.value,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                      child: const Icon(Icons.smart_toy_rounded,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ask PeriodBot',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Instant, friendly answers',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Fake search bar
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ask me anything about periods...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward_rounded,
                            size: 20, color: Color(0xFF6D28D9)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'AI assistant. Not a substitute for medical advice.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Square-ish gradient tile with a big floating icon behind the text.
  Widget _lessonTile(_Lesson l, double height) {
    return _Pressable(
      onTap: () => _open(l.screen),
      child: Container(
        height: height,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [l.colorA, l.colorB],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: l.colorA.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Big decorative icon that gently floats
            Positioned(
              right: -16,
              bottom: -16,
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, -7 * _float.value),
                  child: child,
                ),
                child: Transform.rotate(
                  angle: -0.28,
                  child: Icon(l.icon,
                      size: 104, color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(l.icon, size: 22, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    l.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      height: 1.25,
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

  /// Full-width horizontal tile (used for FAQs).
  Widget _wideTile(_Lesson l) {
    return _Pressable(
      onTap: () => _open(l.screen),
      child: Container(
        height: 92,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [l.colorA, l.colorB],
          ),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: l.colorA.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 40,
              bottom: -22,
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, -6 * _float.value),
                  child: child,
                ),
                child: Transform.rotate(
                  angle: 0.25,
                  child: Icon(l.icon,
                      size: 96, color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(l.icon, size: 26, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.92),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 24),
                ],
              ),
            ),
          ],
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

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Educational Resources',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Intro
                _entrance(
                  0,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Build confidence through knowledge 🌱',
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Challenge myths, learn key facts, practice healthy habits and understand our collective roles.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: scheme.onSurface.withOpacity(0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                _entrance(1, _buildBotCard()),
                const SizedBox(height: 26),

                _entrance(
                  2,
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 5,
                          height: 20,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Explore topics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Staggered two-column layout: tall + short, short + tall
                _entrance(
                  3,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _lessonTile(_myths, 200),
                            const SizedBox(height: 12),
                            _lessonTile(_hygiene, 160),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: [
                            _lessonTile(_essential, 160),
                            const SizedBox(height: 12),
                            _lessonTile(_roles, 200),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _entrance(4, _wideTile(_faqs)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gives any child a small "press in" effect when tapped.
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
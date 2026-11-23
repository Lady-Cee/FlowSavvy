import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/period_log_provider.dart';
import '../../../providers/symptom_log_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_text_styles.dart';
import '../../../utils/get_date_formatter.dart';
import '../../../widgets/long_custom_button.dart';

// ── Holds all resolved cycle data in one place ──
class _CycleData {
  final DateTime lastPeriodDate;
  final int cycleLength;
  final int cycleDay;
  final int daysUntilNextPeriod;
  final bool periodExpectedToday;
  final DateTime nextPeriodDate;
  final DateTime ovulation;
  final DateTime fertileStart;
  final DateTime fertileEnd;
  final int fertileStartDay;
  final int fertileEndDay;
  final String phase;

  _CycleData({
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.cycleDay,
    required this.daysUntilNextPeriod,
    required this.periodExpectedToday,
    required this.nextPeriodDate,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
    required this.fertileStartDay,
    required this.fertileEndDay,
    required this.phase,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AppStrings appStrings = AppStrings();

  late AnimationController _controller;

  // Accent colours used by the stat tiles
  static const Color _violet = Color(0xFF8E5CF7);
  static const Color _amber = Color(0xFFFFB020);
  static const Color _teal = Color(0xFF14B8A6);

  @override
  void initState() {
    super.initState();

    // Drives the soft "breathing" glow around the cycle ring
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final periodProvider = context.read<PeriodLogProvider>();
      final profileProvider = context.read<UserProfileProvider>();
      periodProvider.loadLogs();
      final profile = profileProvider.userProfile;
      if (profile != null) {
        periodProvider.setDefaultCycleLength(profile.cycleLength);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider =
    Provider.of<UserProfileProvider>(context, listen: false);
    final symptomProvider =
    Provider.of<SymptomLogProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    await authProvider.logout();
    profileProvider.resetProfile();
    symptomProvider.resetLogs();
    navigator.pushReplacementNamed('loginSignUpScreen');
  }

  // ---------------------------------------------------------------------------
  // DATE HELPERS (calendar dates only, so time of day never skews the counts)
  // ---------------------------------------------------------------------------

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _addDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  int _daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  String _plural(int n) => n == 1 ? 'day' : 'days';

  String _inDaysLabel(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    if (days > 1) return 'In $days days';
    if (days == -1) return 'Yesterday';
    return '${days.abs()} days ago';
  }

  /// ── Single source of truth for all cycle calculations ──
  _CycleData _resolveCycleData({
    required DateTime? logDate,
    required DateTime profileDate,
    required int profileCycleLength,
  }) {
    final today = _dateOnly(DateTime.now());
    final profileStart = _dateOnly(profileDate);
    final logStart = logDate == null ? null : _dateOnly(logDate);

    // RULE: If a formal period log exists and is newer, it takes precedence as
    // the latest period. Otherwise fall back to the profile's base date.
    final lastPeriodDate = (logStart != null && logStart.isAfter(profileStart))
        ? logStart
        : profileStart;

    final cycleLength = profileCycleLength <= 0 ? 28 : profileCycleLength;

    final daysSince = _daysBetween(lastPeriodDate, today);

    // Assume cycles have repeated since the last known period, so the
    // predictions always point at the current or next cycle.
    final cyclesElapsed = daysSince <= 0 ? 0 : daysSince ~/ cycleLength;
    final currentCycleStart =
    _addDays(lastPeriodDate, cyclesElapsed * cycleLength);

    final nextPeriodDate = _addDays(currentCycleStart, cycleLength);
    final cycleDay = math.max(_daysBetween(currentCycleStart, today) + 1, 1);
    final daysUntilNextPeriod = _daysBetween(today, nextPeriodDate);

    // On the day a predicted period begins, say so instead of counting
    // down a whole new cycle.
    final periodExpectedToday = cyclesElapsed > 0 && cycleDay == 1;

    // Ovulation happens about 14 days BEFORE the next period. Very short
    // cycles are clamped so it never lands before day 2.
    final ovulationOffset = cycleLength > 15 ? cycleLength - 14 : 1;
    final ovulation = _addDays(currentCycleStart, ovulationOffset);
    final ovulationDay = ovulationOffset + 1; // day 1 = first day of period

    // Fertile window: the 5 days before ovulation, plus ovulation day and the
    // day after (sperm can survive up to ~5 days, the egg about a day).
    final fertileStart = _addDays(ovulation, -5);
    final fertileEnd = _addDays(ovulation, 1);
    final fertileStartDay = math.max(ovulationDay - 5, 1);
    final fertileEndDay = math.min(ovulationDay + 1, cycleLength);

    // Phase is worked out from the ovulation day, so it adapts to short and
    // long cycles instead of using fixed day numbers.
    String phase;
    if (cycleDay <= 5 && cycleDay < ovulationDay - 1) {
      phase = 'Menstrual';
    } else if (cycleDay >= ovulationDay - 1 && cycleDay <= ovulationDay + 1) {
      phase = 'Ovulation';
    } else if (cycleDay < ovulationDay - 1) {
      phase = 'Follicular';
    } else {
      phase = 'Luteal';
    }

    return _CycleData(
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
      cycleDay: cycleDay,
      daysUntilNextPeriod: daysUntilNextPeriod,
      periodExpectedToday: periodExpectedToday,
      nextPeriodDate: nextPeriodDate,
      ovulation: ovulation,
      fertileStart: fertileStart,
      fertileEnd: fertileEnd,
      fertileStartDay: fertileStartDay,
      fertileEndDay: fertileEndDay,
      phase: phase,
    );
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _fertileStatus(_CycleData c, DateTime today) {
    if (today.isBefore(c.fertileStart)) {
      return 'Starts ${_inDaysLabel(_daysBetween(today, c.fertileStart)).toLowerCase()}';
    }
    if (today.isAfter(c.fertileEnd)) return 'Ended';
    return 'Open now';
  }

  String _phaseTip(String phase) {
    switch (phase) {
      case 'Menstrual':
        return 'Rest when you need to, stay hydrated, and try gentle movement or warmth to ease cramps.';
      case 'Follicular':
        return 'Energy often rises in this phase. A good time to try new activities and plan busy days.';
      case 'Ovulation':
        return 'You may feel more energetic and social. Fertility is at its highest around now.';
      default:
        return 'Mood and energy can dip before your period. Prioritise sleep, balanced meals and self-care.';
    }
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  /// Fade + slide in. Later items take slightly longer, so the screen builds up.
  Widget _entrance(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + index * 140),
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

  Widget _heroChip(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  /// Big gradient card with the segmented cycle ring.
  Widget _buildHeroCard(
      _CycleData cycle,
      double ringSize,
      bool showPhase,
      ColorScheme scheme,
      ) {
    final gradientEnd =
    Color.lerp(scheme.primary, const Color(0xFF6D28D9), 0.65)!;

    final periodText = cycle.periodExpectedToday
        ? 'Period expected today'
        : 'Period in ${cycle.daysUntilNextPeriod} ${_plural(cycle.daysUntilNextPeriod)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              showPhase
                  ? _heroChip('${cycle.phase} phase',
                  icon: Icons.auto_awesome)
                  : _heroChip('Cycle day ${cycle.cycleDay}',
                  icon: Icons.favorite_rounded),
              const Spacer(),
              _heroChip('${cycle.cycleLength}-day cycle'),
            ],
          ),
          const SizedBox(height: 6),

          // Segmented ring
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final pulse = _controller.value;
                return TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  builder: (context, reveal, __) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // soft breathing glow behind the number
                        Container(
                          width: ringSize * 0.62,
                          height: ringSize * 0.62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white
                                    .withOpacity(0.10 + 0.06 * pulse),
                                blurRadius: 40 + 20 * pulse,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        CustomPaint(
                          size: Size(ringSize, ringSize),
                          painter: CycleRingPainter(
                            cycleLength: cycle.cycleLength,
                            currentDay: cycle.cycleDay,
                            fertileStartDay:
                            showPhase ? cycle.fertileStartDay : null,
                            fertileEndDay:
                            showPhase ? cycle.fertileEndDay : null,
                            reveal: reveal,
                            pulse: pulse,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'DAY',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${cycle.cycleDay}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ringSize * 0.25,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            Text(
                              'of ${cycle.cycleLength}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            children: [
              _legendDot(Colors.white, 'Days passed'),
              if (showPhase)
                _legendDot(const Color(0xFFFFE08A), 'Fertile window'),
            ],
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.water_drop_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    periodText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Last period started ${DateFormat('MMM d, yyyy').format(cycle.lastPeriodDate)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Small info tile with a coloured icon.
  Widget _statTile({
    required IconData icon,
    required Color accent,
    required String label,
    required String value,
    required String detail,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileRow(Widget left, Widget right) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _buildTipCard(String phase, ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip for your $phase phase',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _phaseTip(phase),
                  style: const TextStyle(fontSize: 13.5, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title,
        required IconData icon,
        required String routeName}) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _violet.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _violet.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 24, color: _violet),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title,
                    style: AppTextStyles.mediumTextSemiBold(context)),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: scheme.onSurface.withOpacity(0.4)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHydrationBanner() {
    const blue = Color(0xFF3B82F6);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: blue.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.water_drop_rounded, color: blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              appStrings.homeStayHydratedText,
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
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
    final profileProvider = context.watch<UserProfileProvider>();
    final periodProvider = context.watch<PeriodLogProvider>();
    final scheme = Theme.of(context).colorScheme;

    final profile = profileProvider.userProfile;
    final bool hasProfile = profile != null;
    final username = profile?.name.split(' ').first.toLowerCase() ?? 'user';

    if (profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context
            .read<PeriodLogProvider>()
            .setDefaultCycleLength(profile.cycleLength);
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: !hasProfile
            ? Text(appStrings.flowSavvyDashBoardText1,
            style: AppTextStyles.largeTextSemiBold(context))
            : Text(
          'Welcome, ${capitalizeFirstLetter(username)} 👋',
          style:
          const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
        ),
        centerTitle: !hasProfile,
        actions: [
          !hasProfile
              ? IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'logout',
          )
              : Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: scheme.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => logout(context),
                icon: Icon(Icons.logout_rounded, color: scheme.primary),
                tooltip: 'Logout',
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // ── No profile yet ──
          if (!hasProfile) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_add_alt_1_rounded,
                          size: 44, color: scheme.primary),
                    ),
                    const SizedBox(height: 20),
                    Text(appStrings.defaultText,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: constraints.maxWidth * 0.6,
                      child: LongCustomButton(
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                        title: 'Go to Profile',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── All cycle data resolved in one call ──
          final cycle = _resolveCycleData(
            logDate: periodProvider.latestLog?.startDate,
            profileDate: profile.lastPeriodDate,
            // Use the provider's dynamic cycle length, not the static profile one
            profileCycleLength: periodProvider.getEffectiveCycleLength(),
          );

          final today = _dateOnly(DateTime.now());
          final showPhase = profile.age >= 23;
          // Ring size: raise or lower the 0.52 / 200 to resize the whole card
          final ringSize = math.min(constraints.maxWidth * 0.52, 200.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _entrance(
                      0,
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 14),
                        child: Text(getFormattedDate(),
                            style: AppTextStyles.semiBold(context)),
                      ),
                    ),

                    _entrance(
                      1,
                      _buildHeroCard(cycle, ringSize, showPhase, scheme),
                    ),
                    const SizedBox(height: 16),

                    _entrance(
                      2,
                      _tileRow(
                        _statTile(
                          icon: Icons.calendar_today_rounded,
                          accent: scheme.primary,
                          label: 'Next period',
                          value:
                          DateFormat('MMM d').format(cycle.nextPeriodDate),
                          detail: _inDaysLabel(cycle.daysUntilNextPeriod),
                        ),
                        _statTile(
                          icon: Icons.favorite_rounded,
                          accent: _violet,
                          label: 'Ovulation',
                          value: DateFormat('MMM d').format(cycle.ovulation),
                          detail: _inDaysLabel(
                              _daysBetween(today, cycle.ovulation)),
                        ),
                      ),
                    ),

                    if (showPhase) ...[
                      const SizedBox(height: 12),
                      _entrance(
                        3,
                        _tileRow(
                          _statTile(
                            icon: Icons.bubble_chart_rounded,
                            accent: _teal,
                            label: 'Current phase',
                            value: cycle.phase,
                            detail: 'Day ${cycle.cycleDay}',
                          ),
                          _statTile(
                            icon: Icons.spa_rounded,
                            accent: _amber,
                            label: 'Fertile window',
                            value:
                            '${DateFormat('MMM d').format(cycle.fertileStart)} - ${DateFormat('MMM d').format(cycle.fertileEnd)}',
                            detail: _fertileStatus(cycle, today),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _entrance(4, _buildTipCard(cycle.phase, scheme)),
                    ],

                    if (profile.age >= 40) ...[
                      const SizedBox(height: 16),
                      _entrance(
                        5,
                        _buildFeatureCard(
                          context,
                          title: 'Menopause Tips',
                          icon: Icons.female,
                          routeName: '/menopause',
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                    _entrance(6, _buildHydrationBanner()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Ring made of one small segment per cycle day.
/// Past days are filled, today glows, future days are faded, and the fertile
/// window (when shown) is tinted amber.
class CycleRingPainter extends CustomPainter {
  final int cycleLength;
  final int currentDay;
  final int? fertileStartDay;
  final int? fertileEndDay;
  final double reveal; // 0..1 intro animation
  final double pulse; // 0..1 breathing glow

  static const Color _fertileColor = Color(0xFFFFE08A);

  CycleRingPainter({
    required this.cycleLength,
    required this.currentDay,
    required this.fertileStartDay,
    required this.fertileEndDay,
    required this.reveal,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cycleLength <= 0) return;

    final strokeWidth = size.width * 0.05;
    final radius = size.width / 2 - strokeWidth * 1.2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: radius);

    final seg = 2 * math.pi / cycleLength;
    final gap = seg * 0.32;
    final reachedDays = (currentDay * reveal).round();

    for (var i = 0; i < cycleLength; i++) {
      final day = i + 1;
      final start = -math.pi / 2 + i * seg + gap / 2;
      final sweep = seg - gap;

      final isFertile = fertileStartDay != null &&
          fertileEndDay != null &&
          day >= fertileStartDay! &&
          day <= fertileEndDay!;
      final isToday = day == currentDay;
      final isPast = day < currentDay;
      final reached = day <= reachedDays;

      final baseColor = isFertile ? _fertileColor : Colors.white;
      final filled = (isPast || isToday) && reached;

      // Glow under today's segment
      if (isToday && reached) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth * 2.4
          ..color = Colors.white.withOpacity(0.5 + 0.25 * pulse)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + pulse * 5);
        canvas.drawArc(rect, start, sweep, false, glow);
      }

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = isToday ? strokeWidth * 1.5 : strokeWidth
        ..color = filled
            ? baseColor
            : baseColor.withOpacity(isFertile ? 0.5 : 0.22);

      canvas.drawArc(rect, start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CycleRingPainter old) {
    return old.cycleLength != cycleLength ||
        old.currentDay != currentDay ||
        old.fertileStartDay != fertileStartDay ||
        old.fertileEndDay != fertileEndDay ||
        old.reveal != reveal ||
        old.pulse != pulse;
  }
}

/// Kept from the previous version in case another file still uses it.
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 6.0;
    final radius = (size.width / 2) - (strokeWidth / 2);
    final center = Offset(size.width / 2, size.height / 2);

    final basePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, basePaint);
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
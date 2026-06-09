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
  final int daysUntilNextPeriod;
  final DateTime nextPeriodDate;
  final DateTime ovulation;
  final DateTime fertileStart;
  final DateTime fertileEnd;
  final String phase;

  _CycleData({
    required this.lastPeriodDate,
    required this.cycleLength,
    required this.daysUntilNextPeriod,
    required this.nextPeriodDate,
    required this.ovulation,
    required this.fertileStart,
    required this.fertileEnd,
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
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

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
    await authProvider.logout();
    Provider.of<UserProfileProvider>(context, listen: false).resetProfile();
    Provider.of<SymptomLogProvider>(context, listen: false).resetLogs();
    Navigator.pushReplacementNamed(context, 'loginSignUpScreen');
  }

  /// ── Single source of truth for all cycle calculations ──
  _CycleData _resolveCycleData({
    required DateTime? logDate,
    required DateTime profileDate,
    required int? logCycleLength,
    required int profileCycleLength,
  }) {
    final today = DateTime.now();

    // Latest date wins
    final lastPeriodDate = (logDate != null && logDate.isAfter(profileDate))
        ? logDate
        : profileDate;

    // Cycle length follows whichever date won
    final cycleLength = (logDate != null && logDate.isAfter(profileDate))
        ? (logCycleLength ?? profileCycleLength)
        : profileCycleLength;

    // All predictions derived from the same base
    final daysSince = today.difference(lastPeriodDate).inDays;
    final cyclesElapsed = daysSince ~/ cycleLength;
    final nextPeriodDate = lastPeriodDate.add(
      Duration(days: cycleLength * (cyclesElapsed + 1)),
    );
    final daysUntilNextPeriod = cycleLength - (daysSince % cycleLength);
    final ovulation = nextPeriodDate.subtract(Duration(days: cycleLength ~/ 2));
    final fertileStart = ovulation.subtract(const Duration(days: 3));
    final fertileEnd = ovulation.add(const Duration(days: 3));

    // Phase based on same lastPeriodDate
    final cycleDay = (daysSince % cycleLength) + 1;
    String phase;
    if (cycleDay <= 5) phase = 'Menstrual';
    else if (cycleDay <= 11) phase = 'Follicular';
    else if (cycleDay <= 17) phase = 'Ovulation';
    else phase = 'Luteal';

    return _CycleData(
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
      daysUntilNextPeriod: daysUntilNextPeriod,
      nextPeriodDate: nextPeriodDate,
      ovulation: ovulation,
      fertileStart: fertileStart,
      fertileEnd: fertileEnd,
      phase: phase,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<UserProfileProvider>();
    final periodProvider = context.watch<PeriodLogProvider>();

    final profile = profileProvider.userProfile;
    final bool hasProfile = profile != null;
    final username = profile?.name.split(' ').first.toLowerCase() ?? 'user';

    if (profile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PeriodLogProvider>().setDefaultCycleLength(profile.cycleLength);
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: !hasProfile
            ? Text(appStrings.flowSavvyDashBoardText1,
            style: AppTextStyles.largeTextSemiBold(context))
            : Text('Welcome, $username 👋',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        centerTitle: !hasProfile,
        actions: [
          !hasProfile
              ? IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'logout',
          )
              : Padding(
            padding: const EdgeInsets.only(right: 24),
            child: CircleAvatar(
              child: IconButton(
                onPressed: () => logout(context),
                icon: const Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (!hasProfile) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(appStrings.defaultText,
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: constraints.maxWidth * 0.5,
                    child: LongCustomButton(
                      onTap: () => Navigator.pushNamed(context, '/profile'),
                      title: 'Go to Profile',
                    ),
                  ),
                ],
              ),
            );
          }

          // ── All cycle data resolved in one call ──
          final cycle = _resolveCycleData(
            logDate: periodProvider.latestLog?.startDate,
            profileDate: profile.lastPeriodDate,
            logCycleLength: periodProvider.latestLog?.cycleLength,
            profileCycleLength: profile.cycleLength,
          );

          final today = DateTime.now();
          final color = Theme.of(context).colorScheme;

          final borderColor = (cycle.daysUntilNextPeriod <= 2)
              ? Colors.pink.shade100
              : Colors.grey.shade400;

          final progress = today
              .difference(cycle.lastPeriodDate)
              .inDays
              .toDouble() /
              cycle.cycleLength.clamp(1, 365);

          final double ringSize = math.min(constraints.maxWidth * 0.75, 300.0);
          final double innerRingSize = ringSize * 0.88;

          final formattedNextPeriod =
          DateFormat('MMM dd').format(cycle.nextPeriodDate);
          final periodStatus = _getPeriodStatus(cycle.nextPeriodDate, today);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(getFormattedDate(), style: AppTextStyles.semiBold(context)),
                const SizedBox(height: 16),

                // Cycle Summary Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(
                      _getCycleDayText(cycle.lastPeriodDate, cycle.cycleLength),
                      style: AppTextStyles.smallTextRegular(context),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: color.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _getOvulationCountdown(cycle.ovulation, today),
                              style: AppTextStyles.smallTextRegular(context)
                                  .copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        if (profile.age >= 23) ...[
                          Text(
                            'Phase: ${cycle.phase}',
                            style: AppTextStyles.smallTextRegular(context)
                                .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Fertile Window: ${DateFormat('MMM d').format(cycle.fertileStart)} - ${DateFormat('MMM d').format(cycle.fertileEnd)}',
                            style: AppTextStyles.smallTextRegular(context)
                                .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Progress Ring
                Center(
                  child: SizedBox(
                    width: ringSize,
                    height: ringSize,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: ringSize,
                          height: ringSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: borderColor,
                                width: 2.0 + _pulseAnimation.value),
                          ),
                        ),
                        SizedBox(
                          width: innerRingSize,
                          height: innerRingSize,
                          child: CustomPaint(
                            painter: ProgressRingPainter(
                                progress: progress.clamp(0.0, 1.0),
                                color: color.primary),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: innerRingSize,
                          height: innerRingSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: borderColor,
                                width: 1.0 + (_pulseAnimation.value / 2)),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Period in:',
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              cycle.daysUntilNextPeriod > 0
                                  ? '${cycle.daysUntilNextPeriod} days'
                                  : (cycle.daysUntilNextPeriod == 0
                                  ? 'Today'
                                  : '${cycle.daysUntilNextPeriod.abs()} days late'),
                              style: const TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Last Period on ${DateFormat('MMMM d yyyy').format(cycle.lastPeriodDate)}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.semiBold(context)
                                  .copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Next Period Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text('Next Period',
                        style: AppTextStyles.smallTextRegular(context)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today,
                            color: color.primary, size: 16),
                        const SizedBox(width: 4),
                        Text('$formattedNextPeriod • $periodStatus',
                            style: TextStyle(color: Colors.grey[700])),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (profile.age >= 40)
                  _buildFeatureCard(
                    context,
                    title: 'Menopause Tips',
                    icon: Icons.female,
                    routeName: '/menopause',
                  ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    appStrings.homeStayHydratedText,
                    style: TextStyle(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getPeriodStatus(DateTime predictedDate, DateTime today) {
    final daysLate = today.difference(predictedDate).inDays;
    if (daysLate == 0) return 'due today';
    if (daysLate > 0) return '$daysLate days late';
    return 'in ${daysLate.abs()} days';
  }

  String _getOvulationCountdown(DateTime date, DateTime today) {
    final difference = date.difference(today).inDays;
    if (difference > 0) return 'Ovulation in $difference days';
    if (difference == 0) return 'Ovulation is today!';
    return 'Ovulation was ${difference.abs()} days ago';
  }

  String _getCycleDayText(DateTime lastPeriod, int cycleLen) {
    final daysSinceLastPeriod = DateTime.now().difference(lastPeriod).inDays;
    final dayOfCycle = (daysSinceLastPeriod % cycleLen) + 1;
    return 'Day $dayOfCycle of $cycleLen-day cycle';
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title,
        required IconData icon,
        required String routeName}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text(title, style: AppTextStyles.mediumTextSemiBold(context)),
            ],
          ),
        ),
      ),
    );
  }
}

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
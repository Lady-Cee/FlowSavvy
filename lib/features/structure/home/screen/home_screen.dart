import 'dart:math' as math;

import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flow_savvy/features/utils/app_text_styles.dart';
import 'package:flow_savvy/features/widgets/long_custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../utils/get_date_formatter.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    final prefs = await SharedPreferences.getInstance();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfileProvider>(context).userProfile;
    final bool hasProfile = profile != null;
    final username = (profile?.name.split(' ').first.toLowerCase()) ?? 'user';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: !hasProfile
            ? Text(appStrings.flowSavvyDashBoardText1, style: AppTextStyles.largeTextSemiBold(context))
            : Text('Welcome, ${username} 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                onPressed: () {},
                icon: const Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Consumer<UserProfileProvider>(
            builder: (context, profileProvider, _) {
              final profile = profileProvider.userProfile;
              final color = Theme.of(context).colorScheme;

              if (profile == null) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(appStrings.defaultText, style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
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

              final today = DateTime.now();
              final predictedNextPeriod = profile.predictedNextPeriod;
              final lastPeriodDate = profile.lastPeriodDate;
              final cycleLength = profile.cycleLength;
              final predictedOvulation = lastPeriodDate.add(const Duration(days: 14));

              final formattedNextPeriod = (predictedNextPeriod != null)
                  ? DateFormat('MMM dd').format(predictedNextPeriod)
                  : 'Not available';

              final periodStatus = (predictedNextPeriod != null)
                  ? _getPeriodStatus(predictedNextPeriod, today)
                  : '';

              final daysUntilNextPeriod = (predictedNextPeriod != null)
                  ? predictedNextPeriod.difference(today).inDays
                  : null;

              final borderColor = (daysUntilNextPeriod != null && daysUntilNextPeriod <= 2 && daysUntilNextPeriod >= 0)
                  ? Colors.pink.shade100
                  : Colors.grey.shade400;

              final progress = (today.difference(lastPeriodDate).inDays / cycleLength).clamp(0.0, 1.0);

              double ringSize = math.min(constraints.maxWidth * 0.75, 300.0);
              double innerRingSize = ringSize * 0.88;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getFormattedDate(), style: AppTextStyles.semiBold(context)),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(_getCycleDayText(lastPeriodDate, cycleLength), style: AppTextStyles.smallTextRegular(context)),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: color.primary, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _getOvulationCountdown(predictedOvulation, today),
                              style: AppTextStyles.smallTextRegular(context).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                                border: Border.all(color: borderColor, width: 2.0 + _pulseAnimation.value),
                              ),
                            ),
                            SizedBox(
                              width: innerRingSize,
                              height: innerRingSize,
                              child: CustomPaint(
                                painter: ProgressRingPainter(progress: progress, color: color.primary),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: innerRingSize,
                              height: innerRingSize,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: borderColor, width: 1.0 + (_pulseAnimation.value / 2)),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Period in:', style: TextStyle(color: Colors.white)),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  daysUntilNextPeriod != null
                                      ? (daysUntilNextPeriod > 0
                                      ? '$daysUntilNextPeriod days'
                                      : (daysUntilNextPeriod == 0
                                      ? 'Today'
                                      : '${daysUntilNextPeriod.abs()} days late'))
                                      : '--',
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Last Period on ${DateFormat('MMMM d yyyy').format(lastPeriodDate)}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.semiBold(context).copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text('Next Period', style: AppTextStyles.smallTextRegular(context)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_today, color: color.primary, size: 16),
                            const SizedBox(width: 4),
                            Text('$formattedNextPeriod • $periodStatus', style: TextStyle(color: Colors.grey[700])),
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
                    Center(child: Text(appStrings.homeStayHydratedText, style: TextStyle(color: Colors.grey[700]), textAlign: TextAlign.center,)),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
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
    final dayOfCycle = DateTime.now().difference(lastPeriod).inDays + 1;
    return 'Day $dayOfCycle of $cycleLen-day cycle';
  }

  Widget _buildFeatureCard(BuildContext context,
      {required String title, required IconData icon, required String routeName}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, routeName),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
              SizedBox(width: 10),
              Text(title, style: AppTextStyles.mediumTextSemiBold(context) ),
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
    final strokeWidth = 6.0;
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
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
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
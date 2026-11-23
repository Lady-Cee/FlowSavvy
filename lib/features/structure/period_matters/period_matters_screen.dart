import 'package:flow_savvy/features/structure/period_matters/period/screen/period_log_screen.dart';
import 'package:flow_savvy/features/structure/period_matters/symptom/screen/symptom_log_screen.dart';
import 'package:flow_savvy/features/structure/period_matters/user/screen/user_profile_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// One tappable item on the screen. Either opens an in-app screen
/// ([screen]) or an external web form ([url]).
class _Resource {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final WidgetBuilder? screen;
  final String? url;

  const _Resource({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.screen,
    this.url,
  });

  bool get isExternal => url != null;
}

class PeriodMattersScreen extends StatefulWidget {
  const PeriodMattersScreen({super.key});

  @override
  State<PeriodMattersScreen> createState() => _PeriodMattersScreenState();
}

class _PeriodMattersScreenState extends State<PeriodMattersScreen> {
  static const Color _violet = Color(0xFF8E5CF7);
  static const Color _teal = Color(0xFF14B8A6);
  static const Color _amber = Color(0xFFFFB020);
  static const Color _blue = Color(0xFF3B82F6);

  // ---------------------------------------------------------------------------
  // OPENING FORMS
  // ---------------------------------------------------------------------------

  /// Opens a web link. Tries the external browser first, then the platform
  /// default, then an in-app web view.
  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    var launched = false;

    for (final mode in const [
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
      LaunchMode.inAppWebView,
    ]) {
      try {
        launched = await launchUrl(uri, mode: mode);
        if (launched) break;
      } catch (e) {
        debugPrint('Launch failed with mode $mode: $e');
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Could not open the form. Please check your internet connection.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          action: SnackBarAction(
            label: 'Copy Link',
            textColor: Colors.white,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Link copied')),
              );
            },
          ),
        ),
      );
    }
  }

  void _handleTap(_Resource resource) {
    if (resource.isExternal) {
      _openUrl(resource.url!);
    } else if (resource.screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: resource.screen!),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  /// Fade + slide in. Later items take slightly longer, so the screen builds up.
  Widget _entrance(int index, Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 110),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 22),
          child: c,
        ),
      ),
      child: child,
    );
  }

  Widget _buildBanner(ColorScheme scheme) {
    final end = Color.lerp(scheme.primary, const Color(0xFF6D28D9), 0.65)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, end],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.3),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your health hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track your cycle, log symptoms, manage your profile and connect with NGOs, donors and sponsors.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _resourceTile(_Resource r) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _handleTap(r),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: r.accent.withOpacity(0.2)),
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
              // Gradient icon tile
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(r.accent, Colors.white, 0.28)!,
                      r.accent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  boxShadow: [
                    BoxShadow(
                      color: r.accent.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(r.icon, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      r.subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (r.isExternal) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: r.accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Opens in browser',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: r.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                r.isExternal
                    ? Icons.open_in_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: r.isExternal ? 20 : 16,
                color: r.accent,
              ),
            ],
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

    final tracking = <_Resource>[
      _Resource(
        title: 'Track Period',
        subtitle: 'Log your period start and end dates',
        icon: Icons.calendar_today_rounded,
        accent: scheme.primary,
        screen: (_) => PeriodLogScreen(),
      ),
      _Resource(
        title: 'Symptom Log',
        subtitle: 'Record how you feel each month',
        icon: Icons.medical_services_outlined,
        accent: _violet,
        screen: (_) => SymptomLogScreen(),
      ),
      _Resource(
        title: 'Profile',
        subtitle: 'Your details and cycle settings',
        icon: Icons.person_rounded,
        accent: _teal,
        screen: (_) => UserProfileScreen(),
      ),
    ];

    const support = <_Resource>[
      _Resource(
        title: 'Pad Request Form',
        subtitle: 'Ask for menstrual pad support',
        icon: Icons.assignment_outlined,
        accent: _amber,
        url: 'https://forms.gle/RJbhszE4bhq1TDCM8', // Pad request form url
      ),
      _Resource(
        title: 'NGO / Donor / Sponsor Form',
        subtitle: 'Partner with us to support girls and women',
        icon: Icons.volunteer_activism,
        accent: _blue,
        url:
        'https://forms.gle/iqwULzMhTXh9XiCb9', // NGO/DONOR registration form url
      ),
    ];

    var step = 1; // entrance order

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Period Matters',
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
                _entrance(0, _buildBanner(scheme)),
                const SizedBox(height: 24),

                _entrance(step++, _sectionTitle('Track & monitor')),
                for (final r in tracking) ...[
                  _entrance(step++, _resourceTile(r)),
                  const SizedBox(height: 12),
                ],

                const SizedBox(height: 12),
                _entrance(step++, _sectionTitle('Get support')),
                for (final r in support) ...[
                  _entrance(step++, _resourceTile(r)),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
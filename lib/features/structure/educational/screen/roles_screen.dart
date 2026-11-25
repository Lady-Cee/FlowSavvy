import 'package:flutter/material.dart';

/// Roles & responsibilities as a tabbed view: pick a group from the chips,
/// then read its responsibilities as a numbered action list.
class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  int _selected = 0;

  // Each group gets its own colour and icon, matched by name
  static const Map<String, _RoleStyle> _styles = {
    'individual': _RoleStyle(Color(0xFF8E5CF7), Icons.person_rounded),
    'communities': _RoleStyle(Color(0xFF14B8A6), Icons.groups_rounded),
    'government': _RoleStyle(Color(0xFF3B82F6), Icons.account_balance_rounded),
    'private sector': _RoleStyle(Color(0xFFFFB020), Icons.business_rounded),
    'ngos and civil societies':
    _RoleStyle(Color(0xFFF43F5E), Icons.volunteer_activism_rounded),
  };

  static const _RoleStyle _fallback =
  _RoleStyle(Color(0xFF8E5CF7), Icons.group_rounded);

  _RoleStyle _styleOf(String group) =>
      _styles[group.toLowerCase()] ?? _fallback;

  /// "individual" -> "Individual", "NGOs and civil societies" stays as is
  String _title(String group) {
    if (group.isEmpty) return group;
    return group[0].toUpperCase() + group.substring(1);
  }

  /// The responsibility text holds one action per line
  List<String> _actions(String text) => text
      .split('\n')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  Widget _buildIntro(ColorScheme scheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.handshake_rounded, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Good menstrual health takes everyone. Pick a group to see the part it plays.',
              style: TextStyle(
                  fontSize: 13.5, height: 1.4, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(ColorScheme scheme) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: roles.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final style = _styleOf(roles[i]['group']!);
          final selected = i == _selected;

          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? style.color : style.color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
                boxShadow: selected
                    ? [
                  BoxShadow(
                    color: style.color.withOpacity(0.40),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(style.icon,
                      size: 18, color: selected ? Colors.white : style.color),
                  const SizedBox(width: 8),
                  Text(
                    _title(roles[i]['group']!),
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : style.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetail(int index, ColorScheme scheme) {
    final role = roles[index];
    final style = _styleOf(role['group']!);
    final actions = _actions(role['responsibility']!);

    return Container(
      key: ValueKey(index),
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: style.color.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: style.color.withOpacity(0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Coloured title band
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [style.color, style.color.withOpacity(0.72)],
              ),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title(role['group']!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${actions.length} ways to make a difference',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.92),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Numbered actions
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Column(
              children: [
                for (var n = 0; n < actions.length; n++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: style.color.withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${n + 1}',
                            style: TextStyle(
                              color: style.color,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              actions[n],
                              style: const TextStyle(
                                fontSize: 14.5,
                                height: 1.5,
                              ),
                            ),
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
        title: const Text('Roles & Responsibilities',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: _buildIntro(scheme),
              ),
              _buildChips(scheme),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _buildDetail(_selected, scheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<Map<String, String>> roles = [
    {
      'group': 'individual',
      'responsibility':
      'Educate yourself and others on menstruation and proper hygiene practices.\n'
          'Practice proper hygiene by changing menstrual products regularly and using clean water.\n'
          'Break the stigma by speaking openly and respectfully about menstruation.\n'
          'Support peers—especially young girls—by sharing accurate information and emotional support.\n'
          'Encourage healthy habits like proper disposal of used menstrual materials and using clean, safe products.'
    },
    {
      'group': 'communities',
      'responsibility':
      'Create safe and private sanitation facilities, especially in schools and public places.\n'
          'Organize community awareness campaigns to dispel myths and taboos.\n'
          'Engage parents, teachers, and religious leaders to support open discussions about menstruation.\n'
          'Establish community support groups where women and girls can share experiences and learn.\n'
          'Promote local production of affordable menstrual products to increase accessibility.'
    },
    {
      'group': 'government',
      'responsibility':
      'Implement menstrual health education in school curricula.\n'
          'Ensure access to clean water and sanitation facilities in schools and public spaces.\n'
          'Subsidize or make menstrual products tax-free to improve affordability.\n'
          'Develop and enforce policies supporting menstrual health rights and workplace accommodations.\n'
          'Support research and data collection to improve MHM programs and policies.'
    },
    {
      'group': 'private sector',
      'responsibility':
      'Produce affordable, sustainable, and safe menstrual hygiene products.\n'
          'Run menstrual health education programs as part of corporate social responsibility (CSR).\n'
          'Create inclusive workplace policies that support menstruating employees (e.g., menstrual leave, proper restroom facilities).\n'
          'Partner with NGOs or government to distribute products to underserved areas.\n'
          'Innovate eco-friendly alternatives to reduce environmental impact.'
    },
    {
      'group': 'NGOs and civil societies',
      'responsibility':
      'Run awareness campaigns in schools, rural areas, and urban slums.\n'
          'Distribute menstrual products to girls and women in need, especially during emergencies or in low-income areas.\n'
          'Train health educators and community volunteers to spread accurate information.\n'
          'Advocate for policy changes and increased government funding for menstrual health.\n'
          'Monitor and evaluate MHM programs to ensure effectiveness and reach.'
    },
  ];
}

class _RoleStyle {
  final Color color;
  final IconData icon;
  const _RoleStyle(this.color, this.icon);
}
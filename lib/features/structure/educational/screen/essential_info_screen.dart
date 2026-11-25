import 'package:flutter/material.dart';

class EssentialInfoScreen extends StatefulWidget {
  const EssentialInfoScreen({super.key});

  @override
  State<EssentialInfoScreen> createState() => _EssentialInfoScreenState();
}

class _EssentialInfoScreenState extends State<EssentialInfoScreen> {
  static const Color _deepViolet = Color(0xFF6D28D9);

  // Accent colours cycled through the cards
  static const List<Color> _accents = [
    Color(0xFF8E5CF7),
    Color(0xFF14B8A6),
    Color(0xFFFFB020),
    Color(0xFF3B82F6),
  ];

  static const List<IconData> _icons = [
    Icons.lightbulb_rounded,
    Icons.favorite_rounded,
    Icons.spa_rounded,
    Icons.bubble_chart_rounded,
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Each fact keeps its original number, even while filtering
  List<MapEntry<int, String>> get _filtered {
    final q = _query.trim().toLowerCase();
    final all = essentialInfo.asMap().entries.toList();
    if (q.isEmpty) return all;
    return all.where((e) => e.value.toLowerCase().contains(q)).toList();
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  Widget _entrance(int index, Widget child) {
    final delay = (index * 0.06).clamp(0.0, 0.5);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + (delay * 1000).round()),
      curve: Curves.easeOutCubic,
      builder: (context, v, c) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, (1 - v) * 24), child: c),
      ),
      child: child,
    );
  }

  Widget _buildHeader(ColorScheme scheme) {
    final end = Color.lerp(scheme.primary, _deepViolet, 0.65)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, end],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_stories_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Know your body',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${essentialInfo.length} quick facts about menstruation, explained simply.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(ColorScheme scheme) {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _query = v),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search facts…',
        filled: true,
        fillColor: scheme.primary.withOpacity(0.06),
        prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _searchController.clear();
            setState(() => _query = '');
          },
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _factCard(int number, String text, ColorScheme scheme) {
    final accent = _accents[number % _accents.length];
    final icon = _icons[number % _icons.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent edge
              Container(width: 5, color: accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FACT ${(number + 1).toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10.5,
                                letterSpacing: 1.8,
                                fontWeight: FontWeight.w800,
                                color: accent,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              text,
                              style: const TextStyle(
                                fontSize: 14.5,
                                height: 1.45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primary.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded,
                size: 36, color: scheme.primary),
          ),
          const SizedBox(height: 14),
          const Text('No facts match your search',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Try a different word.',
              style: TextStyle(color: scheme.onSurface.withOpacity(0.6))),
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
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Essential Menstrual Info',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              _entrance(0, _buildHeader(scheme)),
              const SizedBox(height: 16),
              _entrance(1, _buildSearch(scheme)),
              const SizedBox(height: 16),
              if (items.isEmpty)
                _emptyState(scheme)
              else
                for (var i = 0; i < items.length; i++)
                  _entrance(
                    i + 2,
                    _factCard(items[i].key, items[i].value, scheme),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> essentialInfo = [
    'Menstruation is a natural biological process.',
    'The average menstrual cycle is about 28 days.',
    'It is normal for cycles to vary between individuals.',
    'A typical period lasts between 3 to 7 days.',
    'Menstruation occurs when the uterus sheds its lining because an egg was not fertilized.',
    'The average amount of blood lost during a period is between 30 and 40 milliliters.',
    'The first menstruation, or menarche, typically occurs between ages 9 and 16.',
    // The two near-identical menopause facts were merged into this one.
    'Periods can start to occur irregularly as women approach menopause, usually between ages 45 and 55.',
    'Menstruation is controlled by hormonal changes, primarily estrogen and progesterone.',
    'It is normal for periods to be light, heavy, or in between.',
    'Some women may experience premenstrual syndrome (PMS), which can cause mood swings, bloating, and fatigue.',
    'Menstrual cycles can be affected by stress, health conditions, and changes in diet or exercise.',
    'Tracking menstrual cycles can help in understanding reproductive health.',
    'Tampons, pads, menstrual cups, and period panties are common products used to manage menstruation.',
    'Not all women experience cramps, but they are common, especially during the first few days of menstruation.',
    'Irregular periods can be caused by hormonal imbalances, stress, or health issues such as polycystic ovary syndrome (PCOS).',
    'Menstruation is a sign of a functioning reproductive system in people with ovaries.',
    'It is normal to experience changes in cycle length or flow throughout life, especially during puberty and menopause.',
    'Good menstrual hygiene practices are important to prevent infections and discomfort.',
    'Some cultures and communities may have specific beliefs or taboos surrounding menstruation.',
  ];
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hygiene tips as an interactive checklist: tap a tip to mark it as a habit
/// you already follow. Progress is saved on the device.
class HygieneTipsScreen extends StatefulWidget {
  const HygieneTipsScreen({super.key});

  @override
  State<HygieneTipsScreen> createState() => _HygieneTipsScreenState();
}

class _HygieneTipsScreenState extends State<HygieneTipsScreen> {
  static const String _prefsKey = 'hygiene_tips_done';

  // This screen uses a fresh teal / blue palette so it feels different from
  // the other info screens.
  static const Color _teal = Color(0xFF14B8A6);
  static const Color _blue = Color(0xFF3B82F6);

  final Set<int> _done = {};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefsKey) ?? [];
      if (!mounted) return;
      setState(() {
        _done
          ..clear()
          ..addAll(saved
              .map(int.tryParse)
              .whereType<int>()
              .where((i) => i >= 0 && i < hygieneTips.length));
      });
    } catch (_) {
      // Progress just won't be restored; the screen still works.
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          _prefsKey, _done.map((e) => e.toString()).toList());
    } catch (_) {}
  }

  void _toggle(int i) {
    setState(() {
      if (!_done.remove(i)) _done.add(i);
    });
    _saveProgress();
  }

  void _reset() {
    setState(_done.clear);
    _saveProgress();
  }

  // Pick an icon that matches the tip's content
  IconData _iconFor(String tip) {
    final t = tip.toLowerCase();
    if (t.contains('hand')) return Icons.clean_hands_rounded;
    if (t.contains('flush') || t.contains('dispose')) {
      return Icons.delete_outline_rounded;
    }
    if (t.contains('underwear')) return Icons.checkroom_rounded;
    if (t.contains('shower') || t.contains('wash')) {
      return Icons.shower_rounded;
    }
    if (t.contains('change')) return Icons.schedule_rounded;
    if (t.contains('douch') || t.contains('scented')) {
      return Icons.block_rounded;
    }
    if (t.contains('reusable') || t.contains('clean')) {
      return Icons.cleaning_services_rounded;
    }
    if (t.contains('trim')) return Icons.content_cut_rounded;
    return Icons.water_drop_rounded;
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  Widget _entrance(int index, Widget child) {
    final delay = (index * 0.05).clamp(0.0, 0.5);
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

  Widget _buildProgressCard() {
    final total = hygieneTips.length;
    final count = _done.length;
    final progress = total == 0 ? 0.0 : count / total;
    final complete = count == total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_teal, _blue],
        ),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 84,
            height: 84,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 84,
                  height: 84,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: progress),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, v, _) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 8,
                      strokeCap: StrokeCap.round,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                Text(
                  '$count/$total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  complete ? 'Hygiene hero! 🎉' : 'Your hygiene checklist',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  complete
                      ? 'You follow every tip. Keep it up!'
                      : 'Tap a tip to mark it as a habit you already follow.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _reset,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipTile(int i, ColorScheme scheme) {
    final done = _done.contains(i);
    final accent = done ? _teal : _blue;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: done ? _teal.withOpacity(0.08) : scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accent.withOpacity(done ? 0.40 : 0.16),
          width: done ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _toggle(i),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_iconFor(hygieneTips[i]),
                      color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hygieneTips[i],
                    style: TextStyle(
                      fontSize: 14.5,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                      color: done
                          ? scheme.onSurface.withOpacity(0.55)
                          : scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Animated check circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? _teal : Colors.transparent,
                    border: Border.all(
                      color: done ? _teal : scheme.onSurface.withOpacity(0.25),
                      width: 2,
                    ),
                  ),
                  child: AnimatedScale(
                    scale: done ? 1 : 0,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutBack,
                    child: const Icon(Icons.check_rounded,
                        size: 18, color: Colors.white),
                  ),
                ),
              ],
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
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Hygiene Tips',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              _buildProgressCard(),
              const SizedBox(height: 18),
              for (var i = 0; i < hygieneTips.length; i++)
                _entrance(i, _tipTile(i, scheme)),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> hygieneTips = [
    'Change sanitary products every 4–6 hours.',
    'Wash the genital area with warm water and mild soap.',
    'Avoid using scented products that can cause irritation.',
    'Always wash your hands before and after changing sanitary products.',
    'Dispose of used sanitary products properly—wrap them and place in a bin.',
    'Wear breathable cotton underwear to help prevent infections.',
    'Take a shower daily to maintain overall cleanliness.',
    'Avoid douching as it can disrupt the vagina’s natural balance.',
    'Do not flush sanitary products; use designated disposal bins.',
    'Keep your pubic area clean and dry to reduce moisture build-up.',
    'Change underwear daily and keep an extra pair during your period.',
    'Trim pubic hair regularly to maintain hygiene (optional but helpful).',
    'Use unscented, pH-balanced wipes if necessary while outside.',
    'Properly clean reusable menstrual products (like cups or cloth pads) after each use.',
  ];
}
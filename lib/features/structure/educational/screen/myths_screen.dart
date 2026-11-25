import 'dart:math' as math;

import 'package:flow_savvy/features/models/myths_and_facts_model.dart';
import 'package:flow_savvy/features/utils/app_strings.dart';
import 'package:flutter/material.dart';

import '../../../data/myths_and_facts_data.dart';

/// Myths & facts as flip cards: read the myth, tap to flip and reveal the
/// truth. A counter at the top tracks how many myths you have busted.
class MythsScreen extends StatefulWidget {
  const MythsScreen({super.key});

  @override
  State<MythsScreen> createState() => _MythsScreenState();
}

class _MythsScreenState extends State<MythsScreen> {
  // Warm coral / amber for myths, green for facts, so this screen has its own
  // personality compared with the other info screens.
  static const Color _mythColor = Color(0xFFF43F5E);
  static const Color _mythAmber = Color(0xFFFFB020);
  static const Color _factColor = Color(0xFF10B981);

  final AppStrings appStrings = AppStrings();
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  // Indexes (in the full list) of the myths that have been flipped
  final Set<int> _busted = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Keeps each item's original index so flipped cards survive filtering
  List<MapEntry<int, MythsAndFactsModel>> get _filtered {
    final q = _query.trim().toLowerCase();
    final all = mythsAndFacts.asMap().entries.toList();
    if (q.isEmpty) return all;
    return all
        .where((e) =>
    e.value.myth.toLowerCase().contains(q) ||
        e.value.fact.toLowerCase().contains(q))
        .toList();
  }

  void _flip(int index) {
    setState(() {
      if (!_busted.remove(index)) _busted.add(index);
    });
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

  Widget _buildHeader() {
    final total = mythsAndFacts.length;
    final count = _busted.length;
    final progress = total == 0 ? 0.0 : count / total;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_mythColor, _mythAmber],
        ),
        boxShadow: [
          BoxShadow(
            color: _mythColor.withOpacity(0.30),
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
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('🕵️', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Myth buster',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.24),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$count / $total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Ever wondered which period beliefs are fact and which are myths? '
                    'Tap a card to find out the truth!',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.93),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 8,
                    backgroundColor: Colors.white.withOpacity(0.28),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
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
        hintText: 'Search myths…',
        filled: true,
        fillColor: _mythColor.withOpacity(0.06),
        prefixIcon: const Icon(Icons.search_rounded, color: _mythColor),
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
          borderSide: const BorderSide(color: _mythColor, width: 1.5),
        ),
      ),
    );
  }

  /// One face of the card (myth side or fact side)
  Widget _face({
    required Color color,
    required IconData icon,
    required String tag,
    required String text,
    required String hint,
    required ColorScheme scheme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.alphaBlend(color.withOpacity(0.07), scheme.surface),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15.5,
              height: 1.45,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.touch_app_rounded,
                  size: 15, color: color.withOpacity(0.8)),
              const SizedBox(width: 6),
              Text(
                hint,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _flipCard(int index, MythsAndFactsModel item, ColorScheme scheme) {
    final flipped = _busted.contains(index);

    final front = _face(
      color: _mythColor,
      icon: Icons.close_rounded,
      tag: 'MYTH',
      text: item.myth,
      hint: 'Tap to reveal the truth',
      scheme: scheme,
    );
    final back = _face(
      color: _factColor,
      icon: Icons.check_rounded,
      tag: 'FACT',
      text: item.fact,
      hint: 'Tap to flip back',
      scheme: scheme,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () => _flip(index),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: flipped ? 1 : 0),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          builder: (context, v, _) {
            final showBack = v > 0.5;
            // The back face is mirrored by the rotation, so rotate it
            // another half turn to read correctly.
            final angle = v * math.pi;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(angle),
              child: showBack
                  ? Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..rotateX(math.pi),
                child: back,
              )
                  : front,
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _mythColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 36, color: _mythColor),
          ),
          const SizedBox(height: 14),
          const Text('No myths match your search',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
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
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left),
        ),
        centerTitle: true,
        title: Text(
          appStrings.mythsAndFactsTitleText,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              _entrance(0, _buildHeader()),
              const SizedBox(height: 16),
              _entrance(1, _buildSearch(scheme)),
              const SizedBox(height: 16),
              if (items.isEmpty)
                _emptyState()
              else
                for (var i = 0; i < items.length; i++)
                  _entrance(
                    i + 2,
                    _flipCard(items[i].key, items[i].value, scheme),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
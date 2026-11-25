import 'package:flutter/material.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  static const Color _deepViolet = Color(0xFF6D28D9);

  static const List<Color> _accents = [
    Color(0xFF8E5CF7),
    Color(0xFF14B8A6),
    Color(0xFFFFB020),
    Color(0xFF3B82F6),
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // Index (in the full list) of the open question; only one opens at a time
  int? _openIndex;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MapEntry<int, Map<String, String>>> get _filtered {
    final q = _query.trim().toLowerCase();
    final all = faqs.asMap().entries.toList();
    if (q.isEmpty) return all;
    return all
        .where((e) =>
    e.value['question']!.toLowerCase().contains(q) ||
        e.value['answer']!.toLowerCase().contains(q))
        .toList();
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
                child: const Icon(Icons.forum_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Got questions?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${faqs.length} answers to the things people often ask about periods.',
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
      onChanged: (v) => setState(() {
        _query = v;
        _openIndex = null;
      }),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search questions…',
        filled: true,
        fillColor: scheme.primary.withOpacity(0.06),
        prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _searchController.clear();
            setState(() {
              _query = '';
              _openIndex = null;
            });
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

  Widget _faqCard(int index, Map<String, String> faq, ColorScheme scheme) {
    final accent = _accents[index % _accents.length];
    final open = _openIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: open ? accent.withOpacity(0.06) : scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accent.withOpacity(open ? 0.45 : 0.18),
          width: open ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(open ? 0.18 : 0.08),
            blurRadius: open ? 18 : 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => setState(() => _openIndex = open ? null : index),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        faq['question']!,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.35,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(Icons.keyboard_arrow_down_rounded,
                          color: accent, size: 26),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: open
                      ? Padding(
                    padding: const EdgeInsets.only(top: 12, left: 50),
                    child: Text(
                      faq['answer']!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: scheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
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
          const Text('No questions match your search',
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
        title: const Text('FAQs',
            style: TextStyle(fontWeight: FontWeight.w800)),
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
                    _faqCard(items[i].key, items[i].value, scheme),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<Map<String, String>> faqs = [
    {
      'question': 'Can I exercise during my period?',
      'answer': 'Yes, light to moderate exercise can help relieve cramps and improve mood.'
    },
    {
      'question': 'Is it safe to use tampons?',
      'answer': 'Yes, when used correctly and changed regularly, tampons are safe.'
    },
    {
      'question': 'What is menstruation?',
      'answer': 'Menstruation is the monthly shedding of the uterine lining, resulting in bleeding through the vagina.'
    },
    {
      'question': 'At what age do girls usually start menstruating?',
      'answer': 'Most girls begin menstruating between ages 10 and 15, though it can vary.'
    },
    {
      'question': 'What is a menstrual cycle?',
      'answer': 'The menstrual cycle is the monthly process where the body prepares for pregnancy, including ovulation and menstruation.'
    },
    {
      'question': 'How long does a menstrual cycle last?',
      'answer': 'A typical menstrual cycle lasts about 28 days, but it can range from 21 to 35 days.'
    },
    {
      'question': 'How many days does menstruation last?',
      'answer': 'Menstruation usually lasts between 3 to 7 days.'
    },
    {
      'question': 'How do I calculate my menstrual cycle?',
      'answer': 'Start counting from the first day of your period to the day before your next period begins. This is your cycle length.'
    },
    {
      'question': 'What is the fertile window?',
      'answer': 'The fertile window is the period when pregnancy is most likely, spanning 5 days before ovulation and the day of ovulation itself.'
    },
    {
      'question': 'Can I track my cycle using apps?',
      'answer': 'Yes, apps like Flo, Clue, and Period Tracker help monitor menstrual cycles, predict ovulation, and track symptoms.'
    },
    {
      'question': 'Is it normal to have irregular cycles?',
      'answer': 'Occasional irregularities are common, especially during adolescence or perimenopause.'
    },
    {
      'question': 'Can stress affect my menstrual cycle?',
      'answer': 'Yes, high stress levels can lead to delayed or missed periods.'
    },
    {
      'question': 'What is menstrual hygiene management (MHM)?',
      'answer': 'MHM involves using clean menstrual products and maintaining proper hygiene during menstruation.'
    },
    {
      'question': 'How often should I change my menstrual product?',
      'answer': 'Change pads every 4–6 hours, tampons every 4–8 hours, and empty menstrual cups every 8–12 hours.'
    },
    {
      'question': 'Is it safe to swim during menstruation?',
      'answer': 'Yes, using tampons or menstrual cups makes swimming safe during your period.'
    },
    {
      'question': 'Can poor menstrual hygiene cause infections?',
      'answer': 'Yes, improper hygiene can lead to infections like UTIs or RTIs.'
    },
    {
      'question': 'What is Toxic Shock Syndrome (TSS)?',
      'answer': 'Toxic Shock Syndrome is a rare but serious condition linked to prolonged tampon use. Change tampons regularly to reduce the risk.'
    },
    {
      'question': 'How can I relieve menstrual cramps?',
      'answer': 'Apply heat, take pain relievers, exercise, and stay hydrated to relieve cramps.'
    },
    {
      'question': 'What is PMS?',
      'answer': 'PMS stands for Premenstrual Syndrome, which includes symptoms like mood swings and bloating before menstruation.'
    },
    {
      'question': 'What is PMDD?',
      'answer': 'Premenstrual Dysphoric Disorder (PMDD) is a severe form of PMS that affects daily life.'
    },
    {
      'question': 'What is PCOS?',
      'answer': 'Polycystic Ovary Syndrome (PCOS) is a hormonal disorder causing irregular periods and other symptoms.'
    },
    {
      'question': 'What is endometriosis?',
      'answer': 'Endometriosis is a condition where tissue similar to the uterine lining grows outside the uterus, causing pain and potentially affecting fertility.'
    },
    {
      'question': 'What is amenorrhea?',
      'answer': 'Amenorrhea is the absence of menstruation, which can be primary (no periods by age 15) or secondary (missing periods for three months or more).'
    },
    {
      'question': 'When should I see a doctor about my period?',
      'answer': 'See a doctor if you soak through pads quickly, bleed for more than 7 days, or have very heavy bleeding, severe pain, missed periods, or significant changes in your cycle.'
    },
    {
      'question': 'Is it normal to have blood clots during menstruation?',
      'answer': 'Small clots are normal, but large or frequent clots should be evaluated by a doctor.'
    },
    {
      'question': 'What are the signs of a urinary tract infection (UTI)?',
      'answer': 'Symptoms include a burning sensation during urination, frequent urge to urinate, and cloudy urine.'
    },
    {
      'question': 'Does diet affect menstruation?',
      'answer': 'A balanced diet supports regular cycles, while extreme dieting or poor nutrition can disrupt menstruation.'
    },
    {
      'question': 'Can exercise influence my period?',
      'answer': 'Regular exercise promotes overall health, but excessive intense activity can lead to missed periods.'
    },
    {
      'question': 'How does menopause affect menstruation?',
      'answer': 'Menopause marks the end of menstrual cycles, typically between ages 45 and 55, with periods becoming irregular before stopping.'
    },
    {
      'question': 'What is period poverty?',
      'answer': 'Period poverty refers to inadequate access to menstrual products and hygiene facilities.'
    },
    {
      'question': 'How does menstruation affect school attendance?',
      'answer': 'Lack of products and facilities can cause girls to miss school during their periods.'
    },
    {
      'question': 'Are there cultural taboos around menstruation?',
      'answer': 'Yes, many cultures have myths and restrictions around menstruation, leading to stigma and misinformation.'
    },
  ];
}
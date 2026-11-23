import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../providers/user_profile_provider.dart';
import '../../../../utils/app_strings.dart';
import '../../../../utils/app_text_styles.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _cycleLengthController = TextEditingController();
  final _lastPeriodController = TextEditingController();

  DateTime? _lastPeriodDate;
  DateTime? _predictedNextPeriod;
  DateTime? _predictedOvulation;
  int? _cycleDay;
  int? _daysToNextPeriod;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _cycleLengthController.dispose();
    _lastPeriodController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOGIC (same behaviour as before)
  // ---------------------------------------------------------------------------

  Future<void> _loadProfile() async {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    await provider.loadUserProfile();
    if (!mounted) return;

    final profile = provider.userProfile;

    if (profile != null) {
      final cycleLength = profile.cycleLength;
      final lastPeriod = profile.lastPeriodDate;

      _updatePredictionFromLastPeriod(lastPeriod, cycleLength);

      setState(() {
        _nameController.text = profile.name;
        _ageController.text = profile.age.toString();
        _cycleLengthController.text = cycleLength.toString();
        _lastPeriodController.text =
            DateFormat('yyyy-MM-dd').format(lastPeriod);
      });
    }
  }

  /// Strips the time of day so only the calendar date is used.
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Adds days using calendar arithmetic (safe across daylight-saving changes).
  DateTime _addDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  /// Whole calendar days from [from] to [to], ignoring time of day.
  int _daysBetween(DateTime from, DateTime to) {
    final a = DateTime.utc(from.year, from.month, from.day);
    final b = DateTime.utc(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  void _updatePredictionFromLastPeriod(DateTime lastPeriod, int cycleLength) {
    // Guard: a cycle length of 0 would crash the maths below
    if (cycleLength <= 0) return;

    final today = _dateOnly(DateTime.now());
    final lastStart = _dateOnly(lastPeriod); // the real, entered date

    // If the last period was a while ago, assume cycles have repeated since,
    // so the predictions always point at the current or next cycle.
    final daysSinceLast = _daysBetween(lastStart, today);
    final cyclesPassed = daysSinceLast <= 0 ? 0 : daysSinceLast ~/ cycleLength;
    final currentCycleStart = _addDays(lastStart, cyclesPassed * cycleLength);

    final nextPeriod = _addDays(currentCycleStart, cycleLength);

    // Ovulation happens about 14 days BEFORE the next period (the luteal phase
    // is fairly constant), not 14 days after the last one. For a 28-day cycle
    // both give the same date, but they differ for any other cycle length.
    // Very short cycles are clamped so ovulation never lands before day 2.
    final ovulationOffset = cycleLength > 15 ? cycleLength - 14 : 1;
    final ovulationDate = _addDays(currentCycleStart, ovulationOffset);

    setState(() {
      // Keep the real last period date (do not overwrite it with a projected
      // one), so what the user saves is what they actually entered.
      _lastPeriodDate = lastStart;
      _predictedNextPeriod = nextPeriod;
      _predictedOvulation = ovulationDate;
      _cycleDay = _daysBetween(currentCycleStart, today) + 1;
      _daysToNextPeriod = _daysBetween(today, nextPeriod);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // last period can't be in the future
    );
    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
        _lastPeriodController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _updatePrediction(); // Recalculate predictions on new input
    }
  }

  void _updatePrediction() {
    final cycleLength = int.tryParse(_cycleLengthController.text);
    if (_lastPeriodDate != null && cycleLength != null) {
      _updatePredictionFromLastPeriod(_lastPeriodDate!, cycleLength);
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text);
    final cycleLength = int.tryParse(_cycleLengthController.text);

    final scheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = Provider.of<UserProfileProvider>(context, listen: false);

    if (name.isEmpty ||
        age == null ||
        cycleLength == null ||
        cycleLength <= 0 ||
        _lastPeriodDate == null) {
      messenger.showSnackBar(
        SnackBar(
          content: Text("Please fill in all fields with valid information"),
          backgroundColor: scheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await provider.saveUserProfile(
        name,
        age,
        cycleLength,
        _lastPeriodDate!,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text("Profile saved successfully ✅"),
          backgroundColor: scheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      navigator.pushNamed('/home');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text("Failed to save profile: $e"),
          backgroundColor: scheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---------------------------------------------------------------------------
  // UI HELPERS
  // ---------------------------------------------------------------------------

  /// White rounded card with a small icon + title, used to group fields.
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.primary.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  /// Modern filled text field with a floating label and a leading icon.
  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? formatters,
    bool readOnly = false,
    VoidCallback? onTap,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
    String? suffixText,
  }) {
    final scheme = Theme.of(context).colorScheme;

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: scheme.primary),
        suffixIcon: suffixIcon,
        suffixText: suffixText,
        filled: true,
        fillColor: scheme.primary.withOpacity(0.05),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: border(Colors.transparent),
        enabledBorder: border(Colors.transparent),
        focusedBorder: border(scheme.primary, 1.6),
      ),
    );
  }

  String _daysLabel(int days) {
    if (days <= 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return 'In $days days';
  }

  /// Small translucent tile used inside the cycle insights card.
  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required String detail,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gradient card with a progress ring and the predictions.
  Widget _insightsCard() {
    final scheme = Theme.of(context).colorScheme;
    final cycleLength = int.tryParse(_cycleLengthController.text) ?? 28;
    final progress =
    ((_cycleDay ?? 0) / (cycleLength <= 0 ? 28 : cycleLength))
        .clamp(0.0, 1.0)
        .toDouble();

    return Container(
      key: const ValueKey('insights'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            scheme.primary.withOpacity(0.72),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Progress ring
              SizedBox(
                width: 112,
                height: 112,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 112,
                          height: 112,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 9,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Day',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${_cycleDay ?? '-'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'of $cycleLength',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your cycle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _daysToNextPeriod == null
                          ? ''
                          : 'Next period: ${_daysLabel(_daysToNextPeriod!).toLowerCase()}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.92),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _statTile(
                icon: Icons.water_drop_rounded,
                label: 'Next period',
                value: _predictedNextPeriod == null
                    ? '-'
                    : DateFormat('MMM d').format(_predictedNextPeriod!),
                detail: _daysToNextPeriod == null
                    ? ''
                    : _daysLabel(_daysToNextPeriod!),
              ),
              const SizedBox(width: 12),
              _statTile(
                icon: Icons.spa_rounded,
                label: 'Ovulation',
                value: _predictedOvulation == null
                    ? '-'
                    : DateFormat('MMM d').format(_predictedOvulation!),
                detail: _predictedOvulation == null
                    ? ''
                    : DateFormat('EEEE').format(_predictedOvulation!),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'These are estimates based on your average cycle. Cycles can vary from month to month.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// Shown until enough information is filled in to make predictions.
  Widget _insightsPlaceholder() {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      key: const ValueKey('placeholder'),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: scheme.primary),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Add your cycle length and last period date to see your cycle day, next period and ovulation predictions.',
              style: TextStyle(fontSize: 13.5, height: 1.4),
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
    final appStrings = AppStrings();
    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;

    final nameText = _nameController.text.trim();
    final hasPredictions = _cycleDay != null;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 60,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: scheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          appStrings.completeYourProfileText,
          style: AppTextStyles.largeTextSemiBold(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.primary.withOpacity(0.35),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: scheme.primary.withOpacity(0.14),
                      child: nameText.isEmpty
                          ? Icon(Icons.person_rounded,
                          size: 40, color: scheme.primary)
                          : Text(
                        nameText[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    appStrings.completeProfileSubTitleText,
                    style: AppTextStyles.smallTextRegular(context),
                    textAlign: TextAlign.center,
                  ),

                  // Login reminder if user not logged in
                  if (user == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.info_outline,
                                size: 16, color: Colors.grey),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Login to access your profile across devices.",
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 22),

                  // Personal details
                  _sectionCard(
                    title: 'Personal details',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _field(
                        controller: _nameController,
                        label: appStrings.completeProfileNameText,
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.name,
                        onChanged: (_) => setState(() {}), // updates avatar
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _ageController,
                        label: appStrings.completeProfileAgeText,
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Cycle details
                  _sectionCard(
                    title: 'Cycle details',
                    icon: Icons.calendar_month_outlined,
                    children: [
                      _field(
                        controller: _cycleLengthController,
                        label: appStrings.completeProfileAverageCycleText2,
                        icon: Icons.loop_rounded,
                        keyboardType: TextInputType.number,
                        suffixText: 'days',
                        formatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (_) => _updatePrediction(),
                      ),
                      const SizedBox(height: 14),
                      _field(
                        controller: _lastPeriodController,
                        label: appStrings.completeProfileLastPeriodText,
                        icon: Icons.event_outlined,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
                            color: scheme.primary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Predictions
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    child: hasPredictions
                        ? _insightsCard()
                        : _insightsPlaceholder(),
                  ),

                  const SizedBox(height: 28),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.primary,
                        foregroundColor: scheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isSaving
                          ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: scheme.onPrimary,
                        ),
                      )
                          : Text(
                        appStrings.saveProfileBtnText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Privacy note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          size: 15, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          appStrings.completeProfileWeValueText,
                          style: AppTextStyles.smallTextRegular(context)
                              .copyWith(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
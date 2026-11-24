import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/gemini_provider.dart';

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// "Today", "Yesterday" or a date, for the separators between days.
String _dateLabel(DateTime d) {
  final now = DateTime.now();
  if (_sameDay(d, now)) return 'Today';
  if (_sameDay(d, now.subtract(const Duration(days: 1)))) return 'Yesterday';
  return DateFormat('MMM d, yyyy').format(d);
}

class GeminiSearchScreen extends StatefulWidget {
  const GeminiSearchScreen({super.key});

  @override
  _GeminiSearchScreenState createState() => _GeminiSearchScreenState();
}

class _GeminiSearchScreenState extends State<GeminiSearchScreen>
    with SingleTickerProviderStateMixin {
  static const Color _deepViolet = Color(0xFF6D28D9);

  /// Quick questions the user can tap instead of typing.
  static const List<String> _suggestions = [
    'What causes period cramps?',
    'How often should I change my pad?',
    'Is an irregular period normal?',
    'What foods help with period pain?',
    'What is PMS?',
    'How do I track my cycle?',
  ];

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _focused = false;

  // Breathing glow around the PeriodBot avatar
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    // Rebuild when the text changes (send / clear buttons)
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    _focusNode.addListener(() {
      if (mounted) setState(() => _focused = _focusNode.hasFocus);
    });

    // Load this user's saved chats from Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<GeminiProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _float.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // LOGIC
  // ---------------------------------------------------------------------------

  void _submit() {
    final provider = Provider.of<GeminiProvider>(context, listen: false);

    // Don't clear the text if a request is already running
    if (provider.isLoading) return;

    final query = _controller.text.trim();
    if (query.isEmpty) return;

    provider.getGeminiResponse(query);
    _controller.clear();
    FocusScope.of(context).unfocus(); // Close keyboard
  }

  void _sendSuggestion(String question) {
    final provider = Provider.of<GeminiProvider>(context, listen: false);
    if (provider.isLoading) return;

    provider.getGeminiResponse(question);
    FocusScope.of(context).unfocus();
  }

  Future<void> _confirmClearAll() async {
    final provider = Provider.of<GeminiProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Clear all chats?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'This removes every question and answer. It can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear all',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );

    if (confirmed == true) provider.clearResponses();
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Response copied'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _delete(int index) {
    final provider = Provider.of<GeminiProvider>(context, listen: false);
    final primary = Theme.of(context).colorScheme.primary;

    // remove and keep a copy
    final deletedResponse = provider.removeResponseAt(index);

    // show snackbar with undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Record deleted'),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        // Newer Flutter versions keep a snackbar with an action on screen
        // until it is tapped. This makes it close after the duration.
        persist: false,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // re-insert at the same position
            provider.insertResponseAt(index, deletedResponse);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI PIECES
  // ---------------------------------------------------------------------------

  LinearGradient _brandGradient(ColorScheme scheme) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [scheme.primary, Color.lerp(scheme.primary, _deepViolet, 0.65)!],
  );

  Widget _botAvatar(ColorScheme scheme, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _brandGradient(scheme),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(Icons.smart_toy_rounded,
          color: Colors.white, size: size * 0.55),
    );
  }

  Widget _suggestionChip(String text, ColorScheme scheme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _sendSuggestion(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: scheme.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: scheme.primary.withOpacity(0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 14, color: scheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shown while the saved chats are being loaded from Firebase.
  Widget _buildHistoryLoading(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading your chats...',
            style: TextStyle(
              fontSize: 13.5,
              color: scheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Welcome screen with quick questions, shown before the first question.
  Widget _buildEmptyState(ColorScheme scheme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _float,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -6 * _float.value),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _brandGradient(scheme),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary
                            .withOpacity(0.25 + 0.15 * _float.value),
                        blurRadius: 20 + 16 * _float.value,
                        spreadRadius: 1 + 3 * _float.value,
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hi, I\'m PeriodBot 👋',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Ask me anything about periods, hygiene and reproductive health.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: scheme.onSurface.withOpacity(0.65),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'TRY ASKING',
              style: TextStyle(
                fontSize: 11.5,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in _suggestions) _suggestionChip(s, scheme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Compact row of quick questions above the composer.
  Widget _buildSuggestionRow(ColorScheme scheme) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Center(child: _suggestionChip(_suggestions[i], scheme)),
      ),
    );
  }

  /// The search / message bar pinned to the bottom.
  Widget _buildComposer(ColorScheme scheme, bool isLoading) {
    final hasText = _controller.text.trim().isNotEmpty;
    final canSend = hasText && !isLoading;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: scheme.primary.withOpacity(_focused ? 0.7 : 0.2),
                  width: _focused ? 1.8 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(_focused ? 0.18 : 0.08),
                    blurRadius: _focused ? 20 : 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: Icon(Icons.auto_awesome,
                        size: 20, color: scheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    // Enter sends, Shift+Enter adds a new line
                    child: CallbackShortcuts(
                      bindings: {
                        const SingleActivator(LogicalKeyboardKey.enter):
                        _submit,
                      },
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        inputFormatters: [LengthLimitingTextInputFormatter(500)],
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Ask PeriodBot a question...',
                          hintStyle: TextStyle(
                            color: scheme.onSurface.withOpacity(0.45),
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          isDense: true,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ),
                  if (hasText)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: IconButton(
                        tooltip: 'Clear',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(Icons.close_rounded,
                            size: 20,
                            color: scheme.onSurface.withOpacity(0.5)),
                        onPressed: _controller.clear,
                      ),
                    ),
                  const SizedBox(width: 2),
                  // Send button
                  GestureDetector(
                    onTap: canSend ? _submit : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: canSend ? _brandGradient(scheme) : null,
                        color: canSend
                            ? null
                            : scheme.onSurface.withOpacity(0.1),
                        boxShadow: canSend
                            ? [
                          BoxShadow(
                            color: scheme.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                            : null,
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: scheme.primary,
                          ),
                        )
                            : Icon(
                          Icons.arrow_upward_rounded,
                          color: canSend
                              ? Colors.white
                              : scheme.onSurface.withOpacity(0.35),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'AI assistant. Not a substitute for medical advice.',
              style: TextStyle(
                fontSize: 10.5,
                color: scheme.onSurface.withOpacity(0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final geminiProvider = Provider.of<GeminiProvider>(context);
    final scheme = Theme.of(context).colorScheme;
    final isLoading = geminiProvider.isLoading;
    final responses = geminiProvider.responses;

    // While loading, one extra item (the "thinking" bubble) sits at the bottom.
    final extra = isLoading ? 1 : 0;
    final isEmpty = responses.isEmpty && !isLoading;
    final historyLoading =
        geminiProvider.isHistoryLoading && responses.isEmpty && !isLoading;

    final showSuggestionRow =
        !isEmpty && !isLoading && _controller.text.trim().isEmpty;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _botAvatar(scheme, 32),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PeriodBot',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                Text(
                  isLoading ? 'Thinking...' : 'Menstrual health helper',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isLoading
                        ? scheme.primary
                        : scheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: responses.isEmpty ? null : _confirmClearAll,
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
              Expanded(
                child: historyLoading
                    ? _buildHistoryLoading(scheme)
                    : isEmpty
                    ? _buildEmptyState(scheme)
                // reverse: the newest message (index 0) sits at the bottom
                    : ListView.builder(
                  reverse: true,
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: responses.length + extra,
                  itemBuilder: (ctx, i) {
                    // Bottom item while loading = the thinking bubble
                    if (isLoading && i == 0) {
                      return _PopIn(
                        key: const ValueKey('thinking'),
                        animate: true,
                        child: _ThinkingItem(
                          userQuery: geminiProvider.pendingQuery ?? '',
                        ),
                      );
                    }

                    // Real index in the responses list
                    final index = i - extra;
                    final response = responses[index];

                    // Show a "Today / Yesterday / date" pill when this
                    // message is from a different day than the one above
                    final created =
                    geminiProvider.createdAtOf(response);
                    final older = index + 1 < responses.length
                        ? geminiProvider.createdAtOf(responses[index + 1])
                        : null;
                    final showDate = created != null &&
                        (older == null || !_sameDay(created, older));

                    return _PopIn(
                      // Keeps each message's expanded/collapsed state
                      // attached to it when the list shifts.
                      key: ObjectKey(response),
                      animate: index == 0,
                      child: _ConversationItem(
                        dateLabel:
                        showDate ? _dateLabel(created) : null,
                        userQuery: response.userQuery,
                        answer: response.answer,
                        onCopy: _copy,
                        onDelete: () => _delete(index),
                      ),
                    );
                  },
                ),
              ),
              if (showSuggestionRow) ...[
                _buildSuggestionRow(scheme),
                const SizedBox(height: 4),
              ],
              _buildComposer(scheme, isLoading),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and slides a message in once, when it first appears.
class _PopIn extends StatefulWidget {
  final bool animate;
  final Widget child;

  const _PopIn({super.key, required this.animate, required this.child});

  @override
  State<_PopIn> createState() => _PopInState();
}

class _PopInState extends State<_PopIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: widget.animate ? 0 : 1,
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    if (widget.animate) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// The user's question as a gradient chat bubble on the right.
class _UserBubble extends StatelessWidget {
  final String text;

  const _UserBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final maxWidth = MediaQuery.of(context).size.width * 0.78;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: math.min(maxWidth, 480)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, const Color(0xFF6D28D9), 0.65)!,
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(6),
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _smallAvatar(ColorScheme scheme) {
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          scheme.primary,
          Color.lerp(scheme.primary, const Color(0xFF6D28D9), 0.65)!,
        ],
      ),
    ),
    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 18),
  );
}

/// One question and its answer.
class _ConversationItem extends StatelessWidget {
  final String userQuery;
  final String answer;
  final String? dateLabel;
  final void Function(String text) onCopy;
  final VoidCallback onDelete;

  const _ConversationItem({
    required this.userQuery,
    required this.answer,
    required this.onCopy,
    required this.onDelete,
    this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (dateLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: scheme.onSurface.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  dateLabel!,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ),
          _UserBubble(text: userQuery),
          const SizedBox(height: 10),
          _BotBubble(answer: answer, onCopy: onCopy, onDelete: onDelete),
        ],
      ),
    );
  }
}

/// PeriodBot's answer. Long answers are shortened with a "Read more" button.
class _BotBubble extends StatefulWidget {
  final String answer;
  final void Function(String text) onCopy;
  final VoidCallback onDelete;

  const _BotBubble({
    required this.answer,
    required this.onCopy,
    required this.onDelete,
  });

  @override
  State<_BotBubble> createState() => _BotBubbleState();
}

class _BotBubbleState extends State<_BotBubble> {
  /// How many lines of the answer show before "Read more".
  static const int _collapsedLines = 2;

  static const TextStyle _answerStyle = TextStyle(fontSize: 15.5, height: 1.4);

  bool _expanded = false;

  String get _cleanAnswer => widget.answer
      .replaceAll('*', '')
      .replaceAll('#', '')
      .replaceAll('•', '')
      .trim();

  Widget _miniAction(
      IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final answerText = _cleanAnswer;
    final muted = scheme.onSurface.withOpacity(0.55);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _smallAvatar(scheme),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () => widget.onCopy(answerText),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(6),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    border:
                    Border.all(color: scheme.primary.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Work out whether the answer is long enough to need
                      // collapsing. Short answers show fully with no button.
                      final painter = TextPainter(
                        text: TextSpan(text: answerText, style: _answerStyle),
                        maxLines: _collapsedLines,
                        textDirection: Directionality.of(context),
                        textScaler: MediaQuery.textScalerOf(context),
                      )..layout(maxWidth: constraints.maxWidth);

                      final isLong = painter.didExceedMaxLines;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: Alignment.topCenter,
                            child: Text(
                              answerText,
                              style: _answerStyle,
                              maxLines: (isLong && !_expanded)
                                  ? _collapsedLines
                                  : null,
                              overflow: (isLong && !_expanded)
                                  ? TextOverflow.ellipsis
                                  : TextOverflow.visible,
                            ),
                          ),
                          if (isLong)
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 34),
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                              onPressed: () =>
                                  setState(() => _expanded = !_expanded),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _expanded ? 'Show less' : 'Read more',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Icon(
                                    _expanded
                                        ? Icons.keyboard_arrow_up_rounded
                                        : Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                            )
                          else
                            const SizedBox(height: 4),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _miniAction(Icons.copy_rounded, 'Copy',
                            () => widget.onCopy(answerText), muted),
                    _miniAction(Icons.delete_outline_rounded, 'Delete',
                        widget.onDelete, Colors.red.shade400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shown at the bottom while PeriodBot is working: the question that was just
/// asked and a bubble with bouncing dots.
class _ThinkingItem extends StatefulWidget {
  final String userQuery;

  const _ThinkingItem({required this.userQuery});

  @override
  State<_ThinkingItem> createState() => _ThinkingItemState();
}

class _ThinkingItemState extends State<_ThinkingItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Widget _dot(int i, Color color) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, _) {
        final t = math.sin(2 * math.pi * (_bounce.value - i * 0.15));
        final lift = t > 0 ? t : 0.0;
        return Transform.translate(
          offset: Offset(0, -5 * lift),
          child: Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.4 + 0.6 * lift),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          if (widget.userQuery.isNotEmpty) ...[
            _UserBubble(text: widget.userQuery),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _smallAvatar(scheme),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border.all(color: scheme.primary.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++) _dot(i, scheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'PeriodBot is thinking',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface.withOpacity(0.6),
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
}
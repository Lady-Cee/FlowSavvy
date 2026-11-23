import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/gemini_provider.dart';

class GeminiSearchScreen extends StatefulWidget {
  @override
  _GeminiSearchScreenState createState() => _GeminiSearchScreenState();
}

class _GeminiSearchScreenState extends State<GeminiSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitQuery(BuildContext context) {
    final provider = Provider.of<GeminiProvider>(context, listen: false);

    // Don't clear the text if a request is already running
    if (provider.isLoading) return;

    final query = _controller.text.trim();
    if (query.isNotEmpty) {
      provider.getGeminiResponse(query);
      _controller.clear();
      FocusScope.of(context).unfocus(); // Close keyboard
    }
  }

  @override
  Widget build(BuildContext context) {
    final geminiProvider = Provider.of<GeminiProvider>(context);
    final appColor = Theme.of(context).colorScheme;
    final isLoading = geminiProvider.isLoading;
    final responses = geminiProvider.responses;

    // While loading, one extra item (the "thinking" card) sits at the top.
    final extra = isLoading ? 1 : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Menstrual Hygiene Info'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: geminiProvider.clearResponses,
            tooltip: "Clear All",
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Ask a question...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _submitQuery(context),
                    maxLines: 3,
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    color: isLoading
                        ? appColor.primary.withOpacity(0.5)
                        : appColor.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: isLoading ? null : () => _submitQuery(context),
                    icon: Icon(Icons.search, color: appColor.secondary),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: (responses.isEmpty && !isLoading)
                ? Center(child: Text('Ask a question to get started'))
                : ListView.builder(
              itemCount: responses.length + extra,
              itemBuilder: (ctx, i) {
                // First item while loading = the thinking card
                if (isLoading && i == 0) {
                  return _ThinkingCard(
                    key: ValueKey('thinking-card'),
                    userQuery: geminiProvider.pendingQuery ?? '',
                  );
                }

                // Real index in the responses list
                final index = i - extra;
                final response = responses[index];

                return _ResponseCard(
                  // Keeps each card's expanded/collapsed state attached
                  // to its own response when the list shifts.
                  key: ObjectKey(response),
                  userQuery: response.userQuery,
                  answer: response.answer,
                  onDelete: () {
                    final provider = Provider.of<GeminiProvider>(
                      context,
                      listen: false,
                    );

                    // remove and keep a copy
                    final deletedResponse =
                    provider.removeResponseAt(index);

                    // show snackbar with undo
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Record deleted"),
                        backgroundColor: appColor.primary,
                        action: SnackBarAction(
                          label: "Undo",
                          textColor: Colors.white,
                          onPressed: () {
                            // re-insert at the same position
                            provider.insertResponseAt(
                                index, deletedResponse);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Card shown at the top of the list while PeriodBot is working.
/// Shows the question that was just asked, a pulsing "thinking" label and
/// pulsing placeholder lines where the answer will appear.
class _ThinkingCard extends StatefulWidget {
  final String userQuery;

  const _ThinkingCard({super.key, required this.userQuery});

  @override
  State<_ThinkingCard> createState() => _ThinkingCardState();
}

class _ThinkingCardState extends State<_ThinkingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _skeletonLine(Color color, {double widthFactor = 1.0}) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    final skeletonColor = appColor.primary.withOpacity(0.18);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: appColor.primary.withOpacity(0.5),
          width: 1,
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You asked:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(widget.userQuery, style: TextStyle(fontSize: 16)),
            SizedBox(height: 14),
            FadeTransition(
              opacity: _opacity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 20, color: appColor.primary),
                      SizedBox(width: 8),
                      Text(
                        "PeriodBot is thinking...",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: appColor.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  _skeletonLine(skeletonColor),
                  _skeletonLine(skeletonColor, widthFactor: 0.85),
                  _skeletonLine(skeletonColor, widthFactor: 0.6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One question + answer card. The answer is shortened to a few lines with a
/// "Read more" button, and expands when tapped.
class _ResponseCard extends StatefulWidget {
  final String userQuery;
  final String answer;
  final VoidCallback onDelete;

  const _ResponseCard({
    super.key,
    required this.userQuery,
    required this.answer,
    required this.onDelete,
  });

  @override
  State<_ResponseCard> createState() => _ResponseCardState();
}

class _ResponseCardState extends State<_ResponseCard> {
  /// How many lines of the answer show before "Read more".
  static const int _collapsedLines = 2;

  static const TextStyle _answerStyle = TextStyle(fontSize: 16);

  bool _expanded = false;

  String get _cleanAnswer => widget.answer
      .replaceAll('*', '')
      .replaceAll('#', '')
      .replaceAll('•', '')
      .trim();

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    final answerText = _cleanAnswer;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: appColor.primary.withOpacity(0.5),
          width: 1,
        ),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "You asked:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(widget.userQuery, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              "PeriodBot:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            LayoutBuilder(
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
                    GestureDetector(
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: answerText));

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Response copied"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: AnimatedSize(
                        duration: Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        alignment: Alignment.topCenter,
                        child: Text(
                          answerText,
                          style: _answerStyle,
                          maxLines:
                          (isLong && !_expanded) ? _collapsedLines : null,
                          overflow: (isLong && !_expanded)
                              ? TextOverflow.ellipsis
                              : TextOverflow.visible,
                        ),
                      ),
                    ),
                    if (isLong)
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () =>
                            setState(() => _expanded = !_expanded),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_expanded ? 'Show less' : 'Read more'),
                            Icon(
                              _expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: widget.onDelete,
        ),
      ),
    );
  }
}
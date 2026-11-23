import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/gemini_response_model.dart';

class GeminiProvider with ChangeNotifier {
  final List<GeminiResponseModel> _responses = [];

  List<GeminiResponseModel> get responses => [..._responses];

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _pendingQuery;
  String? get pendingQuery => _pendingQuery;

  // ---------------------------------------------------------------------------
  // CONFIG
  // ---------------------------------------------------------------------------

  /// Name of the variable in your .env file that holds the Gemini key.
  /// Change this if your .env uses a different name.
  static const String _apiKeyEnvName = 'GEMINI_API_KEY';

  /// Models are tried in order. If one keeps failing with a temporary error
  /// (503 / 429 / timeout), the next one is used.
  static const List<String> _models = [
    'gemini-3.8-flash',
    'gemini-3.5-flash-lite',
    'gemini-2.5-flash',
  ];

  static const int _maxAttemptsPerModel = 2;
  static const Duration _initialRetryDelay = Duration(seconds: 2);
  static const Duration _requestTimeout = Duration(seconds: 45);

  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // ---------------------------------------------------------------------------
  // PUBLIC API
  // ---------------------------------------------------------------------------

  Future<void> getGeminiResponse(String query) async {
    // Ignore taps while a request is already running
    if (_isLoading) return;

    _isLoading = true;
    _pendingQuery = query;
    notifyListeners();

    try {
      final prompt = _buildPrompt(query);
      final answer = await _generateWithFallback(prompt);

      _responses.insert(
        0,
        GeminiResponseModel(
          userQuery: query,
          answer: (answer == null || answer.isEmpty)
              ? 'Sorry, no response available. Please try rephrasing your question.'
              : answer,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('GEMINI ERROR: $e');
      debugPrint('GEMINI STACK TRACE: $stackTrace');

      _responses.insert(
        0,
        GeminiResponseModel(
          userQuery: query,
          answer: _friendlyError(e),
        ),
      );
    } finally {
      _isLoading = false;
      _pendingQuery = null;
      notifyListeners();
    }
  }

  void clearResponses() {
    _responses.clear();
    notifyListeners();
  }

  // Returns the removed item so it can be restored (Undo).
  GeminiResponseModel removeResponseAt(int index) {
    final removed = _responses.removeAt(index);
    notifyListeners();
    return removed;
  }

  void insertResponseAt(int index, GeminiResponseModel response) {
    if (index < 0 || index > _responses.length) {
      _responses.add(response);
    } else {
      _responses.insert(index, response);
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // INTERNALS
  // ---------------------------------------------------------------------------

  String _buildPrompt(String query) {
    return """
You are PeriodBot, the AI assistant for PeriodReal.

PeriodReal helps girls, young women, schools, and NGOs improve menstrual health awareness and support.

Guidelines:
- Do not greet the user or introduce yourself. Start answering the question directly.
- Do not say "Hello" or mention your name unless the user asks who you are.
- Respond in plain English.
- Use a friendly and supportive tone.
- Keep answers clear and easy to understand.
- Do not use markdown.
- Do not use *, **, #, -, bullet points, or special formatting.
- Do not use headings.
- Use short paragraphs.
- Keep responses concise.
- Focus on menstrual health, menstrual hygiene, periods, reproductive health, and menopause.

User Question:
$query
""";
  }

  /// Calls one specific model directly through the Gemini REST API,
  /// so the model name you set here is the model that is really used.
  Future<String?> _callModel(String model, String prompt) async {
    final apiKey = dotenv.env[_apiKeyEnvName] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('API key missing: $_apiKeyEnvName not found in .env');
    }

    final uri = Uri.parse('$_baseUrl/$model:generateContent');

    final res = await http
        .post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
      }),
    )
        .timeout(_requestTimeout);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;

    // Prompt was blocked before generation
    final blockReason = data['promptFeedback']?['blockReason'];
    if (blockReason != null) {
      throw Exception('BLOCKED: $blockReason');
    }

    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return null;

    final parts = candidates[0]?['content']?['parts'] as List?;
    if (parts == null || parts.isEmpty) return null;

    // Join all text parts (some models return the answer in several parts)
    final text = parts
        .map((p) => (p is Map ? p['text'] : null)?.toString() ?? '')
        .join()
        .trim();

    return text;
  }

  /// Tries each model in order, retrying temporary errors with backoff.
  Future<String?> _generateWithFallback(String prompt) async {
    Object? lastError;

    for (final model in _models) {
      var delay = _initialRetryDelay;

      for (var attempt = 1; attempt <= _maxAttemptsPerModel; attempt++) {
        try {
          return await _callModel(model, prompt);
        } catch (e) {
          lastError = e;
          debugPrint('GEMINI [$model] attempt $attempt failed: $e');

          // A missing or removed model: skip straight to the next one
          if (_isModelNotFound(e)) break;

          // Errors retrying will not fix (bad key, blocked prompt...): stop
          if (!_isRetryable(e)) rethrow;

          if (attempt < _maxAttemptsPerModel) {
            await Future.delayed(delay);
            delay *= 2; // 2s, 4s ...
          }
        }
      }
      // This model kept failing, fall through to the next one
    }

    throw lastError ?? Exception('All Gemini models are unavailable');
  }

  bool _isModelNotFound(Object e) {
    final msg = e.toString().toLowerCase();
    return msg.contains('http 404') ||
        (msg.contains('not found') && msg.contains('model'));
  }

  /// Temporary problems worth retrying.
  bool _isRetryable(Object e) {
    if (e is TimeoutException) return true;
    final msg = e.toString().toLowerCase();
    return msg.contains('http 503') ||
        msg.contains('http 429') ||
        msg.contains('http 500') ||
        msg.contains('http 502') ||
        msg.contains('http 504') ||
        msg.contains('unavailable') ||
        msg.contains('overloaded') ||
        msg.contains('resource_exhausted');
  }

  /// Turns an exception into a message the user can understand.
  String _friendlyError(Object e) {
    if (e is TimeoutException) {
      return 'The request took too long. Please check your connection and try again.';
    }

    final msg = e.toString().toLowerCase();

    if (msg.contains('api key missing')) {
      return 'PeriodBot is not set up correctly right now. Please contact support.';
    }
    if (msg.contains('blocked')) {
      return 'I am not able to answer that question. Please try asking it in a different way.';
    }
    if (msg.contains('http 503') ||
        msg.contains('overloaded') ||
        msg.contains('unavailable')) {
      return 'PeriodBot is very busy right now. Please try again in a minute.';
    }
    if (msg.contains('http 429') ||
        msg.contains('quota') ||
        msg.contains('resource_exhausted')) {
      return 'PeriodBot has received too many requests. Please try again shortly.';
    }
    if (msg.contains('api key') ||
        msg.contains('http 401') ||
        msg.contains('http 403') ||
        msg.contains('permission')) {
      return 'PeriodBot is not set up correctly right now. Please contact support.';
    }
    if (msg.contains('http 404') || msg.contains('not found')) {
      return 'PeriodBot is being updated. Please try again later.';
    }
    if (msg.contains('socket') ||
        msg.contains('network') ||
        msg.contains('connection') ||
        msg.contains('clientexception') ||
        msg.contains('failed to fetch')) {
      return 'Unable to connect. Please check your internet connection and try again.';
    }

    return 'Sorry, I am unable to answer your question right now. Please try again later.';
  }
}
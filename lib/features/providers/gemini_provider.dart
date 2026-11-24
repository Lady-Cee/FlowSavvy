import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/gemini_response_model.dart';

class GeminiProvider with ChangeNotifier {
  // Newest first (index 0 = most recent question)
  final List<GeminiResponseModel> _responses = [];

  /// Only ever shows the chats of the user who is signed in right now, so one
  /// person's questions are never visible to the next person who logs in.
  List<GeminiResponseModel> get responses =>
      _historyUid == FirebaseAuth.instance.currentUser?.uid
          ? [..._responses]
          : const [];

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

  /// How many past messages are loaded from Firebase when the chat opens.
  static const int _historyLimit = 200;

  // ---------------------------------------------------------------------------
  // CHAT HISTORY (saved in Firebase under the signed-in user)
  //   users/{uid}/gemini_chats/{chatId}
  //     userQuery: String, answer: String, createdAt: Timestamp
  // ---------------------------------------------------------------------------

  /// The user whose chats are currently held in memory.
  String? _historyUid;

  /// The user whose history has already been loaded from Firebase.
  String? _loadedForUid;

  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  // The model class has no id / date fields, so they are kept on the side.
  final Map<GeminiResponseModel, String> _docIds = Map.identity();
  final Map<GeminiResponseModel, DateTime> _createdAt = Map.identity();

  /// When a message was asked (null if unknown).
  DateTime? createdAtOf(GeminiResponseModel m) => _createdAt[m];

  CollectionReference<Map<String, dynamic>>? _chatCollection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('gemini_chats');
  }

  /// Makes sure the chats in memory belong to the signed-in user. If someone
  /// else was using the app before, their chats are dropped.
  String? _syncOwner() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_historyUid != uid) {
      _responses.clear();
      _docIds.clear();
      _createdAt.clear();
      _historyUid = uid;
      _loadedForUid = null;
    }
    return uid;
  }

  /// Loads the signed-in user's saved chats from Firebase. Safe to call every
  /// time the chat screen opens: it only loads once per user.
  Future<void> loadHistory({bool force = false}) async {
    final uid = _syncOwner();
    if (uid == null) {
      notifyListeners();
      return;
    }
    if (_loadedForUid == uid && !force) return;
    if (_isHistoryLoading) return;

    final col = _chatCollection();
    if (col == null) return;

    _isHistoryLoading = true;
    notifyListeners();

    try {
      final snap = await col
          .orderBy('createdAt', descending: true)
          .limit(_historyLimit)
          .get();

      // The user changed while we were loading: throw this result away
      if (FirebaseAuth.instance.currentUser?.uid != uid) return;

      final loaded = <GeminiResponseModel>[];
      final loadedIds = <String>{};

      for (final d in snap.docs) {
        final data = d.data();
        final q = data['userQuery'];
        final a = data['answer'];
        if (q is! String || a is! String) continue;

        final m = GeminiResponseModel(userQuery: q, answer: a);
        _docIds[m] = d.id;
        final ts = data['createdAt'];
        if (ts is Timestamp) _createdAt[m] = ts.toDate();

        loaded.add(m);
        loadedIds.add(d.id);
      }

      // Keep anything asked while the history was still loading
      final extras = _responses.where((r) {
        final id = _docIds[r];
        return id == null || !loadedIds.contains(id);
      }).toList();

      _responses
        ..clear()
        ..addAll(extras)
        ..addAll(loaded);

      _loadedForUid = uid;
    } catch (e) {
      debugPrint('GEMINI HISTORY LOAD ERROR: $e');
    } finally {
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  /// Call on logout if you want the chats removed from memory straight away.
  void resetChats() {
    _responses.clear();
    _docIds.clear();
    _createdAt.clear();
    _historyUid = null;
    _loadedForUid = null;
    notifyListeners();
  }

  /// Saves a new question and answer. Not awaited: the chat shows instantly,
  /// and Firebase syncs in the background (also works offline).
  void _saveToFirestore(GeminiResponseModel m) {
    final col = _chatCollection();
    if (col == null) return;

    final ref = col.doc();
    final now = DateTime.now();
    _docIds[m] = ref.id;
    _createdAt[m] = now;

    ref.set({
      'userQuery': m.userQuery,
      'answer': m.answer,
      'createdAt': Timestamp.fromDate(now),
    }).catchError((Object e) {
      debugPrint('GEMINI SAVE ERROR: $e');
    });
  }

  void _deleteFromFirestore(GeminiResponseModel m) {
    final col = _chatCollection();
    final id = _docIds[m];
    if (col == null || id == null) return;

    col.doc(id).delete().catchError((Object e) {
      debugPrint('GEMINI DELETE ERROR: $e');
    });
  }

  Future<void> _deleteAllFromFirestore() async {
    final col = _chatCollection();
    if (col == null) return;

    try {
      final snap = await col.get();
      var batch = FirebaseFirestore.instance.batch();
      var count = 0;

      for (final d in snap.docs) {
        batch.delete(d.reference);
        count++;
        if (count == 400) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
          count = 0;
        }
      }
      if (count > 0) await batch.commit();

      _docIds.clear();
      _createdAt.clear();
    } catch (e) {
      debugPrint('GEMINI CLEAR ERROR: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // PUBLIC API
  // ---------------------------------------------------------------------------

  Future<void> getGeminiResponse(String query) async {
    // Ignore taps while a request is already running
    if (_isLoading) return;

    _syncOwner();

    _isLoading = true;
    _pendingQuery = query;
    notifyListeners();

    try {
      final prompt = _buildPrompt(query);
      final answer = await _generateWithFallback(prompt);

      if (answer == null || answer.isEmpty) {
        // Not saved: this is not a real answer
        _responses.insert(
          0,
          GeminiResponseModel(
            userQuery: query,
            answer:
            'Sorry, no response available. Please try rephrasing your question.',
          ),
        );
      } else {
        final result = GeminiResponseModel(userQuery: query, answer: answer);
        _responses.insert(0, result);
        _saveToFirestore(result); // keep it in the user's history
      }
    } catch (e, stackTrace) {
      debugPrint('GEMINI ERROR: $e');
      debugPrint('GEMINI STACK TRACE: $stackTrace');

      // Not saved: error messages should not clutter the history
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
    _deleteAllFromFirestore();
  }

  // Returns the removed item so it can be restored (Undo).
  GeminiResponseModel removeResponseAt(int index) {
    final removed = _responses.removeAt(index);
    notifyListeners();
    _deleteFromFirestore(removed);
    return removed;
  }

  void insertResponseAt(int index, GeminiResponseModel response) {
    if (index < 0 || index > _responses.length) {
      _responses.add(response);
    } else {
      _responses.insert(index, response);
    }
    notifyListeners();

    // Undo: put the saved copy back with its original id and date
    final col = _chatCollection();
    final id = _docIds[response];
    if (col != null && id != null) {
      col.doc(id).set({
        'userQuery': response.userQuery,
        'answer': response.answer,
        'createdAt':
        Timestamp.fromDate(_createdAt[response] ?? DateTime.now()),
      }).catchError((Object e) {
        debugPrint('GEMINI RESTORE ERROR: $e');
      });
    }
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
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import '../models/gemini_response_model.dart';

class GeminiProvider with ChangeNotifier {
  final List<GeminiResponseModel> _responses = [];

  List<GeminiResponseModel> get responses => [..._responses];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getGeminiResponse(String query) async {
    _isLoading = true;
    notifyListeners();

    // try {
    //   final gemini = Gemini.instance;
    //   final response = await gemini.text(query);
    //
    //   final answer = response?.output ?? 'Sorry, no response available.';
    //   final result = GeminiResponseModel(userQuery: query, answer: answer);
    //   _responses.insert(0, result);
    // } catch (e) {
    //   _responses.insert(
    //     0,
    //     GeminiResponseModel(userQuery: query, answer: 'Error: $e'),
    //   );
    // }

    try {
      final gemini = Gemini.instance;
      final response = await gemini.text(query);

      print('Gemini response: ${response?.output}');

      final answer = response?.output ?? 'Sorry, no response available.';
      final result = GeminiResponseModel(userQuery: query, answer: answer);
      _responses.insert(0, result);
    } catch (e) {
      print('Gemini error: $e'); // ✅ Print the error for debugging
      _responses.insert(
        0,
        GeminiResponseModel(userQuery: query, answer: 'Error: $e'),
      );
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResponses() {
    _responses.clear();
    notifyListeners();
  }
}



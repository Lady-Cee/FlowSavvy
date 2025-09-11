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

    try {
      final gemini = Gemini.instance;
      final response = await gemini.text(query);

      //  Print the raw Gemini response to debug
      // print('Gemini response: ${response?.output}');

      final answer = response?.output ?? 'Sorry, no response available.';
      final result = GeminiResponseModel(userQuery: query, answer: answer);
      _responses.insert(0, result);
    } catch (e, stack) {
      // print('Gemini error: $e'); // ✅ Print the error for debugging
      // print("Stack Trace: $stack");
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


  // // returns nothing - hence the item deleted cannot be restored.
  // void deleteResponse(int index) {
  //   _responses.removeAt(index);
  //   notifyListeners();
  // }

  // returns the removed item - hence it can be restored.
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


}



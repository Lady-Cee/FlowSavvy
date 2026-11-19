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

      final prompt = """
You are PeriodBot, the AI assistant for PeriodReal.

PeriodReal helps girls, young women, schools, and NGOs improve menstrual health awareness and support.

Guidelines:
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

      final response = await gemini.text(prompt);

      final answer =
          response?.output?.trim() ?? 'Sorry, no response available.';

      final result = GeminiResponseModel(
        userQuery: query,
        answer: answer,
      );

      _responses.insert(0, result);
    } catch (e) {
      _responses.insert(
        0,
        GeminiResponseModel(
          userQuery: query,
          answer:
          'Sorry, I am unable to answer your question right now. Please try again later.',
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  // Future<void> getGeminiResponse(String query) async {
  //   _isLoading = true;
  //   notifyListeners();
  //
  //   try {
  //     final gemini = Gemini.instance;
  //     final response = await gemini.text(query);
  //
  //     //  Print the raw Gemini response to debug
  //     // print('Gemini response: ${response?.output}');
  //
  //     final answer = response?.output ?? 'Sorry, no response available.';
  //     final result = GeminiResponseModel(userQuery: query, answer: answer);
  //     _responses.insert(0, result);
  //   } catch (e, stack) {
  //     // print('Gemini error: $e'); // ✅ Print the error for debugging
  //     // print("Stack Trace: $stack");
  //     _responses.insert(
  //       0,
  //       GeminiResponseModel(userQuery: query, answer: 'Error: $e'),
  //     );
  //   }
  //   finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

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



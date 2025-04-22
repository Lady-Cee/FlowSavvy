import 'package:flutter/material.dart';
import '../models/symptom_log.dart';

class SymptomLogProvider with ChangeNotifier {
  final List<SymptomLog> _logs = [];

  List<SymptomLog> get logs => [..._logs];

  void addLog(SymptomLog log) {
    _logs.add(log);
    notifyListeners();
  }
}

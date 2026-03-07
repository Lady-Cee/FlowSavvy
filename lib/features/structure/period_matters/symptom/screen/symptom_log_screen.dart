import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../models/symptom_log.dart';
import '../../../../providers/symptom_log_provider.dart';
import '../../../../widgets/long_custom_button.dart';

class SymptomLogScreen extends StatefulWidget {
  @override
  _SymptomLogScreenState createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends State<SymptomLogScreen> {
  DateTime _selectedDate = DateTime.now();
  List<String> _selectedSymptoms = [];
  List<String> _selectedMood = [];
  int _painLevel = 0;
  List<String> _suggestedRemedies = [];

  final Map<String, String> moodEmojis = {
    'Happy': '😊',
    'Sad': '😢',
    'Anxious': '😰',
    'Irritable': '😠',
    'Calm': '😌',
  };

  final Map<String, List<String>> _remedySuggestions = {
    'Cramps': ['Hot water bottle', 'Gentle yoga', 'Chamomile tea', 'Warm bath', 'Stretching'],
    'Headache': ['Ibuprofen', 'Rest', 'Cool compress', 'Hydration', 'Lavender oil'],
    'Back Pain': ['Stretching', 'Warm bath', 'Posture correction', 'Massage', 'Heat pack'],
    'Nausea': ['Ginger tea', 'Peppermint', 'Small frequent meals', 'Stay hydrated', 'Avoid spicy food'],
    'Fatigue': ['Vitamin B', 'Iron-rich food', 'Power nap', 'Gentle walk', 'Stay hydrated'],
    'Acne': ['Tea tree oil', 'Aloe vera', 'Witch hazel', 'Zinc supplements', 'Benzoyl peroxide'],
    'Mood Swings': ['Meditation', 'Breathing exercises', 'Journaling', 'Warm bath', 'Support groups'],
    'Bloating': ['Fennel tea', 'Peppermint tea', 'Avoid carbonated drinks', 'Probiotics', 'Eat slowly'],
    'Diarrhea': ['Oral rehydration salts', 'Bananas', 'Rice', 'Yogurt', 'Chamomile tea'],
    'Tender Breasts': ['Cold compress', 'Supportive bra', 'Vitamin E', 'Massage', 'Reduce caffeine'],
  };

  final Map<String, String> _motivations = {
    'Cramps': 'You are stronger than the pain. Hang in there!',
    'Headache': 'Take it easy, your peace of mind matters.',
    'Back Pain': 'Rest and reset. You’ve got this.',
    'Nausea': 'Breathe and relax, better moments are coming.',
    'Fatigue': 'Rest is productive too. Recharge and rise.',
    'Acne': 'Your skin doesn’t define you. You’re beautiful.',
    'Mood Swings': 'Emotions are valid. You’re doing your best.',
    'Bloating': 'This too shall pass. Stay gentle with yourself.',
    'Diarrhea': 'Take it slow, your body is healing.',
    'Tender Breasts': 'Comfort is key. Treat yourself with care.',
  };

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<SymptomLogProvider>(context, listen: false).fetchLogs());
  }

  void _updateSuggestions() {
    final remedies = <String>{};
    for (var symptom in _selectedSymptoms) {
      remedies.addAll(_remedySuggestions[symptom] ?? []);
    }
    _suggestedRemedies = remedies.toList();
  }

  String _getMotivation() {
    if (_selectedSymptoms.isEmpty) return 'Take care of yourself today.';
    return _motivations[_selectedSymptoms.first] ?? 'You are doing great. Keep going!';
  }

  void _saveLog() async {
    if (_selectedSymptoms.isEmpty || _selectedMood.isEmpty || _painLevel == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one symptom, mood, and pain level'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _updateSuggestions();

    final log = SymptomLog(
      id: '', // Will be set in provider
      date: _selectedDate,
      symptoms: List.from(_selectedSymptoms),
      mood: List.from(_selectedMood),
      painLevel: _painLevel,
      remedies: List.from(_suggestedRemedies),
      motivation: _getMotivation(),
    );

    await Provider.of<SymptomLogProvider>(context, listen: false).addLog(log);

    setState(() {
      _selectedSymptoms.clear();
      _selectedMood.clear();
      _painLevel = 0;
      _suggestedRemedies.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Symptom log saved successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteLog(SymptomLog log) {
    final provider = Provider.of<SymptomLogProvider>(context, listen: false);

    provider.hideLog(log.id);

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    bool undoTapped = false;

    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text("Log deleted"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: "Undo",
          textColor: Colors.white,
          onPressed: () {
            undoTapped = true;
            provider.restoreLog(log.id);
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );

    // ✅ Force close after 4s regardless of Flutter's internal timer
    Future.delayed(Duration(seconds: 4), () {
      messenger.hideCurrentSnackBar();
      if (!undoTapped) {
        provider.removeLog(log.id);
      }
    });

    controller.closed.then((reason) {
      if (reason != SnackBarClosedReason.action && !undoTapped) {
        provider.removeLog(log.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColor = Theme.of(context).colorScheme;
    final logs = Provider.of<SymptomLogProvider>(context).logs;

    return Scaffold(
      appBar: AppBar(title: Text('Symptom Log')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              Text('Select Date:'),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDate = pickedDate);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(border: OutlineInputBorder()),
                  child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                ),
              ),

              SizedBox(height: 20),
              // Mood
              Text('How are you feeling today?'),
              SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 12,
                children: moodEmojis.keys.map((mood) {
                  return FilterChip(
                    label: Text('${moodEmojis[mood]} $mood'),
                    selected: _selectedMood.contains(mood),
                    onSelected: (val) {
                      setState(() {
                        _selectedMood.contains(mood)
                            ? _selectedMood.remove(mood)
                            : _selectedMood.add(mood);
                      });
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 16),
              // Symptoms
              Text('Physical Symptoms'),
              SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 12,
                children: _remedySuggestions.keys.map((symptom) {
                  final isSelected = _selectedSymptoms.contains(symptom);
                  return FilterChip(
                    label: Text(symptom),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        isSelected
                            ? _selectedSymptoms.remove(symptom)
                            : _selectedSymptoms.add(symptom);
                      });
                    },
                  );
                }).toList(),
              ),

              SizedBox(height: 16),
              // Pain slider
              Text('Pain Level: $_painLevel'),
              Slider(
                value: _painLevel.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                label: '$_painLevel',
                activeColor: Colors.pink,
                onChanged: (val) => setState(() => _painLevel = val.toInt()),
              ),

              SizedBox(height: 24),
              // Save button
              LongCustomButton(onTap: _saveLog, title: 'Save Log'),
              SizedBox(height: 24),

              // Logs list
              if (logs.isNotEmpty)
                ...logs.map((log) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: appColor.primary.withOpacity(0.5), width: 1),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    title: Text(
                      DateFormat('yMMMd').format(log.date),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Symptoms: ${log.symptoms.join(', ')}'),
                        Text('Mood: ${log.mood.join(', ')}'),
                        Text('Pain Level: ${log.painLevel}'),
                        Text('Remedies: ${log.remedies.join(', ')}'),
                        SizedBox(height: 6),
                        Text(
                          'Motivation: ${log.motivation}',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteLog(log),
                    ),
                  ),
                ))
            ],
          ),
        ),
      ),
    );
  }
}
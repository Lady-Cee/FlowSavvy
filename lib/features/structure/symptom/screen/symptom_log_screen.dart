import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../models/symptom_log.dart';
import '../../../providers/symptom_log_provider.dart';
import '../../../widgets/long_custom_button.dart';

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
  //List<String> _suggestedMedications = [];


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

  // final Map<String, List<String>> _medicationSuggestions = {
  //   'Cramps': ['Paracetamol', 'Ibuprofen', 'Midol', 'Naproxen', 'Buscopan'],
  //   'Headache': ['Ibuprofen', 'Paracetamol', 'Excedrin', 'Aspirin', 'Naproxen'],
  //   'Back Pain': ['Ibuprofen', 'Paracetamol', 'Diclofenac', 'Topical creams', 'Muscle relaxants'],
  //   'Nausea': ['Domperidone', 'Ondansetron', 'Antacids', 'Ginger capsules', 'Meclizine'],
  //   'Fatigue': ['Iron supplement', 'B-complex', 'Multivitamins', 'Folic acid', 'Energy boosters'],
  //   'Acne': ['Benzoyl peroxide', 'Salicylic acid', 'Oral antibiotics', 'Topical retinoids', 'Hormonal therapy'],
  //   'Mood Swings': ['SSRIs', 'Vitamin B6', 'Magnesium', 'St. John’s Wort', 'Evening primrose oil'],
  //   'Bloating': ['Simethicone', 'Activated charcoal', 'Probiotics', 'Antacids', 'Digestive enzymes'],
  //   'Diarrhea': ['Loperamide', 'ORS', 'Probiotics', 'Bismuth subsalicylate', 'Antispasmodics'],
  //   'Tender Breasts': ['Ibuprofen', 'Paracetamol', 'Evening primrose oil', 'Vitamin E', 'Cold compress'],
  // };

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

  void _updateSuggestions() {
    final remedies = <String>{};
    final meds = <String>{};
    for (var symptom in _selectedSymptoms) {
      remedies.addAll(_remedySuggestions[symptom] ?? []);
     // meds.addAll(_medicationSuggestions[symptom] ?? []);
    }
    _suggestedRemedies = remedies.toList();
    //_suggestedMedications = meds.toList();
  }

  String _getMotivation() {
    if (_selectedSymptoms.isEmpty) return 'Take care of yourself today.';
    return _motivations[_selectedSymptoms.first] ?? 'You are doing great. Keep going!';
  }
  void _saveLog() {
    if (_selectedSymptoms.isEmpty ||
        _selectedMood.isEmpty ||
        _selectedDate == null ||
        _painLevel == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one symptom, mood, date and pain level'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _updateSuggestions(); // Ensure remedies/medications are updated

    final log = SymptomLog(
      date: _selectedDate,
      symptoms: List.from(_selectedSymptoms),
      mood: List.from(_selectedMood),
      painLevel: _painLevel,
     // medications: List.from(_suggestedMedications),
      remedies: List.from(_suggestedRemedies),
      motivation: _getMotivation(),
    );

    Provider.of<SymptomLogProvider>(context, listen: false).addLog(log);

    setState(() {
      _selectedSymptoms.clear();
      _selectedMood.clear();
      _painLevel = 0;
      _suggestedRemedies.clear();
    //  _suggestedMedications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Symptom log saved successfully.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // void _saveLog() {
  //   _updateSuggestions(); // Ensure remedies/medications are updated
  //
  //   final log = SymptomLog(
  //     date: _selectedDate,
  //     symptoms: List.from(_selectedSymptoms),
  //     mood: List.from(_selectedMood),
  //     painLevel: _painLevel,
  //     medications: List.from(_suggestedMedications),
  //     remedies: List.from(_suggestedRemedies),
  //     motivation: _getMotivation(),
  //   );
  //
  //   Provider.of<SymptomLogProvider>(context, listen: false).addLog(log);
  //
  //   setState(() {
  //     _selectedSymptoms.clear();
  //     _selectedMood.clear();
  //     _painLevel = 0;
  //     _suggestedRemedies.clear();
  //     _suggestedMedications.clear();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final logs = Provider.of<SymptomLogProvider>(context).logs;
    return Scaffold(
      appBar: AppBar(title: Text('Symptom Log')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                   // labelText: DateFormat('yyyy-MM-dd').format(_selectedDate),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                ),
              ),


              SizedBox(height: 20),
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

              SizedBox(height: 16),
              Text('Pain Level: $_painLevel'),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.pink,         // filled portion
                  inactiveTrackColor: Colors.grey[300],  // unfilled portion
                ),
                child: Slider(
                  value: _painLevel.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  label: '$_painLevel',
                  onChanged: (val) {
                    setState(() {
                      _painLevel = val.toInt();
                    });
                  },
                ),
              ),

              // Slider(
              //   value: _painLevel.toDouble(),
              //   min: 0,
              //   max: 10,
              //   divisions: 10,
              //   label: '$_painLevel',
              //   onChanged: (val) {
              //     setState(() {
              //       _painLevel = val.toInt();
              //     });
              //   },
              // ),
              SizedBox(height: 24),
              LongCustomButton(
                onTap: _saveLog,
                title: 'Save Log',
              ),
              SizedBox(height: 24),
              if (logs.isNotEmpty)
                ...logs.map((log) => Card(
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat('yMMMd').format(log.date),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Symptoms: ${log.symptoms.join(', ')}'),
                        Text('Mood: ${log.mood.join(', ')}'),
                        Text('Pain Level: ${log.painLevel}'),
                        Text('Remedies: ${log.remedies.join(', ')}'),
                       // Text('Medications: ${log.medications.join(', ')}'),
                        SizedBox(height: 8),
                        Text('Motivation: ${log.motivation}',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                      ],
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




import 'package:flutter/material.dart';

import '../models/menopause_model.dart';
// import 'menopause_model.dart';

class MenopauseProvider with ChangeNotifier {
  final List<MenopauseTip> _tips = [
    MenopauseTip(
      title: 'Hot Flashes',
      description: 'Wear lightweight clothes and keep cool. Try deep breathing exercises.',
      icon: '🔥',
    ),
    MenopauseTip(
      title: 'Mood Swings',
      description: 'Stay active, talk to a therapist, and connect with others for support.',
      icon: '😕',
    ),
    MenopauseTip(
      title: 'Sleep Issues',
      description: 'Establish a calming bedtime routine and limit caffeine.',
      icon: '😴',
    ),
    MenopauseTip(
      title: 'Vaginal Dryness',
      description: 'Use vaginal moisturizers or consult a doctor for hormonal options.',
      icon: '💧',
    ),
    MenopauseTip(
      title: 'Weight Management',
      description: 'Maintain a balanced diet and exercise regularly.',
      icon: '🥗',
    ),
    MenopauseTip(
      title: 'Bone Health',
      description: 'Get enough calcium and vitamin D. Consider resistance training.',
      icon: '🦴',
    ),
  ];

  List<MenopauseTip> get tips => _tips;
}

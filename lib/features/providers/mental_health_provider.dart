import 'package:flutter/material.dart';

import '../models/mental_health_professional.dart';

class MentalHealthProvider with ChangeNotifier {
  final List<MentalHealthProfessional> _professionals = [
    MentalHealthProfessional(
      id: '1',
      name: 'Dr. Emily Clark',
      qualification: 'Clinical Psychologist',
      imageUrl: 'https://img.freepik.com/free-photo/medium-shot-smiley-woman-teaching_23-2149272223.jpg',
      bio: 'Specializes in cognitive behavioral therapy and trauma recovery.',
      contactInfo: 'emily.clark@example.com',
    ),
    // Add more professionals as needed
  ];

  List<MentalHealthProfessional> get professionals => [..._professionals];
}

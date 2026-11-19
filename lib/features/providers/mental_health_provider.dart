import 'package:flutter/material.dart';

import '../models/mental_health_professional.dart';

class MentalHealthProvider with ChangeNotifier {
  final List<MentalHealthProfessional> _professionals = [
    MentalHealthProfessional(
      id: '1',
      name: 'Dr. Emily Clark',
      qualification: 'Clinical Psychologist',
      imageUrl: 'assets/images/Tinu1.png',
      bio: 'Specializes in cognitive behavioral therapy and trauma recovery.',
      contactInfo: 'JohnDoe@gmail.com',
      contactPhoneNumber: '08038849601',

    ),
    // Add more professionals as needed
  ];

  List<MentalHealthProfessional> get professionals => [..._professionals];
}

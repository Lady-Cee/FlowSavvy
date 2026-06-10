import 'package:flutter/material.dart';

import '../models/mental_health_professional.dart';

class MentalHealthProvider with ChangeNotifier {
  final List<MentalHealthProfessional> _professionals = [
    MentalHealthProfessional(
      id: '1',
      name: 'Atinuke Manuels',
      expertise: 'Clinical Psychologist',
      imageUrl: 'assets/images/Tinu1.png',
      bio: 'Specializes in cognitive behavioral therapy and trauma recovery.',
        email: 'aodeshola@yahoo.com',
        phoneNumber: '+2347060945459'

    ),
    // Add more professionals as needed
  ];

  List<MentalHealthProfessional> get professionals => [..._professionals];
}

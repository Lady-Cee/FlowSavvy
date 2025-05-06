import 'package:flutter/material.dart';

import '../models/doctor.dart';

class DoctorProvider with ChangeNotifier {
  final List<Doctor> _doctors = [
    Doctor(
      id: '1',
      name: 'Dr. Jane Smith',
      specialization: 'Gynecologist',
      imageUrl: 'https://img.freepik.com/free-photo/medium-shot-smiley-woman-teaching_23-2149272223.jpg',
      bio: 'Experienced in women\'s health and reproductive care.',
      contactInfo: 'dr.jane@example.com',
    ),
    // Add more doctors as needed
  ];

  List<Doctor> get doctors => [..._doctors];
}

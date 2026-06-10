import 'package:flutter/material.dart';

import '../models/doctor.dart';

class DoctorProvider with ChangeNotifier {
  final List<Doctor> _doctors = [
    Doctor(
      id: '1',
      name: 'Dr. Jane Smith',
      specialization: 'Gynecologist',
      imageUrl: 'assets/images/Cyn.png',
      bio: 'Experienced in women\'s health and reproductive care.',
      email: 'ccenweonwu@gmail.com',
      phoneNumber: '+2348038849601'
    ),
    // Add more doctors as needed
  ];

  List<Doctor> get doctors => [..._doctors];
}

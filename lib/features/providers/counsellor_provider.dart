import 'package:flutter/material.dart';

import '../models/counsellor.dart';

class CounsellorProvider with ChangeNotifier {
  final List<Counsellor> _counsellors = [
    Counsellor(
      id: '1',
      name: 'Mr. John Doe',
      expertise: 'Stress Management',
      imageUrl: 'assets/images/Tinu.png',
      bio: 'Helping individuals manage stress and anxiety effectively.',
      contactInfo: 'Johndoe@yahoo.com',
      contactPhoneNumber: '08038849601'
    ),
    // Add more counsellors as needed
  ];

  List<Counsellor> get counsellors => [..._counsellors];
}

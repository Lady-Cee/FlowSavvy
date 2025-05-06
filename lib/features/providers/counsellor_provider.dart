import 'package:flutter/material.dart';

import '../models/counsellor.dart';

class CounsellorProvider with ChangeNotifier {
  final List<Counsellor> _counsellors = [
    Counsellor(
      id: '1',
      name: 'Mr. John Doe',
      expertise: 'Stress Management',
      imageUrl: 'https://img.freepik.com/free-photo/medium-shot-smiley-woman-teaching_23-2149272223.jpg',
      bio: 'Helping individuals manage stress and anxiety effectively.',
      contactInfo: 'john.doe@example.com',
    ),
    // Add more counsellors as needed
  ];

  List<Counsellor> get counsellors => [..._counsellors];
}

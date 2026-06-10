import 'package:flutter/material.dart';

import '../models/counsellor.dart';

class CounsellorProvider with ChangeNotifier {
  final List<Counsellor> _counsellors = [
    Counsellor(
      id: '1',
      name: 'Tinu Atinuke',
      expertise: 'Stress Management',
      imageUrl: 'assets/images/Tinu1.png',
      bio: 'Helping individuals manage stress and anxiety effectively.',
      email: 'aodeshola@yahoo.com',
        phoneNumber: '+2347060945459'
    ),
    // Add more counsellors as needed
  ];

  List<Counsellor> get counsellors => [..._counsellors];
}

import 'package:flutter/cupertino.dart';

import '../models/community_admin.dart';

class CommunityAdminProvider with ChangeNotifier {
  final List<CommunityAdmin> _admins = [
    CommunityAdmin(
      id: '1',
      name: 'Ms. Cynthia Enweonwu',
      role: 'Community Manager,',
      imageUrl: 'assets/images/Cyn.png',
      bio: 'Ensures a safe and engaging community environment.',
      email: 'ccenweonwu@gmail.com',
      phoneNumber: '+2348038849601'
    ),
    // Add more admins as needed
  ];

  List<CommunityAdmin> get admins => [..._admins];
}

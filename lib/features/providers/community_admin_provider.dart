import 'package:flutter/cupertino.dart';

import '../models/community_admin.dart';

class CommunityAdminProvider with ChangeNotifier {
  final List<CommunityAdmin> _admins = [
    CommunityAdmin(
      id: '1',
      name: 'Ms. Cynthia Enweonwu',
      role: 'Community Manager,',
      imageUrl: 'https://img.freepik.com/free-photo/medium-shot-smiley-woman-teaching_23-2149272223.jpg',
      bio: 'Ensures a safe and engaging community environment.',
      contactInfo: 'ccenweonwu@gmail.com',
    ),
    // Add more admins as needed
  ];

  List<CommunityAdmin> get admins => [..._admins];
}

//import 'reply_model.dart'; // Import this if it's in a separate file

import 'package:flow_savvy/features/models/reply.dart';

class CommunityPost {
  final String id;
  final String author; // or "Anonymous"
  final String title;
  final String content;
  final DateTime createdAt;
  final int likes;
  final List<Reply> replies; // ✅ Change this from List<String> to List<Reply>

  CommunityPost({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    this.replies = const [], // ✅ Use default empty list of Reply
  });
}


// class CommunityPost {
//   final String id;
//   final String author; // or anonymous
//   final String title;
//   final String content;
//   final DateTime createdAt;
//   final int likes;
//   final List<String> comments;
//
//   CommunityPost({
//     required this.id,
//     required this.author,
//     required this.title,
//     required this.content,
//     required this.createdAt,
//     this.likes = 0,
//     this.comments = const [],
//   });
// }

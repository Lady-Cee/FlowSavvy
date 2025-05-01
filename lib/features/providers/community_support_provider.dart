import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/community_support_model.dart';
import '../models/reply.dart';
// import '../models/reply_model.dart'; // Import the Reply model

class CommunitySupportProvider with ChangeNotifier {
  final List<CommunityPost> _posts = [];

  List<CommunityPost> get posts => [..._posts];

  void addPost(CommunityPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void addReplyToPost(String postId, Reply reply) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final updatedPost = CommunityPost(
        id: post.id,
        author: post.author,
        title: post.title,
        content: post.content,
        createdAt: post.createdAt,
        likes: post.likes,
        replies: [...post.replies, reply], // ✅ add reply here
      );
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }


  void likePost(String postId) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      _posts[index] = CommunityPost(
        id: post.id,
        author: post.author,
        title: post.title,
        content: post.content,
        createdAt: post.createdAt,
        likes: post.likes + 1,
        replies: post.replies,
      );
      notifyListeners();
    }
  }

  /// ✅ Add reply to a specific post
  void addReply(String postId, String author, String content) {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final updatedReplies = List<Reply>.from(post.replies)
        ..add(Reply(
          id: const Uuid().v4(),
          author: author,
          content: content,
          createdAt: DateTime.now(),
        ));

      _posts[index] = CommunityPost(
        id: post.id,
        author: post.author,
        title: post.title,
        content: post.content,
        createdAt: post.createdAt,
        likes: post.likes,
        replies: updatedReplies,
      );
      notifyListeners();
    }
  }
}



// import 'package:flutter/material.dart';
//
// import '../models/community_support_model.dart';
// //import '../models/community_post_model.dart';
//
// class CommunitySupportProvider with ChangeNotifier {
//   final List<CommunityPost> _posts = [];
//
//   List<CommunityPost> get posts => [..._posts];
//
//   void addPost(CommunityPost post) {
//     _posts.insert(0, post);
//     notifyListeners();
//   }
//
//   void likePost(String postId) {
//     final index = _posts.indexWhere((post) => post.id == postId);
//     if (index != -1) {
//       _posts[index] = CommunityPost(
//         id: _posts[index].id,
//         author: _posts[index].author,
//         title: _posts[index].title,
//         content: _posts[index].content,
//         createdAt: _posts[index].createdAt,
//         likes: _posts[index].likes + 1,
//         comments: _posts[index].comments,
//       );
//       notifyListeners();
//     }
//   }
//
// // Optional: Add comment, delete post, etc.
// }

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/community_post.dart';
import '../models/reply.dart';

class CommunitySupportProvider with ChangeNotifier {

  // =========================================================
  // POSTS
  // =========================================================

  final List<CommunityPost> _posts = [];

  List<CommunityPost> get posts => List.unmodifiable(_posts);

  // =========================================================
  // STATES
  // =========================================================

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // =========================================================
  // HELPERS
  // =========================================================

  final Uuid _uuid = const Uuid();

  final Random _random = Random();

  /// Generates names such as:
  /// Anonymous Girl 2481
  /// Anonymous Girl 5903
  String generateAnonymousName() {
    return "Anonymous Girl ${1000 + _random.nextInt(9000)}";
  }

  // =========================================================
  // ADD POST
  // =========================================================

  void addPost({
    required String userId,
    required String content,
    bool isAnonymous = true,
  }) {

    final CommunityPost newPost = CommunityPost(
      id: _uuid.v4(),
      userId: userId,
      author: generateAnonymousName(),
      isAnonymous: isAnonymous,
      content: content,
      createdAt: DateTime.now(),
      likes: 0,
      replies: [],
    );

    _posts.insert(0, newPost);

    notifyListeners();

    // ======================================================
    // BACKEND TODO
    //
    // Save newPost.toMap() to Firestore.
    //
    // Example:
    //
    // FirebaseFirestore.instance
    //     .collection('community_posts')
    //     .doc(newPost.id)
    //     .set(newPost.toMap());
    //
    // ======================================================
  }

  // =========================================================
  // DELETE POST
  // =========================================================

  void deletePost(String postId) {

    _posts.removeWhere(
          (post) => post.id == postId,
    );

    notifyListeners();

    // ======================================================
    // BACKEND TODO
    //
    // Delete this post from Firestore.
    //
    // ======================================================
  }

  // =========================================================
  // FIND POST
  // =========================================================

  CommunityPost? findPost(String postId) {

    try {
      return _posts.firstWhere(
            (post) => post.id == postId,
      );
    } catch (_) {
      return null;
    }
  }

  // =========================================================
  // LIKE POST
  // =========================================================

  void likePost(String postId) {
    final post = findPost(postId);

    if (post == null) return;

    post.likes++;

    notifyListeners();

    // ======================================================
    // BACKEND TODO
    //
    // Increment likes in Firestore.
    //
    // Example:
    //
    // FirebaseFirestore.instance
    //     .collection('community_posts')
    //     .doc(postId)
    //     .update({
    //       'likes': FieldValue.increment(1),
    //     });
    //
    // ======================================================
  }

  // =========================================================
  // ADD REPLY
  // =========================================================

  void addReply({
    required String postId,
    required String userId,
    required String author,
    required String content,
  }) {
    final post = findPost(postId);

    if (post == null) return;

    final reply = Reply(
      id: _uuid.v4(),
      userId: userId,
      author: author,
      content: content,
      createdAt: DateTime.now(),
    );;

    post.replies.add(reply);

    notifyListeners();

    // ======================================================
    // BACKEND TODO
    //
    // Save this reply to Firestore.
    //
    // ======================================================
  }

  // =========================================================
  // LOAD POSTS
  // =========================================================

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // ======================================================
      // BACKEND TODO
      //
      // Load posts from Firestore here.
      //
      // Example:
      //
      // final snapshot = await FirebaseFirestore.instance
      //     .collection('community_posts')
      //     .orderBy('createdAt', descending: true)
      //     .get();
      //
      // ======================================================

      await Future.delayed(
        const Duration(milliseconds: 800),
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  // =========================================================
  // REFRESH POSTS
  // =========================================================

  Future<void> refreshPosts() async {
    _isRefreshing = true;

    notifyListeners();

    try {
      // ======================================================
      // BACKEND TODO
      //
      // Reload latest posts from Firestore.
      //
      // ======================================================

      await Future.delayed(
        const Duration(milliseconds: 800),
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isRefreshing = false;

    notifyListeners();
  }

  // =========================================================
  // CLEAR POSTS
  // =========================================================

  void clearPosts() {
    _posts.clear();

    notifyListeners();

    // ======================================================
    // BACKEND TODO
    //
    // Optional:
    // If required, clear cached Firestore data.
    //
    // ======================================================
  }

  // =========================================================
  // CLEAR ERROR
  // =========================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}
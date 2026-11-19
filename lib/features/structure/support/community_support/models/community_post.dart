import 'reply.dart';

class CommunityPost {
  /// Unique ID for the post
  final String id;

  /// Firebase Authentication User ID
  /// This is hidden from other users.
  final String userId;

  /// Whether the user wants to remain anonymous
  /// Default is true
  final bool isAnonymous;

  /// Display name shown in the community
  /// Example: Anonymous Girl 104
  final String author;

  /// The user's post/question
  final String content;

  /// Date and time the post was created
  final DateTime createdAt;

  /// Number of likes
  int likes;

  /// List of replies
  List<Reply> replies;

  CommunityPost({
    required this.id,
    required this.userId,
    this.isAnonymous = true,
    required this.author,
    required this.content,
    required this.createdAt,
    this.likes = 0,
    List<Reply>? replies,
  }) : replies = replies ?? [];

  /// Convert CommunityPost to Map
  /// Used when saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'isAnonymous': isAnonymous,
      'author': author,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'replies': replies.map((reply) => reply.toMap()).toList(),
    };
  }

  /// Create CommunityPost from Firestore Map
  factory CommunityPost.fromMap(Map<String, dynamic> map) {
    return CommunityPost(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      isAnonymous: map['isAnonymous'] ?? true,
      author: map['author'] ?? 'Anonymous User',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      likes: map['likes'] ?? 0,
      replies: (map['replies'] as List<dynamic>?)
          ?.map((reply) => Reply.fromMap(reply))
          .toList() ??
          [],
    );
  }

  /// Create a copy of the object with updated values
  CommunityPost copyWith({
    String? id,
    String? userId,
    bool? isAnonymous,
    String? author,
    String? content,
    DateTime? createdAt,
    int? likes,
    List<Reply>? replies,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      author: author ?? this.author,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      replies: replies ?? this.replies,
    );
  }
}
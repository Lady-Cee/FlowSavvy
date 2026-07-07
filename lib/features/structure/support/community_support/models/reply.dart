class Reply {
  /// Unique ID for the reply
  final String id;

  /// Firebase Authentication User ID
  /// Hidden from other users
  final String userId;

  /// Name displayed to the community
  /// e.g. Anonymous Girl 104
  final String author;

  /// Reply message
  final String content;

  /// Date and time the reply was created
  final DateTime createdAt;

  Reply({
    required this.id,
    required this.userId,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  /// Convert Reply object to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'author': author,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Create Reply object from Firestore
  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      author: map['author'] ?? 'Anonymous User',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
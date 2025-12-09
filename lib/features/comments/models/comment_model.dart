/// Comment Model - نموذج التعليق

class Comment {
  final String id;
  final String projectId;
  final String userId;
  final String userName;
  final String? userImage;
  final String text;
  final DateTime createdAt;
  final int likes;
  final List<String> likedBy;
  final String? parentId; // للردود على التعليقات
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.projectId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.text,
    DateTime? createdAt,
    this.likes = 0,
    List<String>? likedBy,
    this.parentId,
    List<Comment>? replies,
  }) : createdAt = createdAt ?? DateTime.now(),
       likedBy = likedBy ?? [],
       replies = replies ?? [];

  /// نسخة محدثة من Comment
  Comment copyWith({
    String? id,
    String? projectId,
    String? userId,
    String? userName,
    String? userImage,
    String? text,
    DateTime? createdAt,
    int? likes,
    List<String>? likedBy,
    String? parentId,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? List.from(this.likedBy),
      parentId: parentId ?? this.parentId,
      replies: replies ?? List.from(this.replies),
    );
  }

  /// تحويل Comment إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'likes': likes,
      'likedBy': likedBy,
      'parentId': parentId,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }

  /// إنشاء Comment من Map
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      projectId: map['projectId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'],
      text: map['text'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      likes: map['likes'] ?? 0,
      likedBy: map['likedBy'] != null ? List<String>.from(map['likedBy']) : [],
      parentId: map['parentId'],
      replies: map['replies'] != null
          ? (map['replies'] as List).map((r) => Comment.fromMap(r)).toList()
          : [],
    );
  }

  /// التحقق من صحة التعليق
  bool isValid() {
    if (id.isEmpty) return false;
    if (projectId.isEmpty) return false;
    if (userId.isEmpty) return false;
    if (userName.isEmpty) return false;
    if (text.isEmpty || text.length < 1) return false;
    return true;
  }

  /// التحقق مما إذا كان المستخدم قد أعجب بالتعليق
  bool isLikedBy(String visitorUserId) {
    return likedBy.contains(visitorUserId);
  }

  /// هل هذا رد على تعليق آخر
  bool get isReply => parentId != null && parentId!.isNotEmpty;

  @override
  String toString() => 'Comment(id: $id, text: $text, userId: $userId)';
}

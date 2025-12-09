/// Review model - نموذج التقييم
class Review {
  final String id;
  final String userId; // ID of the user who wrote the review
  final String workerId; // ID of the worker being reviewed
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.workerId,
    required this.rating,
    required this.comment,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Review copyWith({
    String? id,
    String? userId,
    String? workerId,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      workerId: workerId ?? this.workerId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'workerId': workerId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      workerId: map['workerId'] ?? '',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0.0,
      comment: map['comment'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// التحقق من صحة نموذج التقييم
  bool isValid() {
    if (id.isEmpty) return false;
    if (userId.isEmpty) return false;
    if (workerId.isEmpty) return false;
    if (rating < 0.0 || rating > 5.0) return false;
    if (comment.isEmpty || comment.length < 5) return false;
    return true;
  }

  /// التحقق من صحة البيانات وإرجاع جميع الأخطاء
  List<String> validate() {
    final errors = <String>[];

    if (id.isEmpty) errors.add('معرف التقييم مطلوب');
    if (userId.isEmpty) errors.add('معرف المستخدم مطلوب');
    if (workerId.isEmpty) errors.add('معرف العامل مطلوب');
    if (rating < 0.0 || rating > 5.0) errors.add('التقييم يجب أن يكون بين 0 و 5');
    if (comment.isEmpty) errors.add('التعليق مطلوب');
    if (comment.length < 5) errors.add('التعليق قصير جداً');

    return errors;
  }

  @override
  String toString() => 'Review(id: $id, userId: $userId, workerId: $workerId, rating: $rating)';
}

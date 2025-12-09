/// Update Comment Request - طلب تعديل تعليق

class UpdateCommentRequest {
  final int commentId;
  final String content;

  const UpdateCommentRequest({required this.commentId, required this.content});

  /// تحويل الطلب إلى JSON
  Map<String, dynamic> toJson() {
    return {'content': content};
  }

  /// التحقق من صحة الطلب
  bool isValid() {
    return commentId > 0 && content.trim().isNotEmpty;
  }
}

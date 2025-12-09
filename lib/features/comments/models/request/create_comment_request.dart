/// Create Comment Request - طلب إنشاء تعليق

class CreateCommentRequest {
  final int postId;
  final String content;
  final int? parentId; // للردود على تعليق آخر

  const CreateCommentRequest({required this.postId, required this.content, this.parentId});

  /// تحويل الطلب إلى JSON
  Map<String, dynamic> toJson() {
    return {'post_id': postId, 'content': content, if (parentId != null) 'parent_id': parentId};
  }

  /// التحقق من صحة الطلب
  bool isValid() {
    return postId > 0 && content.trim().isNotEmpty;
  }

  /// هل هذا رد على تعليق؟
  bool get isReply => parentId != null;
}

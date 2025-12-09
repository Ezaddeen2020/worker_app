/// Get Comments Request - طلب جلب التعليقات

class GetCommentsRequest {
  final int postId;
  final int page;
  final int limit;
  final String? sortBy; // 'newest', 'oldest', 'most_liked'

  const GetCommentsRequest({required this.postId, this.page = 1, this.limit = 20, this.sortBy});

  /// تحويل الطلب إلى Query Parameters
  Map<String, String> toQueryParameters() {
    return {
      'page': page.toString(),
      'limit': limit.toString(),
      if (sortBy != null) 'sort_by': sortBy!,
    };
  }

  /// نسخة جديدة مع تغيير الصفحة
  GetCommentsRequest copyWithPage(int newPage) {
    return GetCommentsRequest(postId: postId, page: newPage, limit: limit, sortBy: sortBy);
  }

  /// التحقق من صحة الطلب
  bool isValid() {
    return postId > 0 && page > 0 && limit > 0;
  }
}

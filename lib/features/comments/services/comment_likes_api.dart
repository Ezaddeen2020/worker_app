/// Comment Likes API - إعجابات التعليقات
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/status_request.dart';
import '../../../core/functions/handling_data.dart';
import '../../../core/api/api_response_model.dart';

class CommentLikesApi {
  final ApiClient _apiClient;

  CommentLikesApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// إضافة لايك للتعليق
  Future<ApiResponse<int>> like({required String token, required String commentId}) async {
    logMessage('Comments', 'Liking comment: $commentId');

    final result = await _apiClient.postWithToken(ApiEndpoints.likeComment(commentId), {}, token);

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      final likesCount = data['likes_count'] ?? data['likes'] ?? 0;
      return ApiResponse.success(likesCount as int);
    });
  }

  /// إزالة لايك من التعليق
  Future<ApiResponse<int>> unlike({required String token, required String commentId}) async {
    logMessage('Comments', 'Unliking comment: $commentId');

    final result = await _apiClient.deleteWithToken(ApiEndpoints.unlikeComment(commentId), token);

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      final likesCount = data['likes_count'] ?? data['likes'] ?? 0;
      return ApiResponse.success(likesCount as int);
    });
  }

  /// تبديل حالة اللايك
  Future<ApiResponse<int>> toggle({
    required String token,
    required String commentId,
    required bool isCurrentlyLiked,
  }) async {
    if (isCurrentlyLiked) {
      return unlike(token: token, commentId: commentId);
    } else {
      return like(token: token, commentId: commentId);
    }
  }
}

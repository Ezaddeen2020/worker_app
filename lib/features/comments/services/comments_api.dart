/// Comments API - جميع عمليات التعليقات (جلب، إنشاء، تعديل، حذف)
/// Online فقط - لا يوجد تخزين محلي

import 'package:dartz/dartz.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/status_request.dart';
import '../../../core/api/api_response_model.dart';
import '../models/comment_model.dart';
import '../models/request/create_comment_request.dart';
import '../models/request/update_comment_request.dart';
import '../models/request/get_comments_request.dart';

export 'comment_likes_api.dart';

/// خدمة API للتعليقات - تشمل جميع العمليات
class CommentsApi {
  final ApiClient _apiClient;

  CommentsApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ============= جلب التعليقات =============

  /// جلب تعليقات منشور معين مع دعم الصفحات
  Future<Either<String, PaginatedResponse<Comment>>> getByPost(GetCommentsRequest request) async {
    try {
      final url =
          '${ApiEndpoints.commentsByPost(request.postId.toString())}?${_buildQuery(request.toQueryParameters())}';
      final response = await _apiClient.get(url);

      return response.fold((status) => Left(status.message), (data) {
        final paginated = PaginatedResponse<Comment>.fromMap(
          data as Map<String, dynamic>,
          (json) => Comment.fromMap(json),
        );
        return Right(paginated);
      });
    } catch (e) {
      return Left('خطأ في جلب التعليقات: $e');
    }
  }

  /// جلب الردود على تعليق معين
  Future<Either<String, PaginatedResponse<Comment>>> getReplies({
    required int commentId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final url = '${ApiEndpoints.repliesByComment(commentId.toString())}?page=$page&limit=$limit';
      final response = await _apiClient.get(url);

      return response.fold((status) => Left(status.message), (data) {
        final paginated = PaginatedResponse<Comment>.fromMap(
          data as Map<String, dynamic>,
          (json) => Comment.fromMap(json),
        );
        return Right(paginated);
      });
    } catch (e) {
      return Left('خطأ في جلب الردود: $e');
    }
  }

  /// جلب عدد التعليقات لمنشور معين
  Future<Either<String, int>> getCount(int postId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.commentsByPost(postId.toString()));

      return response.fold((status) => Left(status.message), (data) {
        if (data is Map<String, dynamic>) {
          return Right(data['total'] ?? data['count'] ?? 0);
        }
        return const Right(0);
      });
    } catch (e) {
      return Left('خطأ في جلب عدد التعليقات: $e');
    }
  }

  // ============= إنشاء تعليق =============

  /// إنشاء تعليق جديد
  Future<Either<String, ApiResponse<Comment>>> create(
    CreateCommentRequest request, {
    required String token,
  }) async {
    try {
      final response = await _apiClient.postWithToken(
        ApiEndpoints.createComment,
        request.toJson(),
        token,
      );

      return response.fold((status) => Left(status.message), (data) {
        final apiResponse = ApiResponse<Comment>.fromMap(
          data as Map<String, dynamic>,
          (json) => Comment.fromMap(json as Map<String, dynamic>),
        );
        return Right(apiResponse);
      });
    } catch (e) {
      return Left('خطأ في إنشاء التعليق: $e');
    }
  }

  /// إنشاء رد على تعليق
  Future<Either<String, ApiResponse<Comment>>> createReply({
    required int postId,
    required int parentId,
    required String content,
    required String token,
  }) async {
    final request = CreateCommentRequest(postId: postId, content: content, parentId: parentId);
    return create(request, token: token);
  }

  // ============= تعديل تعليق =============

  /// تعديل تعليق موجود
  Future<Either<String, ApiResponse<Comment>>> update(
    UpdateCommentRequest request, {
    required String token,
  }) async {
    try {
      final response = await _apiClient.putWithToken(
        ApiEndpoints.updateComment(request.commentId.toString()),
        request.toJson(),
        token,
      );

      return response.fold((status) => Left(status.message), (data) {
        final apiResponse = ApiResponse<Comment>.fromMap(
          data as Map<String, dynamic>,
          (json) => Comment.fromMap(json as Map<String, dynamic>),
        );
        return Right(apiResponse);
      });
    } catch (e) {
      return Left('خطأ في تعديل التعليق: $e');
    }
  }

  // ============= حذف تعليق =============

  /// حذف تعليق
  Future<Either<String, ApiResponse<void>>> delete(int commentId, {required String token}) async {
    try {
      final response = await _apiClient.deleteWithToken(
        ApiEndpoints.deleteComment(commentId.toString()),
        token,
      );

      return response.fold((status) => Left(status.message), (data) {
        final apiResponse = ApiResponse<void>.fromMap(data as Map<String, dynamic>, (_) {});
        return Right(apiResponse);
      });
    } catch (e) {
      return Left('خطأ في حذف التعليق: $e');
    }
  }

  // ============= Helper Methods =============

  String _buildQuery(Map<String, String> params) {
    return params.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}

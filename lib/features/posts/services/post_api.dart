/// Post API Service - خدمة المنشورات (معتمدة على Models)
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/status_request.dart';
import '../../../core/functions/handling_data.dart';
import '../models/project_model.dart';
import '../../../core/api/api_response_model.dart';
import '../models/request/post_request_models.dart';

class PostApi {
  final ApiClient _apiClient;

  PostApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// جلب جميع المنشورات
  Future<PaginatedResponse<Project>> getAllPosts({int page = 1, int limit = 20}) async {
    logMessage('Posts', 'Fetching all posts - page: $page');

    final url = '${ApiEndpoints.allPosts}?page=$page&limit=$limit';
    final result = await _apiClient.get(url);

    return result.fold(
      (failure) => PaginatedResponse(success: false, data: [], message: failure.message),
      (data) => PaginatedResponse.fromMap(data, (map) => Project.fromMap(map)),
    );
  }

  /// جلب منشور بالـ ID
  Future<ApiResponse<Project>> getPostById(String postId) async {
    logMessage('Posts', 'Fetching post: $postId');

    final result = await _apiClient.get(ApiEndpoints.postById(postId));

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final project = Project.fromMap(data['data'] ?? data);
        return ApiResponse.success(project);
      } catch (e) {
        return ApiResponse.failure('فشل في تحليل بيانات المنشور');
      }
    });
  }

  /// جلب منشورات مستخدم معين
  Future<ApiResponse<List<Project>>> getPostsByUser(String userId) async {
    logMessage('Posts', 'Fetching posts for user: $userId');

    final result = await _apiClient.get(ApiEndpoints.postsByUser(userId));

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final list = data['data'] ?? data;
        if (list is List) {
          final projects = list.map((m) => Project.fromMap(m)).toList();
          return ApiResponse.success(projects);
        }
        return ApiResponse.success([]);
      } catch (e) {
        return ApiResponse.failure('فشل في تحليل المنشورات');
      }
    });
  }

  /// إنشاء منشور جديد
  Future<ApiResponse<Project>> createPost({
    required String token,
    required CreatePostRequest request,
  }) async {
    if (!request.isValid()) {
      return ApiResponse.failure('العنوان والوصف مطلوبان');
    }

    logMessage('Posts', 'Creating new post: ${request.title}');

    final result = await _apiClient.postWithToken(ApiEndpoints.createPost, request.toMap(), token);

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final project = Project.fromMap(data['data'] ?? data);
        return ApiResponse.success(project, message: 'تم إنشاء المنشور بنجاح');
      } catch (e) {
        return ApiResponse.success(
          Project(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            workerId: '',
            title: request.title,
            description: request.description,
            images: request.images,
            price: request.price,
          ),
          message: 'تم إنشاء المنشور',
        );
      }
    });
  }

  /// تحديث منشور
  Future<ApiResponse<Project>> updatePost({
    required String token,
    required UpdatePostRequest request,
  }) async {
    if (!request.hasChanges()) {
      return ApiResponse.failure('لا توجد تغييرات للحفظ');
    }

    logMessage('Posts', 'Updating post: ${request.postId}');

    final result = await _apiClient.putWithToken(
      ApiEndpoints.updatePost(request.postId),
      request.toMap(),
      token,
    );

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final project = Project.fromMap(data['data'] ?? data);
        return ApiResponse.success(project, message: 'تم تحديث المنشور بنجاح');
      } catch (e) {
        return ApiResponse.failure('فشل في تحليل البيانات');
      }
    });
  }

  /// حذف منشور
  Future<ApiResponse<bool>> deletePost({required String token, required String postId}) async {
    logMessage('Posts', 'Deleting post: $postId');

    final result = await _apiClient.deleteWithToken(ApiEndpoints.deletePost(postId), token);

    return result.fold(
      (failure) => ApiResponse.failure(failure.message, status: failure),
      (data) => ApiResponse.success(true, message: 'تم حذف المنشور بنجاح'),
    );
  }

  /// إضافة لايك للمنشور
  Future<ApiResponse<int>> likePost({required String token, required String postId}) async {
    logMessage('Posts', 'Liking post: $postId');

    final result = await _apiClient.postWithToken(ApiEndpoints.likePost(postId), {}, token);

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      final likesCount = data['likes_count'] ?? data['likes'] ?? 0;
      return ApiResponse.success(likesCount as int);
    });
  }

  /// إزالة لايك من المنشور
  Future<ApiResponse<int>> unlikePost({required String token, required String postId}) async {
    logMessage('Posts', 'Unliking post: $postId');

    final result = await _apiClient.postWithToken(ApiEndpoints.unlikePost(postId), {}, token);

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      final likesCount = data['likes_count'] ?? data['likes'] ?? 0;
      return ApiResponse.success(likesCount as int);
    });
  }

  /// تبديل حالة اللايك
  Future<ApiResponse<int>> toggleLike({
    required String token,
    required String postId,
    required bool isCurrentlyLiked,
  }) async {
    if (isCurrentlyLiked) {
      return unlikePost(token: token, postId: postId);
    } else {
      return likePost(token: token, postId: postId);
    }
  }
}

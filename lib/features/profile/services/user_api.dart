/// User API Service - خدمة المستخدمين (معتمدة على Models)
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/status_request.dart';
import '../../../core/functions/handling_data.dart';
import '../models/user_model.dart';
import '../../../core/api/api_response_model.dart';
import '../models/request/user_request_models.dart';

class UserApiService {
  final ApiClient _apiClient;

  UserApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// جلب المستخدم الحالي
  Future<ApiResponse<User>> getCurrentUser(String token) async {
    logMessage('User', 'Fetching current user');

    final result = await _apiClient.getWithToken(ApiEndpoints.currentUser, token);

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final userData = data['data'] ?? data['user'] ?? data;
        final user = User.fromMap(userData);
        return ApiResponse.success(user);
      } catch (e) {
        return ApiResponse.failure('فشل في تحليل بيانات المستخدم');
      }
    });
  }

  /// جلب مستخدم بالـ ID
  Future<ApiResponse<User>> getUserById(String userId) async {
    logMessage('User', 'Fetching user: $userId');

    final result = await _apiClient.get(ApiEndpoints.userById(userId));

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final userData = data['data'] ?? data['user'] ?? data;
        final user = User.fromMap(userData);
        return ApiResponse.success(user);
      } catch (e) {
        return ApiResponse.failure('فشل في تحليل بيانات المستخدم');
      }
    });
  }

  /// جلب جميع المستخدمين
  Future<PaginatedResponse<User>> getAllUsers({int page = 1, int limit = 20}) async {
    logMessage('User', 'Fetching all users - page: $page');

    final url = '${ApiEndpoints.allUsers}?page=$page&limit=$limit';

    final result = await _apiClient.get(url);

    return result.fold((failure) => PaginatedResponse.failure(failure.message, status: failure), (
      data,
    ) {
      try {
        final list = data['data'] ?? data['users'] ?? data;
        if (list is List) {
          final users = list.map((m) => User.fromMap(m)).toList();
          final totalPages = data['total_pages'] ?? data['totalPages'] ?? 1;
          final totalItems = data['total'] ?? data['total_count'] ?? users.length;
          return PaginatedResponse.success(
            items: users,
            currentPage: page,
            totalPages: totalPages,
            totalItems: totalItems,
          );
        }
        return PaginatedResponse.success(
          items: [],
          currentPage: page,
          totalPages: 1,
          totalItems: 0,
        );
      } catch (e) {
        return PaginatedResponse.failure('فشل في تحليل بيانات المستخدمين');
      }
    });
  }

  /// تحديث بيانات المستخدم
  Future<ApiResponse<User>> updateProfile({
    required String token,
    required UpdateProfileRequest request,
  }) async {
    if (!request.hasChanges()) {
      return ApiResponse.failure('لا توجد تغييرات للحفظ');
    }

    logMessage('User', 'Updating profile');

    final result = await _apiClient.putWithToken(
      ApiEndpoints.updateProfile,
      request.toMap(),
      token,
    );

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final userData = data['data'] ?? data['user'] ?? data;
        final user = User.fromMap(userData);
        return ApiResponse.success(user, message: 'تم تحديث البيانات بنجاح');
      } catch (e) {
        return ApiResponse.success(User.empty(), message: 'تم تحديث البيانات');
      }
    });
  }

  /// رفع صورة البروفايل
  Future<ApiResponse<String>> uploadAvatar({
    required String token,
    required UploadAvatarRequest request,
  }) async {
    if (!request.isValid()) {
      return ApiResponse.failure('مسار الصورة مطلوب');
    }

    logMessage('User', 'Uploading avatar');

    final result = await _apiClient.postWithToken(
      ApiEndpoints.uploadAvatar,
      request.toMap(),
      token,
    );

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      final imageUrl = data['url'] ?? data['image_url'] ?? data['avatar'] ?? '';
      return ApiResponse.success(imageUrl as String, message: 'تم رفع الصورة بنجاح');
    });
  }
}

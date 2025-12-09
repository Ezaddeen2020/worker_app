import 'package:workers/core/api/api_client.dart';
import 'package:workers/core/api/api_endpoints.dart';
import 'package:workers/core/api/status_request.dart';
import 'package:workers/core/functions/handling_data.dart';
import 'package:workers/features/profile/models/user_model.dart';
import 'package:workers/core/api/api_response_model.dart';
import 'package:workers/features/auth/models/auth_models.dart';

class AuthApi {
  final ApiClient _apiClient;

  AuthApi({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// تسجيل الدخول
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    if (!request.isValid()) {
      return ApiResponse.failure('البريد الإلكتروني وكلمة المرور مطلوبان');
    }

    logMessage('Auth', 'Attempting login for: ${request.email}');

    final result = await _apiClient.post(ApiEndpoints.login, request.toMap());

    return result.fold(
      (failure) => ApiResponse.failure(failure.message, status: failure),
      (data) => ApiResponse.success(AuthResponse.fromMap(data)),
    );
  }

  /// إنشاء حساب جديد
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    if (!request.isValid()) {
      return ApiResponse.failure('جميع الحقول مطلوبة');
    }

    logMessage('Auth', 'Attempting registration for: ${request.email}');

    final result = await _apiClient.post(ApiEndpoints.register, request.toMap());

    return result.fold(
      (failure) => ApiResponse.failure(failure.message, status: failure),
      (data) => ApiResponse.success(AuthResponse.fromMap(data)),
    );
  }

  /// تسجيل الخروج
  Future<ApiResponse<bool>> logout(String token) async {
    logMessage('Auth', 'Logging out...');

    final result = await _apiClient.postWithToken(ApiEndpoints.logout, {}, token);

    return result.fold(
      (failure) => ApiResponse.failure(failure.message, status: failure),
      (data) => ApiResponse.success(true, message: 'تم تسجيل الخروج بنجاح'),
    );
  }

  /// تجديد التوكن
  Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    logMessage('Auth', 'Refreshing token...');

    final result = await _apiClient.post(ApiEndpoints.refreshToken, {
      'refresh_token': refreshToken,
    });

    return result.fold(
      (failure) => ApiResponse.failure(failure.message, status: failure),
      (data) => ApiResponse.success(AuthResponse.fromMap(data)),
    );
  }

  /// نسيت كلمة المرور
  Future<ApiResponse<bool>> forgotPassword(ForgotPasswordRequest request) async {
    logMessage('Auth', 'Forgot password for: ${request.email}');

    final result = await _apiClient.post(ApiEndpoints.forgotPassword, request.toMap());

    return result.fold(
      (failure) => ApiResponse.failure(failure.message, status: failure),
      (data) => ApiResponse.success(true, message: 'تم إرسال رابط إعادة التعيين'),
    );
  }

  /// إعادة تعيين كلمة المرور
  Future<ApiResponse<bool>> resetPassword(ResetPasswordRequest request) async {
    logMessage('Auth', 'Resetting password...');

    final result = await _apiClient.post(ApiEndpoints.resetPassword, request.toMap());

    return result.fold(
      (failure) => ApiResponse.failure(failure.message, status: failure),
      (data) => ApiResponse.success(true, message: 'تم إعادة تعيين كلمة المرور'),
    );
  }

  /// التحقق من صلاحية التوكن
  Future<bool> validateToken(String token) async {
    return _apiClient.validateToken(token);
  }

  /// جلب بيانات المستخدم الحالي
  Future<ApiResponse<User>> getCurrentUser(String token) async {
    logMessage('Auth', 'Getting current user...');

    final result = await _apiClient.getWithToken(ApiEndpoints.currentUser, token);

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final user = User.fromMap(data['user'] ?? data);
        return ApiResponse.success(user);
      } catch (e) {
        return ApiResponse.failure('فشل في تحليل بيانات المستخدم');
      }
    });
  }
}

/// Worker API Service - خدمة العمال (معتمدة على Models)
import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/status_request.dart';
import '../../../core/functions/handling_data.dart';
import '../models/worker_profile_model.dart';
import '../../../core/api/api_response_model.dart';
import '../models/request/worker_request_models.dart';

class WorkerApiService {
  final ApiClient _apiClient;

  WorkerApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  /// جلب جميع العمال
  Future<PaginatedResponse<WorkerProfile>> getAllWorkers({int page = 1, int limit = 20}) async {
    logMessage('Workers', 'Fetching all workers - page: $page');

    final url = '${ApiEndpoints.workerProfiles}?page=$page&limit=$limit';

    final result = await _apiClient.get(url);

    return result.fold((failure) => PaginatedResponse.failure(failure.message, status: failure), (
      data,
    ) {
      try {
        final list = data['data'] ?? data['workers'] ?? data;
        if (list is List) {
          final workers = list.map((m) => WorkerProfile.fromMap(m)).toList();
          final totalPages = data['total_pages'] ?? data['totalPages'] ?? 1;
          final totalItems = data['total'] ?? data['total_count'] ?? workers.length;
          return PaginatedResponse.success(
            items: workers,
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
        return PaginatedResponse.failure('فشل في تحليل بيانات العمال');
      }
    });
  }

  /// جلب عامل بالـ ID
  Future<ApiResponse<WorkerProfile>> getWorkerById(String workerId) async {
    logMessage('Workers', 'Fetching worker: $workerId');

    final result = await _apiClient.get(ApiEndpoints.workerById(workerId));

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final workerData = data['data'] ?? data['worker'] ?? data;
        final worker = WorkerProfile.fromMap(workerData);
        return ApiResponse.success(worker);
      } catch (e) {
        return ApiResponse.failure('فشل في تحليل بيانات العامل');
      }
    });
  }

  /// جلب عامل بـ User ID
  Future<ApiResponse<WorkerProfile>> getWorkerByUserId(String userId) async {
    logMessage('Workers', 'Fetching worker by user: $userId');

    final result = await _apiClient.get(ApiEndpoints.workerByUserId(userId));

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final workerData = data['data'] ?? data['worker'] ?? data;
        final worker = WorkerProfile.fromMap(workerData);
        return ApiResponse.success(worker);
      } catch (e) {
        return ApiResponse.failure('فشل في تحليل بيانات العامل');
      }
    });
  }

  /// تحديث بروفايل العامل
  Future<ApiResponse<WorkerProfile>> updateWorkerProfile({
    required String token,
    required UpdateWorkerProfileRequest request,
  }) async {
    if (!request.hasChanges()) {
      return ApiResponse.failure('لا توجد تغييرات للحفظ');
    }

    logMessage('Workers', 'Updating worker profile');

    final result = await _apiClient.putWithToken(
      ApiEndpoints.updateWorkerProfile,
      request.toMap(),
      token,
    );

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final workerData = data['data'] ?? data['worker'] ?? data;
        final worker = WorkerProfile.fromMap(workerData);
        return ApiResponse.success(worker, message: 'تم تحديث البروفايل بنجاح');
      } catch (e) {
        return ApiResponse.success(
          WorkerProfile(id: '', userId: ''),
          message: 'تم تحديث البروفايل',
        );
      }
    });
  }

  /// إنشاء بروفايل عامل جديد
  Future<ApiResponse<WorkerProfile>> createWorkerProfile({
    required String token,
    required CreateWorkerProfileRequest request,
  }) async {
    if (!request.isValid()) {
      return ApiResponse.failure('جميع الحقول مطلوبة');
    }

    logMessage('Workers', 'Creating worker profile');

    final result = await _apiClient.postWithToken(
      ApiEndpoints.workerProfiles,
      request.toMap(),
      token,
    );

    return result.fold((failure) => ApiResponse.failure(failure.message, status: failure), (data) {
      try {
        final workerData = data['data'] ?? data['worker'] ?? data;
        final worker = WorkerProfile.fromMap(workerData);
        return ApiResponse.success(worker, message: 'تم إنشاء البروفايل بنجاح');
      } catch (e) {
        return ApiResponse.failure('فشل في إنشاء البروفايل');
      }
    });
  }

  /// البحث عن العمال
  Future<PaginatedResponse<WorkerProfile>> searchWorkers(SearchWorkersRequest request) async {
    logMessage('Workers', 'Searching workers');

    final url = '${ApiEndpoints.searchWorkers('')}?${request.toQueryString()}';

    final result = await _apiClient.get(url);

    return result.fold((failure) => PaginatedResponse.failure(failure.message, status: failure), (
      data,
    ) {
      try {
        final list = data['data'] ?? data['workers'] ?? data;
        if (list is List) {
          final workers = list.map((m) => WorkerProfile.fromMap(m)).toList();
          final totalPages = data['total_pages'] ?? data['totalPages'] ?? 1;
          final totalItems = data['total'] ?? data['total_count'] ?? workers.length;
          return PaginatedResponse.success(
            items: workers,
            currentPage: request.page,
            totalPages: totalPages,
            totalItems: totalItems,
          );
        }
        return PaginatedResponse.success(
          items: [],
          currentPage: request.page,
          totalPages: 1,
          totalItems: 0,
        );
      } catch (e) {
        return PaginatedResponse.failure('فشل في البحث');
      }
    });
  }
}

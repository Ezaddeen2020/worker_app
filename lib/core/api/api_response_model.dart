import 'package:workers/core/api/status_request.dart';

/// نموذج استجابة API عامة
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final StatusRequest status;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.status = StatusRequest.success,
    this.statusCode,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse(success: true, data: data, message: message, status: StatusRequest.success);
  }

  factory ApiResponse.failure(String message, {StatusRequest? status}) {
    return ApiResponse(success: false, message: message, status: status ?? StatusRequest.failure);
  }

  factory ApiResponse.fromMap(Map<String, dynamic> map, T Function(dynamic)? dataParser) {
    final isSuccess = map['success'] == true || map['status'] == 'success';

    return ApiResponse(
      success: isSuccess,
      data: isSuccess && dataParser != null && map['data'] != null ? dataParser(map['data']) : null,
      message: map['message']?.toString(),
      status: isSuccess ? StatusRequest.success : StatusRequest.failure,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;
  bool get hasData => data != null;
}

/// نموذج استجابة قائمة مع Pagination
class PaginatedResponse<T> {
  final bool success;
  final List<T> data;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final String? message;
  final StatusRequest? status;

  PaginatedResponse({
    required this.success,
    required this.data,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalItems = 0,
    this.perPage = 20,
    this.message,
    this.status,
  });

  /// Factory constructor for success
  factory PaginatedResponse.success({
    required List<T> items,
    int currentPage = 1,
    int totalPages = 1,
    int totalItems = 0,
    int perPage = 20,
    String? message,
  }) {
    return PaginatedResponse<T>(
      success: true,
      data: items,
      currentPage: currentPage,
      totalPages: totalPages,
      totalItems: totalItems == 0 ? items.length : totalItems,
      perPage: perPage,
      message: message,
      status: StatusRequest.success,
    );
  }

  /// Factory constructor for failure
  factory PaginatedResponse.failure(String message, {StatusRequest? status}) {
    return PaginatedResponse<T>(
      success: false,
      data: [],
      message: message,
      status: status ?? StatusRequest.failure,
    );
  }

  factory PaginatedResponse.fromMap(
    Map<String, dynamic> map,
    T Function(Map<String, dynamic>) itemParser,
  ) {
    final isSuccess = map['success'] == true || map['status'] == 'success';
    final rawData = map['data'];

    List<T> items = [];
    if (rawData is List) {
      items = rawData.map((item) => itemParser(item as Map<String, dynamic>)).toList();
    }

    return PaginatedResponse(
      success: isSuccess,
      data: items,
      currentPage: map['current_page'] ?? map['page'] ?? 1,
      totalPages: map['total_pages'] ?? map['last_page'] ?? 1,
      totalItems: map['total'] ?? map['total_items'] ?? items.length,
      perPage: map['per_page'] ?? map['limit'] ?? 20,
      message: map['message']?.toString(),
      status: isSuccess ? StatusRequest.success : StatusRequest.failure,
    );
  }

  /// Getter للعناصر (alias for data)
  List<T> get items => data;

  /// Getter للعدد الكلي (alias for totalItems)
  int get total => totalItems;

  bool get hasMore => currentPage < totalPages;
  bool get isEmpty => data.isEmpty;
  bool get isNotEmpty => data.isNotEmpty;
}

/// نموذج خطأ API
class ApiError {
  final String message;
  final int? statusCode;
  final StatusRequest status;
  final Map<String, dynamic>? errors;

  ApiError({
    required this.message,
    this.statusCode,
    this.status = StatusRequest.failure,
    this.errors,
  });

  factory ApiError.fromMap(Map<String, dynamic> map) {
    return ApiError(
      message: map['message'] ?? 'حدث خطأ غير متوقع',
      statusCode: map['status_code'],
      errors: map['errors'],
    );
  }

  factory ApiError.network() {
    return ApiError(message: 'لا يوجد اتصال بالإنترنت', status: StatusRequest.offline);
  }

  factory ApiError.server() {
    return ApiError(message: 'خطأ في الخادم، حاول لاحقاً', status: StatusRequest.serverFailure);
  }

  factory ApiError.unauthorized() {
    return ApiError(message: 'انتهت صلاحية الجلسة', status: StatusRequest.unauthorized);
  }

  factory ApiError.timeout() {
    return ApiError(message: 'انتهى وقت الاتصال', status: StatusRequest.timeout);
  }
}

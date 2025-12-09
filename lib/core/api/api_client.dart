/// API Client - للتواصل مع الخادم
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:http/io_client.dart';
import 'status_request.dart';
import 'api_endpoints.dart';

class ApiClient {
  final IOClient _client;

  ApiClient({IOClient? client}) : _client = client ?? _createHttpClient();

  /// إنشاء HTTP client محسّن
  static IOClient _createHttpClient() {
    final httpClient = HttpClient();

    // إعدادات timeout
    httpClient.connectionTimeout = const Duration(seconds: 15);
    httpClient.idleTimeout = const Duration(seconds: 30);

    // User Agent
    httpClient.userAgent = 'Workers-App/1.0';

    // تجاوز التحقق من شهادة SSL (للتطوير فقط!)
    // ⚠️ تحذير: يجب إزالة هذا في الإنتاج
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // السماح بجميع الشهادات أثناء التطوير
      log('⚠️ SSL Certificate warning for $host:$port');
      return true; // قبول الشهادة
    };

    return IOClient(httpClient);
  }

  // ==================== GET ====================

  /// GET request بدون token
  Future<Either<StatusRequest, dynamic>> get(String url) async {
    try {
      _logRequest('GET', url);

      final response = await _client
          .get(Uri.parse(url), headers: ApiEndpoints.headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// GET request مع token
  Future<Either<StatusRequest, dynamic>> getWithToken(String url, String token) async {
    try {
      _logRequest('GET', url, hasToken: true);

      final response = await _client
          .get(Uri.parse(url), headers: ApiEndpoints.headersWithToken(token))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== POST ====================

  /// POST request بدون token
  Future<Either<StatusRequest, dynamic>> post(String url, Map<String, dynamic> data) async {
    try {
      _logRequest('POST', url, data: data);

      final response = await _client
          .post(Uri.parse(url), headers: ApiEndpoints.headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// POST request مع token
  Future<Either<StatusRequest, dynamic>> postWithToken(
    String url,
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      _logRequest('POST', url, data: data, hasToken: true);

      final response = await _client
          .post(
            Uri.parse(url),
            headers: ApiEndpoints.headersWithToken(token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== PUT ====================

  /// PUT request مع token
  Future<Either<StatusRequest, dynamic>> putWithToken(
    String url,
    Map<String, dynamic> data,
    String token,
  ) async {
    try {
      _logRequest('PUT', url, data: data, hasToken: true);

      final response = await _client
          .put(
            Uri.parse(url),
            headers: ApiEndpoints.headersWithToken(token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== DELETE ====================

  /// DELETE request مع token
  Future<Either<StatusRequest, dynamic>> deleteWithToken(
    String url,
    String token, {
    Map<String, dynamic>? data,
  }) async {
    try {
      _logRequest('DELETE', url, data: data, hasToken: true);

      final response = await _client
          .delete(
            Uri.parse(url),
            headers: ApiEndpoints.headersWithToken(token),
            body: data != null ? jsonEncode(data) : null,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== Multipart (Upload) ====================

  /// رفع صورة واحدة
  Future<Either<StatusRequest, dynamic>> uploadImage(
    String url,
    File imageFile,
    String token, {
    String fieldName = 'image',
  }) async {
    try {
      _logRequest('UPLOAD', url, hasToken: true);

      final request = await HttpClient().postUrl(Uri.parse(url));

      // Headers
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'multipart/form-data');

      // TODO: Implement multipart upload
      // For now, return a placeholder

      return const Right({'message': 'Upload not implemented yet'});
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== Helper Methods ====================

  /// معالجة الاستجابة
  Either<StatusRequest, dynamic> _handleResponse(dynamic response) {
    _logResponse(response.statusCode, response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) {
          return const Right({'status': 'success'});
        }
        try {
          return Right(jsonDecode(response.body));
        } catch (e) {
          return Right(response.body);
        }

      case 204:
        return const Right({'status': 'success', 'message': 'No content'});

      case 400:
        return const Left(StatusRequest.failure);

      case 401:
        return const Left(StatusRequest.unauthorized);

      case 403:
        return const Left(StatusRequest.forbidden);

      case 404:
        return const Left(StatusRequest.notFound);

      case 500:
      case 502:
      case 503:
        return const Left(StatusRequest.serverFailure);

      default:
        return const Left(StatusRequest.failure);
    }
  }

  /// معالجة الأخطاء
  Left<StatusRequest, dynamic> _handleError(dynamic error) {
    log('❌ API Error: $error');

    if (error is SocketException) {
      return const Left(StatusRequest.offline);
    }
    if (error is HttpException) {
      return const Left(StatusRequest.serverFailure);
    }
    if (error is HandshakeException) {
      log('❌ SSL/TLS Handshake Error - قد يكون هناك مشكلة في شهادة الخادم');
      return const Left(StatusRequest.serverFailure);
    }
    if (error is TlsException) {
      log('❌ TLS Error - مشكلة في الاتصال الآمن');
      return const Left(StatusRequest.serverFailure);
    }
    if (error is FormatException) {
      return const Left(StatusRequest.failure);
    }
    if (error.toString().contains('TimeoutException')) {
      return const Left(StatusRequest.timeout);
    }
    if (error.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
      log('❌ Certificate verification failed');
      return const Left(StatusRequest.serverFailure);
    }

    return const Left(StatusRequest.failure);
  }

  /// تسجيل الطلب
  void _logRequest(String method, String url, {Map<String, dynamic>? data, bool hasToken = false}) {
    log('🚀 $method Request');
    log('📍 URL: $url');
    if (hasToken) log('🔑 With Token');
    if (data != null) log('📦 Data: ${jsonEncode(data)}');
  }

  /// تسجيل الاستجابة
  void _logResponse(int statusCode, String body) {
    final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
    log('$emoji Response Status: $statusCode');
    log('📝 Response Body: ${body.length > 500 ? '${body.substring(0, 500)}...' : body}');
  }

  /// اختبار الاتصال
  Future<bool> testConnection() async {
    try {
      log('🧪 Testing Connection...');
      final response = await _client
          .get(Uri.parse('https://httpbin.org/get'))
          .timeout(const Duration(seconds: 10));

      log('🧪 Test Result: ${response.statusCode == 200 ? 'SUCCESS' : 'FAILED'}');
      return response.statusCode == 200;
    } catch (e) {
      log('🧪 Test Connection Error: $e');
      return false;
    }
  }

  /// التحقق من صلاحية التوكن
  Future<bool> validateToken(String token) async {
    try {
      final result = await getWithToken(ApiEndpoints.validateToken, token);
      return result.isRight();
    } catch (e) {
      return false;
    }
  }
}

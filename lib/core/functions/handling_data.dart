/// معالجة البيانات من الـ API
import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../api/status_request.dart';

/// تسجيل الرسائل
void logMessage(String tag, String message) {
  log('[$tag] $message');
}

/// معالجة نتيجة Either وتحويلها لـ Map
Future<Map<String, dynamic>> handleEitherResult(
  Future<Either<StatusRequest, dynamic>> future,
  String successTag,
  String failureMessage,
) async {
  try {
    final result = await future;

    return result.fold(
      (failure) {
        logMessage('API Error', failure.toString());

        // رسالة مخصصة حسب نوع الخطأ
        String message = failureMessage;
        if (failure == StatusRequest.unauthorized) {
          message = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى';
        } else if (failure == StatusRequest.offline) {
          message = 'لا يوجد اتصال بالإنترنت';
        } else if (failure == StatusRequest.serverFailure) {
          message = 'خطأ في الخادم، حاول لاحقاً';
        } else if (failure == StatusRequest.timeout) {
          message = 'انتهى وقت الاتصال، حاول مرة أخرى';
        }

        return {'status': failure.name, 'message': message, 'success': false};
      },
      (data) {
        logMessage(successTag, data.toString());
        return {'status': 'success', 'data': data, 'success': true};
      },
    );
  } catch (e) {
    logMessage('API Exception', e.toString());
    return {'status': 'failure', 'message': 'حدث خطأ غير متوقع', 'success': false};
  }
}

/// تحويل استجابة Map إلى StatusRequest
StatusRequest mapResponseToStatus(Map<String, dynamic> response) {
  final status = response['status']?.toString().toLowerCase() ?? 'failure';

  switch (status) {
    case 'success':
      return StatusRequest.success;
    case 'unauthorized':
      return StatusRequest.unauthorized;
    case 'offline':
      return StatusRequest.offline;
    case 'serverfailure':
      return StatusRequest.serverFailure;
    case 'notfound':
      return StatusRequest.notFound;
    case 'timeout':
      return StatusRequest.timeout;
    default:
      return StatusRequest.failure;
  }
}

/// التحقق من نجاح الاستجابة
bool isSuccessResponse(Map<String, dynamic> response) {
  return response['success'] == true || response['status'] == 'success';
}

/// استخراج البيانات من الاستجابة
T? extractData<T>(Map<String, dynamic> response) {
  if (isSuccessResponse(response) && response.containsKey('data')) {
    return response['data'] as T?;
  }
  return null;
}

/// استخراج رسالة الخطأ
String extractErrorMessage(Map<String, dynamic> response) {
  return response['message']?.toString() ?? 'حدث خطأ غير متوقع';
}

/// تحويل List من الـ API إلى List من الـ Models
List<T> parseList<T>(dynamic data, T Function(Map<String, dynamic>) fromMap) {
  if (data == null) return [];
  if (data is! List) return [];

  return data.map((item) => fromMap(item as Map<String, dynamic>)).toList().cast<T>();
}

/// تحويل Map من الـ API إلى Model
T? parseObject<T>(dynamic data, T Function(Map<String, dynamic>) fromMap) {
  if (data == null) return null;
  if (data is! Map<String, dynamic>) return null;

  return fromMap(data);
}

/// حالات الطلبات للـ API
enum StatusRequest {
  success, // نجاح العملية
  failure, // فشل عام
  loading, // جاري التحميل
  offline, // لا يوجد اتصال
  serverFailure, // خطأ في السيرفر
  unauthorized, // غير مصرح (401)
  forbidden, // ممنوع (403)
  notFound, // غير موجود (404)
  timeout, // انتهاء الوقت
  noData, // لا توجد بيانات
}

/// Extension للحصول على رسائل الأخطاء
extension StatusRequestExtension on StatusRequest {
  String get message {
    switch (this) {
      case StatusRequest.success:
        return 'تمت العملية بنجاح';
      case StatusRequest.failure:
        return 'حدث خطأ غير متوقع';
      case StatusRequest.loading:
        return 'جاري التحميل...';
      case StatusRequest.offline:
        return 'لا يوجد اتصال بالإنترنت';
      case StatusRequest.serverFailure:
        return 'خطأ في الخادم، حاول لاحقاً';
      case StatusRequest.unauthorized:
        return 'انتهت صلاحية الجلسة، سجل الدخول مرة أخرى';
      case StatusRequest.forbidden:
        return 'ليس لديك صلاحية للوصول';
      case StatusRequest.notFound:
        return 'البيانات المطلوبة غير موجودة';
      case StatusRequest.timeout:
        return 'انتهى وقت الاتصال، حاول مرة أخرى';
      case StatusRequest.noData:
        return 'لا توجد بيانات';
    }
  }

  bool get isSuccess => this == StatusRequest.success;
  bool get isLoading => this == StatusRequest.loading;
  bool get isError => !isSuccess && !isLoading;
}

import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/posts/services/post_service.dart';

/// Account Service - خدمة إدارة الحساب
class AccountService extends GetxService {
  final AuthController _authController = Get.find<AuthController>();

  // Get PostService safely
  PostService get _postService {
    if (!Get.isRegistered<PostService>()) {
      Get.put<PostService>(PostService(), permanent: true);
    }
    return Get.find<PostService>();
  }

  // ========== User Info ==========

  /// الحصول على المستخدم الحالي
  dynamic get currentUser => _authController.currentUser.value;

  /// التحقق من تسجيل الدخول
  bool get isLoggedIn => _authController.isUserLoggedIn.value;

  /// التحقق إذا كان المستخدم عامل
  bool get isWorker {
    final user = currentUser;
    if (user == null) return false;
    final role = (user.role ?? '').toString().toLowerCase();
    return role == 'worker' || user.workerProfile != null;
  }

  /// الحصول على اسم المستخدم
  String get userName => currentUser?.name ?? '';

  /// الحصول على صورة المستخدم
  String get userImage => currentUser?.imagePath ?? '';

  /// الحصول على رقم الهاتف
  String get userPhone => currentUser?.phone ?? '';

  // ========== Stats ==========

  /// عدد المنشورات
  int get postsCount => currentUser?.workerProfile?.projects?.length ?? 0;

  /// التقييم
  double get rating => currentUser?.workerProfile?.rating ?? 0.0;

  /// قائمة المشاريع
  List<dynamic> get projects => currentUser?.workerProfile?.projects ?? [];

  // ========== Actions ==========

  /// تسجيل الخروج
  Future<void> logout() async {
    await _authController.logout();
  }

  /// تحديث البيانات
  void refreshData() {
    _authController.notifyPostAdded();
  }

  /// الحصول على عدد الإعجابات لمنشور
  int getLikeCount(String projectId) {
    return _postService.getLikeCount(projectId);
  }

  /// التحقق من الإعجاب
  bool isLiked(String projectId) {
    return _postService.isLiked(projectId);
  }

  /// تبديل الإعجاب
  Future<void> toggleLike(String workerId, String projectId) async {
    await _postService.toggleLike(workerId, projectId);
    refreshData();
  }

  /// الحصول على عدد التعليقات
  int getCommentCount(String projectId) {
    return _postService.commentCounts[projectId] ?? 0;
  }

  // ========== Profile Formatting ==========

  /// تنسيق تاريخ الانضمام
  String formatJoinDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? "سنة" : "سنوات"}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? "شهر" : "أشهر"}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? "يوم" : "أيام"}';
    } else {
      return 'اليوم';
    }
  }

  /// تنسيق الأرقام (1000 -> 1K)
  String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  /// تنسيق السعر
  String formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}k';
    }
    return price.toStringAsFixed(0);
  }
}

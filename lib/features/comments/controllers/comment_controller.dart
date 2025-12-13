import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/comment_model.dart';
import '../services/comment_local_service.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/posts/models/project_model.dart';
import 'package:workers/features/posts/services/post_service.dart';

class CommentController extends GetxController {
  // ==================== Text Controllers ====================
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // ==================== Observable Variables ====================
  final RxList<Comment> comments = <Comment>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt commentsCount = 0.obs;
  final RxString commentText = ''.obs;

  // للرد على تعليق
  final Rx<Comment?> replyingTo = Rx<Comment?>(null);

  // المشروع الحالي
  String? _currentProjectId;
  Project? currentProject;
  dynamic currentUser;

  // ==================== Getters ====================

  String? get currentProjectId => _currentProjectId;

  bool get hasComments => comments.isNotEmpty;

  bool get isReplying => replyingTo.value != null;

  bool get canSubmit => commentText.value.trim().isNotEmpty && !isSubmitting.value;

  // ==================== Lifecycle ====================

  @override
  void onInit() {
    super.onInit();
    textController.addListener(_onTextChanged);
  }

  @override
  void onClose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    focusNode.dispose();
    clear();
    super.onClose();
  }

  void _onTextChanged() {
    commentText.value = textController.text;
  }

  // ==================== Initialize ====================

  void initialize(Project project, dynamic user) {
    currentProject = project;
    currentUser = user;
    loadComments(project.id);
  }

  // ==================== Main Methods ====================

  /// تحميل التعليقات لمشروع معين
  Future<void> loadComments(String projectId) async {
    try {
      _currentProjectId = projectId;
      isLoading.value = true;
      errorMessage.value = '';

      // استخدام الخدمة المحلية
      final loadedComments = await CommentLocalService.getCommentsByProjectId(projectId);
      comments.assignAll(loadedComments);

      // تحديث العدد
      commentsCount.value = await CommentLocalService.getCommentsCount(projectId);

      print('CommentController: Loaded ${comments.length} comments for project $projectId');
    } catch (e) {
      errorMessage.value = 'فشل في تحميل التعليقات';
      print('CommentController: Error loading comments: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث عدد التعليقات
  Future<void> _updateCommentsCount(String projectId) async {
    commentsCount.value = await CommentLocalService.getCommentsCount(projectId);
  }

  /// إضافة تعليق جديد
  Future<bool> addComment(String text) async {
    if (_currentProjectId == null) {
      errorMessage.value = 'لم يتم تحديد المشروع';
      return false;
    }

    if (text.trim().isEmpty) {
      errorMessage.value = 'التعليق لا يمكن أن يكون فارغاً';
      return false;
    }

    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      // جلب بيانات المستخدم الحالي
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) {
        errorMessage.value = 'يجب تسجيل الدخول أولاً';
        return false;
      }

      // إضافة التعليق باستخدام الخدمة المحلية
      final newComment = await CommentLocalService.addComment(
        projectId: _currentProjectId!,
        userId: currentUser.id,
        userName: currentUser.name,
        userImage: currentUser.imagePath,
        text: text.trim(),
        parentId: replyingTo.value?.id,
      );

      if (newComment == null) {
        errorMessage.value = 'فشل في إضافة التعليق';
        return false;
      }

      // إذا كان رداً، أضفه للتعليق الأصلي
      if (replyingTo.value != null) {
        final parentIndex = comments.indexWhere((c) => c.id == replyingTo.value!.id);
        if (parentIndex != -1) {
          final updatedReplies = List<Comment>.from(comments[parentIndex].replies)..add(newComment);
          comments[parentIndex] = comments[parentIndex].copyWith(replies: updatedReplies);
        }
        cancelReply();
      } else {
        // أضف التعليق في البداية
        comments.insert(0, newComment);
      }

      // تحديث العدد
      await _updateCommentsCount(_currentProjectId!);

      print('CommentController: Comment added successfully');
      return true;
    } catch (e) {
      errorMessage.value = 'حدث خطأ أثناء إضافة التعليق';
      print('CommentController: Error adding comment: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  /// تبديل حالة الإعجاب
  Future<bool> toggleLike(String commentId, {bool isReply = false, String? parentId}) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) {
        errorMessage.value = 'يجب تسجيل الدخول أولاً';
        return false;
      }

      // تبديل الإعجاب باستخدام الخدمة المحلية
      final success = await CommentLocalService.toggleLike(commentId, currentUser.id);

      if (success) {
        // إعادة تحميل التعليقات لتحديث القائمة
        await loadComments(_currentProjectId!);
        return true;
      }

      return false;
    } catch (e) {
      print('CommentController: Error toggling like: $e');
      return false;
    }
  }

  /// البحث عن تعليق بالـ ID (للاستخدام المستقبلي)
  // ignore: unused_element
  Comment? _findComment(String commentId) {
    for (final comment in comments) {
      if (comment.id == commentId) return comment;
      for (final reply in comment.replies) {
        if (reply.id == commentId) return reply;
      }
    }
    return null;
  }

  /// حذف تعليق
  Future<bool> deleteComment(String commentId, {bool isReply = false, String? parentId}) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) {
        errorMessage.value = 'يجب تسجيل الدخول أولاً';
        return false;
      }

      // حذف التعليق باستخدام الخدمة المحلية
      final success = await CommentLocalService.deleteComment(commentId);

      if (!success) {
        errorMessage.value = 'فشل في حذف التعليق';
        return false;
      }

      // تحديث القائمة المحلية
      if (isReply && parentId != null) {
        final parentIndex = comments.indexWhere((c) => c.id == parentId);
        if (parentIndex != -1) {
          final updatedReplies = comments[parentIndex].replies
              .where((r) => r.id != commentId)
              .toList();
          comments[parentIndex] = comments[parentIndex].copyWith(replies: updatedReplies);
        }
      } else {
        comments.removeWhere((c) => c.id == commentId);
      }

      // تحديث العدد
      if (_currentProjectId != null) {
        await _updateCommentsCount(_currentProjectId!);
      }

      return true;
    } catch (e) {
      print('CommentController: Error deleting comment: $e');
      return false;
    }
  }

  /// تحديث نص تعليق
  Future<bool> updateComment(String commentId, String newText) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) {
        errorMessage.value = 'يجب تسجيل الدخول أولاً';
        return false;
      }

      // تحديث التعليق باستخدام الخدمة المحلية
      final success = await CommentLocalService.updateComment(commentId, newText);

      if (!success) {
        errorMessage.value = 'فشل في تحديث التعليق';
        return false;
      }

      // تحديث محلي
      final index = comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        comments[index] = comments[index].copyWith(text: newText);
      }

      return true;
    } catch (e) {
      print('CommentController: Error updating comment: $e');
      return false;
    }
  }

  // ==================== Reply Methods ====================

  /// بدء الرد على تعليق
  void startReply(Comment comment) {
    replyingTo.value = comment;
    focusNode.requestFocus();
  }

  /// إلغاء الرد
  void cancelReply() {
    replyingTo.value = null;
  }

  // ==================== Submit Methods ====================

  /// إرسال التعليق
  Future<void> submitComment() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final success = await addComment(text);
    if (success) {
      textController.clear();
      focusNode.unfocus();
      if (currentProject != null && Get.isRegistered<PostService>()) {
        Get.find<PostService>().refreshCommentCount(currentProject!.id);
      }
    }
  }

  /// تبديل الإعجاب مع البحث عن parentId
  void toggleLikeWithSearch(Comment comment, {bool isReply = false}) {
    String? parentId;
    if (isReply) {
      for (var c in comments) {
        if (c.replies.any((r) => r.id == comment.id)) {
          parentId = c.id;
          break;
        }
      }
    }
    toggleLike(comment.id, isReply: isReply, parentId: parentId);
  }

  /// حذف مع البحث عن parentId
  Future<bool> deleteCommentWithSearch(Comment comment, {bool isReply = false}) async {
    String? parentId;
    if (isReply) {
      for (var c in comments) {
        if (c.replies.any((r) => r.id == comment.id)) {
          parentId = c.id;
          break;
        }
      }
    }
    final deleted = await deleteComment(comment.id, isReply: isReply, parentId: parentId);
    if (deleted && currentProject != null && Get.isRegistered<PostService>()) {
      Get.find<PostService>().refreshCommentCount(currentProject!.id);
    }
    return deleted;
  }

  // ==================== Utility Methods ====================

  /// إعادة تحميل التعليقات
  Future<void> refreshComments() async {
    if (_currentProjectId != null) {
      await loadComments(_currentProjectId!);
    }
  }

  /// مسح الحالة
  void clear() {
    comments.clear();
    commentsCount.value = 0;
    replyingTo.value = null;
    errorMessage.value = '';
    commentText.value = '';
    _currentProjectId = null;
    currentProject = null;
    currentUser = null;
  }

  /// جلب عدد التعليقات لمشروع (بدون تحميل كامل)
  Future<int> getCommentsCountForProject(String projectId) async {
    return await CommentLocalService.getCommentsCount(projectId);
  }

  /// تنسيق الوقت
  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${difference.inDays ~/ 7}أ';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}ي';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}س';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}د';
    } else {
      return 'الآن';
    }
  }

  /// إغلاق الصفحة
  void goBack() {
    Get.back();
  }

  /// مشاركة
  void sharePost() {
    Get.snackbar('مشاركة', 'مشاركة المنشور', snackPosition: SnackPosition.BOTTOM);
  }
}

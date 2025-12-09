/// Comment Local Service - خدمة التخزين المحلي للتعليقات
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment_model.dart';

class CommentLocalService {
  static const String _commentsKey = 'local_comments';
  static SharedPreferences? _prefs;

  /// تهيئة الخدمة
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _instance async {
    await init();
    return _prefs!;
  }

  // ==================== Get Comments ====================

  /// جلب جميع التعليقات لمشروع معين
  static Future<List<Comment>> getCommentsByProjectId(String projectId) async {
    await _instance; // التأكد من تهيئة الخدمة
    final allComments = await _getAllComments();

    // تصفية التعليقات حسب المشروع وإرجاع التعليقات الرئيسية فقط (بدون الردود)
    final projectComments = allComments
        .where((c) => c.projectId == projectId && c.parentId == null)
        .toList();

    // إضافة الردود لكل تعليق
    for (int i = 0; i < projectComments.length; i++) {
      final replies = allComments.where((c) => c.parentId == projectComments[i].id).toList();
      projectComments[i] = projectComments[i].copyWith(replies: replies);
    }

    // ترتيب من الأحدث للأقدم
    projectComments.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return projectComments;
  }

  /// جلب عدد التعليقات لمشروع معين
  static Future<int> getCommentsCount(String projectId) async {
    final allComments = await _getAllComments();
    return allComments.where((c) => c.projectId == projectId).length;
  }

  // ==================== Add Comment ====================

  /// إضافة تعليق جديد
  static Future<Comment?> addComment({
    required String projectId,
    required String userId,
    required String userName,
    String? userImage,
    required String text,
    String? parentId,
  }) async {
    await _instance; // التأكد من تهيئة الخدمة
    final allComments = await _getAllComments();

    // إنشاء ID فريد
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final newComment = Comment(
      id: id,
      projectId: projectId,
      userId: userId,
      userName: userName,
      userImage: userImage,
      text: text,
      parentId: parentId,
      createdAt: DateTime.now(),
      likes: 0,
      likedBy: [],
      replies: [],
    );

    allComments.add(newComment);
    await _saveAllComments(allComments);

    return newComment;
  }

  // ==================== Update Comment ====================

  /// تحديث تعليق
  static Future<bool> updateComment(String commentId, String newText) async {
    final allComments = await _getAllComments();
    final index = allComments.indexWhere((c) => c.id == commentId);

    if (index == -1) return false;

    allComments[index] = allComments[index].copyWith(text: newText);

    await _saveAllComments(allComments);
    return true;
  }

  // ==================== Delete Comment ====================

  /// حذف تعليق
  static Future<bool> deleteComment(String commentId) async {
    final allComments = await _getAllComments();

    // حذف التعليق والردود عليه
    allComments.removeWhere((c) => c.id == commentId || c.parentId == commentId);

    await _saveAllComments(allComments);
    return true;
  }

  // ==================== Like/Unlike ====================

  /// تبديل الإعجاب
  static Future<bool> toggleLike(String commentId, String userId) async {
    final allComments = await _getAllComments();
    final index = allComments.indexWhere((c) => c.id == commentId);

    if (index == -1) return false;

    final comment = allComments[index];
    final likedBy = List<String>.from(comment.likedBy);

    if (likedBy.contains(userId)) {
      likedBy.remove(userId);
    } else {
      likedBy.add(userId);
    }

    allComments[index] = comment.copyWith(likedBy: likedBy, likes: likedBy.length);

    await _saveAllComments(allComments);
    return true;
  }

  // ==================== Private Helpers ====================

  /// جلب جميع التعليقات من التخزين
  static Future<List<Comment>> _getAllComments() async {
    final prefs = await _instance;
    final jsonString = prefs.getString(_commentsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Comment.fromMap(json)).toList();
    } catch (e) {
      print('Error loading comments: $e');
      return [];
    }
  }

  /// حفظ جميع التعليقات
  static Future<void> _saveAllComments(List<Comment> comments) async {
    final prefs = await _instance;
    final jsonList = comments.map((c) => c.toMap()).toList();
    await prefs.setString(_commentsKey, jsonEncode(jsonList));
  }

  /// مسح جميع التعليقات (للاختبار)
  static Future<void> clearAllComments() async {
    final prefs = await _instance;
    await prefs.remove(_commentsKey);
  }
}

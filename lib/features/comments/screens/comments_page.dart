/// Comments Page - صفحة عرض التعليقات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../posts/models/project_model.dart';
import '../models/comment_model.dart';
import '../controllers/comment_controller.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import '../../posts/services/post_service.dart';

class CommentsPage extends StatefulWidget {
  final Project project;
  final dynamic user;

  const CommentsPage({super.key, required this.project, required this.user});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late CommentController _commentController;
  bool _controllerCreatedLocally = false;

  @override
  void initState() {
    super.initState();
    // Reuse existing controller instance when it is already registered (e.g. after returning
    // from the page) to avoid GetX duplicate registration errors that prevent navigation.
    if (Get.isRegistered<CommentController>()) {
      _commentController = Get.find<CommentController>();
    } else {
      _commentController = Get.put(CommentController());
      _controllerCreatedLocally = true;
    }
    _commentController.loadComments(widget.project.id);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    // Remove the controller instance when we created it here so it can be re-initialised on
    // the next visit without GetX throwing an "already registered" exception.
    if (_controllerCreatedLocally && Get.isRegistered<CommentController>()) {
      Get.delete<CommentController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // معاينة المنشور
          _buildPostPreview(isDark),

          Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),

          // قائمة التعليقات
          Expanded(
            child: Obx(() {
              if (_commentController.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: Color(0xFF0095F6)));
              }

              if (_commentController.comments.isEmpty) {
                return _buildEmptyState(isDark);
              }

              return RefreshIndicator(
                onRefresh: () => _commentController.refreshComments(),
                color: Color(0xFF0095F6),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: _commentController.comments.length,
                  itemBuilder: (context, index) {
                    final comment = _commentController.comments[index];
                    return _buildCommentItem(comment, isDark, index: index);
                  },
                ),
              );
            }),
          ),

          // حقل إدخال التعليق
          _buildCommentInput(isDark, currentUser),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Text(
          'التعليقات (${_commentController.commentsCount.value})',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.send_outlined, color: isDark ? Colors.white : Colors.black),
          onPressed: () {
            Get.snackbar('مشاركة', 'مشاركة المنشور', snackPosition: SnackPosition.BOTTOM);
          },
        ),
      ],
    );
  }

  Widget _buildPostPreview(bool isDark) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          // صورة المنشور
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: widget.project.images.isNotEmpty
                ? Image.file(
                    File(widget.project.images.first),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
          SizedBox(width: 12),

          // معلومات المنشور
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Obx(
                  () => Text(
                    '${widget.project.likes} إعجاب • ${_commentController.commentsCount.value} تعليق',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'لا توجد تعليقات بعد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text('كن أول من يعلق!', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildCommentItem(
    Comment comment,
    bool isDark, {
    bool isReply = false,
    int? index,
    int? replyIndex,
    int? parentIndex,
  }) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;
    final isOwner = currentUserId == comment.userId;

    return Obx(() {
      // جلب التعليق المحدث من القائمة
      Comment currentComment = comment;
      if (!isReply && index != null && index < _commentController.comments.length) {
        currentComment = _commentController.comments[index];
      } else if (isReply && parentIndex != null && replyIndex != null) {
        if (parentIndex < _commentController.comments.length) {
          final parent = _commentController.comments[parentIndex];
          if (replyIndex < parent.replies.length) {
            currentComment = parent.replies[replyIndex];
          }
        }
      }

      final isLiked = currentComment.isLikedBy(currentUserId ?? '');

      return Container(
        padding: EdgeInsets.symmetric(horizontal: isReply ? 56 : 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المستخدم
            GestureDetector(
              onTap: () {
                // الانتقال لصفحة المستخدم
              },
              child: CircleAvatar(
                radius: isReply ? 14 : 18,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                backgroundImage:
                    currentComment.userImage != null && currentComment.userImage!.isNotEmpty
                    ? FileImage(File(currentComment.userImage!))
                    : null,
                child: currentComment.userImage == null || currentComment.userImage!.isEmpty
                    ? Icon(
                        Icons.person,
                        size: isReply ? 14 : 18,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      )
                    : null,
              ),
            ),
            SizedBox(width: 12),

            // محتوى التعليق
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم المستخدم
                  Text(
                    currentComment.userName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  // نص التعليق
                  Text(
                    currentComment.text,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black),
                  ),
                  SizedBox(height: 6),

                  // أزرار الإجراءات
                  Row(
                    children: [
                      Text(
                        _formatTimeAgo(currentComment.createdAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      SizedBox(width: 16),
                      if (currentComment.likes > 0)
                        Text(
                          '${currentComment.likes} إعجاب',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _startReply(currentComment),
                        child: Text(
                          'رد',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (isOwner) ...[
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _showDeleteDialog(currentComment, isReply: isReply),
                          child: Text(
                            'حذف',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // الردود
                  if (currentComment.replies.isNotEmpty && !isReply) ...[
                    SizedBox(height: 12),
                    ...currentComment.replies.asMap().entries.map(
                      (entry) => _buildCommentItem(
                        entry.value,
                        isDark,
                        isReply: true,
                        replyIndex: entry.key,
                        parentIndex: index,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // زر الإعجاب
            GestureDetector(
              onTap: () => _toggleLike(currentComment, isReply: isReply),
              child: Padding(
                padding: EdgeInsets.only(left: 8, top: 4),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 14,
                  color: isLiked ? Colors.red : Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommentInput(bool isDark, dynamic currentUser) {
    return Obx(() {
      final isReplying = _commentController.isReplying;
      final replyingTo = _commentController.replyingTo.value;

      return Container(
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          border: Border(
            top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!, width: 0.5),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط الرد
              if (isReplying)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: isDark ? Color(0xFF262626) : Colors.grey[100],
                  child: Row(
                    children: [
                      Text(
                        'الرد على ${replyingTo?.userName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () => _commentController.cancelReply(),
                        child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

              // حقل الإدخال
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // صورة المستخدم
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      backgroundImage:
                          currentUser?.imagePath != null && currentUser!.imagePath.isNotEmpty
                          ? FileImage(File(currentUser.imagePath))
                          : null,
                      child: currentUser?.imagePath == null || currentUser!.imagePath.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 16,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            )
                          : null,
                    ),
                    SizedBox(width: 12),

                    // حقل النص
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Color(0xFF262626) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _textController,
                          focusNode: _focusNode,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: isReplying ? 'اكتب رداً...' : 'أضف تعليقاً...',
                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          maxLines: null,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),

                    // زر الإيموجي
                    GestureDetector(
                      onTap: () {},
                      child: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[500], size: 24),
                    ),
                    SizedBox(width: 8),

                    // زر الإرسال
                    Obx(
                      () => GestureDetector(
                        onTap:
                            _textController.text.trim().isNotEmpty &&
                                !_commentController.isSubmitting.value
                            ? _submitComment
                            : null,
                        child: _commentController.isSubmitting.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF0095F6),
                                ),
                              )
                            : Text(
                                'نشر',
                                style: TextStyle(
                                  color: _textController.text.trim().isNotEmpty
                                      ? Color(0xFF0095F6)
                                      : Colors.grey[400],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==================== Actions ====================

  void _submitComment() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final success = await _commentController.addComment(text);
    if (success) {
      _textController.clear();
      _focusNode.unfocus();
      if (Get.isRegistered<PostService>()) {
        Get.find<PostService>().refreshCommentCount(widget.project.id);
      }
    }
  }

  void _startReply(Comment comment) {
    _commentController.startReply(comment);
    _focusNode.requestFocus();
  }

  void _toggleLike(Comment comment, {bool isReply = false}) {
    String? parentId;
    if (isReply) {
      for (var c in _commentController.comments) {
        if (c.replies.any((r) => r.id == comment.id)) {
          parentId = c.id;
          break;
        }
      }
    }
    _commentController.toggleLike(comment.id, isReply: isReply, parentId: parentId);
  }

  void _showDeleteDialog(Comment comment, {bool isReply = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? Color(0xFF262626) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'حذف التعليق',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'هل أنت متأكد من حذف هذا التعليق؟',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              String? parentId;
              if (isReply) {
                for (var c in _commentController.comments) {
                  if (c.replies.any((r) => r.id == comment.id)) {
                    parentId = c.id;
                    break;
                  }
                }
              }
              final deleted = await _commentController.deleteComment(
                comment.id,
                isReply: isReply,
                parentId: parentId,
              );
              if (deleted && Get.isRegistered<PostService>()) {
                Get.find<PostService>().refreshCommentCount(widget.project.id);
              }
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
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
}

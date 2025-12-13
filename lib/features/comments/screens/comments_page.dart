/// Comments Page - صفحة عرض التعليقات
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../posts/models/project_model.dart';
import '../models/comment_model.dart';
import '../controllers/comment_controller.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';

class CommentsPage extends StatelessWidget {
  final Project project;
  final dynamic user;

  const CommentsPage({super.key, required this.project, required this.user});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final controller = Get.put(CommentController(), tag: 'comments_${project.id}');
    controller.initialize(project, user);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
      appBar: _CommentsAppBar(controller: controller, isDark: isDark),
      body: Column(
        children: [
          // معاينة المنشور
          _PostPreview(project: project, controller: controller, isDark: isDark),

          Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[300]),

          // قائمة التعليقات
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                    child: CircularProgressIndicator(color: Color(0xFF0095F6)));
              }

              if (controller.comments.isEmpty) {
                return _EmptyState(isDark: isDark);
              }

              return RefreshIndicator(
                onRefresh: () => controller.refreshComments(),
                color: Color(0xFF0095F6),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.comments.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      final comment = controller.comments[index];
                      return _CommentItem(
                        comment: comment,
                        controller: controller,
                        isDark: isDark,
                        index: index,
                      );
                    });
                  },
                ),
              );
            }),
          ),

          // حقل إدخال التعليق
          Obx(() => _CommentInput(
                controller: controller,
                isDark: isDark,
                currentUser: authController.currentUser.value,
              )),
        ],
      ),
    );
  }
}

class _CommentsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final CommentController controller;
  final bool isDark;

  const _CommentsAppBar({required this.controller, required this.isDark});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
        onPressed: controller.goBack,
      ),
      title: Obx(
        () => Text(
          'التعليقات (${controller.commentsCount.value})',
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
          onPressed: controller.sharePost,
        ),
      ],
    );
  }
}

class _PostPreview extends StatelessWidget {
  final Project project;
  final CommentController controller;
  final bool isDark;

  const _PostPreview({
    required this.project,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          // صورة المنشور
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: project.images.isNotEmpty
                ? Image.file(
                    File(project.images.first),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                  )
                : _ImagePlaceholder(),
          ),
          SizedBox(width: 12),

          // معلومات المنشور
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
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
                    '${project.likes} إعجاب • ${controller.commentsCount.value} تعليق',
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
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey[300],
      child: Icon(Icons.image, color: Colors.grey),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'كن أول من يعلق!',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final CommentController controller;
  final bool isDark;
  final int index;
  final bool isReply;
  final int? replyIndex;
  final int? parentIndex;

  const _CommentItem({
    required this.comment,
    required this.controller,
    required this.isDark,
    required this.index,
    this.isReply = false,
    this.replyIndex,
    this.parentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;
    final isOwner = currentUserId == comment.userId;
    final isLiked = comment.isLikedBy(currentUserId ?? '');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isReply ? 56 : 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المستخدم
          GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: isReply ? 14 : 18,
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
              backgroundImage: comment.userImage != null && comment.userImage!.isNotEmpty
                  ? FileImage(File(comment.userImage!))
                  : null,
              child: comment.userImage == null || comment.userImage!.isEmpty
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
                  comment.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                // نص التعليق
                Text(
                  comment.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 6),

                // أزرار الإجراءات
                Row(
                  children: [
                    Text(
                      controller.formatTimeAgo(comment.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 16),
                    if (comment.likes > 0)
                      Text(
                        '${comment.likes} إعجاب',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: () => controller.startReply(comment),
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
                        onTap: () => _showDeleteDialog(context, comment),
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
                if (comment.replies.isNotEmpty && !isReply) ...[
                  SizedBox(height: 12),
                  ...comment.replies.asMap().entries.map(
                        (entry) => _CommentItem(
                          comment: entry.value,
                          controller: controller,
                          isDark: isDark,
                          index: index,
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
            onTap: () => controller.toggleLikeWithSearch(comment, isReply: isReply),
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
  }

  void _showDeleteDialog(BuildContext context, Comment comment) {
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
              await controller.deleteCommentWithSearch(comment, isReply: isReply);
            },
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final CommentController controller;
  final bool isDark;
  final dynamic currentUser;

  const _CommentInput({
    required this.controller,
    required this.isDark,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط الرد
            Obx(() {
              if (!controller.isReplying) return SizedBox.shrink();
              final replyingTo = controller.replyingTo.value;
              return Container(
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
                      onTap: controller.cancelReply,
                      child: Icon(Icons.close, size: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }),

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
                      child: Obx(() => TextField(
                            controller: controller.textController,
                            focusNode: controller.focusNode,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: controller.isReplying
                                  ? 'اكتب رداً...'
                                  : 'أضف تعليقاً...',
                              hintStyle:
                                  TextStyle(color: Colors.grey[500], fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                            maxLines: null,
                          )),
                    ),
                  ),
                  SizedBox(width: 8),

                  // زر الإيموجي
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.emoji_emotions_outlined,
                        color: Colors.grey[500], size: 24),
                  ),
                  SizedBox(width: 8),

                  // زر الإرسال
                  Obx(
                    () => GestureDetector(
                      onTap: controller.canSubmit ? controller.submitComment : null,
                      child: controller.isSubmitting.value
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
                                color: controller.canSubmit
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
  }
}

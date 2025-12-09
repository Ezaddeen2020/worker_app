import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import '../features/posts/models/project_model.dart';
import '../features/profile/models/user_model.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import '../features/posts/services/post_service.dart';
import 'post_detail_view.dart';
import '../features/posts/models/project_with_user.dart';
import '../features/comments/screens/comments_page.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final User user;
  final bool showUserHeader;
  final VoidCallback? onLikeChanged;
  final List<ProjectWithUser>? allPosts;

  const ProjectCard({
    super.key,
    required this.project,
    required this.user,
    this.showUserHeader = true,
    this.onLikeChanged,
    this.allPosts,
  });

  void _toggleLike() async {
    final postService = Get.find<PostService>();
    final ok = await postService.toggleLike(user.id, project.id);

    if (!ok) {
      Get.snackbar('خطأ', 'فشل تغيير حالة اللايك');
    }
  }

  void _openComments(BuildContext context) {
    final postService = Get.find<PostService>();
    final future = Get.to(
      () => CommentsPage(project: project, user: user),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );

    future?.then((_) => postService.refreshCommentCount(project.id));
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = project.images.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postService = Get.find<PostService>();

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User header (only if showUserHeader is true)
            if (showUserHeader) ...[
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // User profile image
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: ClipOval(child: _buildProfileImage(user.imagePath, 40)),
                    ),
                    const SizedBox(width: 12),
                    // User name and post time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            _formatDate(project.createdAt),
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Three dots menu for post options
                    if (user.id == Get.find<AuthController>().currentUser.value?.id)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        color: isDark ? Color(0xFF2C2C2C) : Colors.white,
                        onSelected: (String result) {
                          if (result == 'delete') {
                            _showDeleteConfirmationDialog(context);
                          }
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Text(
                              'حذف المنشور',
                              style: TextStyle(color: isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],

            // Project images
            if (hasImages)
              SizedBox(
                height: 300,
                child: PageView.builder(
                  itemCount: project.images.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        final postsToShow =
                            allPosts ?? [ProjectWithUser(project: project, user: user)];
                        final currentIndex = postsToShow.indexWhere(
                          (p) => p.project.id == project.id,
                        );

                        Get.to(
                          () => PostDetailView(
                            project: project,
                            user: user,
                            allPosts: postsToShow,
                            initialIndex: currentIndex >= 0 ? currentIndex : 0,
                          ),
                        );
                      },
                      child: Image.file(
                        File(project.images[index]),
                        fit: BoxFit.cover,
                        cacheWidth: 600, // تحسين الأداء بتحديد حجم الكاش
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 48),
                          );
                        },
                      ),
                    );
                  },
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  final postsToShow = allPosts ?? [ProjectWithUser(project: project, user: user)];
                  final currentIndex = postsToShow.indexWhere((p) => p.project.id == project.id);

                  Get.to(
                    () => PostDetailView(
                      project: project,
                      user: user,
                      allPosts: postsToShow,
                      initialIndex: currentIndex >= 0 ? currentIndex : 0,
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey,
                  ),
                ),
              ),

            // Project content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    project.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  if (project.price != null && project.price! > 0)
                    Text(
                      '${project.price} ر.س',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 5, 95, 66),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    project.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Likes and actions - Using Obx for reactive updates
                  Obx(() {
                    // Listen to PostService updates
                    postService.updateTrigger.value;
                    final isLiked = postService.isLiked(project.id);
                    final likeCount = postService.getLikeCount(project.id);
                    final commentCount = postService.commentCounts[project.id] ?? 0;

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleLike,
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked
                                    ? Colors.red
                                    : (isDark ? Colors.grey[400] : Colors.grey),
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$likeCount',
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => _openComments(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                color: isDark ? Colors.grey[400] : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$commentCount',
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.share, color: isDark ? Colors.grey[400] : Colors.grey, size: 20),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا المنشور؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Get.back();
              await _deleteProject();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Delete the project
  Future<void> _deleteProject() async {
    try {
      final postService = Get.find<PostService>();
      final success = await postService.deletePost(project.id, user.id);

      if (success) {
        onLikeChanged?.call();
        Get.snackbar('نجاح', 'تم حذف المنشور بنجاح');
      } else {
        Get.snackbar('خطأ', 'فشل في حذف المنشور');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء حذف المنشور: $e');
    }
  }

  Widget _buildProfileImage(String? imagePath, double size) {
    try {
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                alignment: Alignment.center,
                child: Icon(Icons.person, size: size * 0.5, color: Colors.grey[600]),
              );
            },
          );
        }
      }
    } catch (_) {}

    return Container(
      width: size,
      height: size,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey[600]),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}

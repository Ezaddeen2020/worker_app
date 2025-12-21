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
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF353E47) : Color(0xFFD6D6D6),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.grey.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[400]!, width: 1.5),
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
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
                child: Stack(
                  children: [
                    SizedBox(
                      height: 220,
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
                              width: double.infinity,
                              cacheWidth: 600,
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
                    ),
                    if (project.images.length > 1)
                      Positioned(
                        bottom: 8,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${project.images.length} صور',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
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
                  height: 160,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[850] : Colors.grey[200],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Icon(
                    Icons.image,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey,
                  ),
                ),
              ),

            // Project content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with same card background
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF353E47) : Color(0xFFD6D6D6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
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
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    project.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Likes and actions - Using Obx for reactive updates
                  Obx(() {
                    postService.updateTrigger.value;
                    final isLiked = postService.isLiked(project.id);
                    final likeCount = postService.getLikeCount(project.id);
                    final commentCount = postService.commentCounts[project.id] ?? 0;
                    return Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _toggleLike,
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked
                                    ? Colors.red
                                    : (isDark ? Colors.grey[400] : Colors.grey),
                                size: 22,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$likeCount',
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _openComments(context),
                          child: Row(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                color: isDark ? Colors.grey[400] : Colors.grey,
                                size: 22,
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
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {},
                          child: Icon(
                            Icons.share,
                            color: isDark ? Colors.grey[400] : Colors.grey,
                            size: 22,
                          ),
                        ),
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

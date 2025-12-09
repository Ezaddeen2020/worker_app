import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import '../features/posts/models/project_model.dart';
import '../features/profile/models/user_model.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'post_detail_view.dart';
import '../features/posts/models/project_with_user.dart';

class ProjectGridItem extends StatefulWidget {
  final Project project;
  final User user;
  final List<ProjectWithUser>? allPosts; // Add this parameter
  final int? initialIndex; // Add this parameter
  final VoidCallback? onLikeChanged; // Add this parameter

  const ProjectGridItem({
    super.key,
    required this.project,
    required this.user,
    this.allPosts, // Add this parameter
    this.initialIndex, // Add this parameter
    this.onLikeChanged, // Add this parameter
  });

  @override
  State<ProjectGridItem> createState() => _ProjectGridItemState();
}

class _ProjectGridItemState extends State<ProjectGridItem> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _initializeLikeState();
  }

  @override
  void didUpdateWidget(covariant ProjectGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize like state when widget is updated with new data
    _initializeLikeState();
  }

  void _initializeLikeState() {
    final likedBy = widget.project.likedBy;
    final currentUserId = Get.find<AuthController>().currentUser.value?.id;
    _isLiked = currentUserId != null && likedBy.contains(currentUserId);
    _likeCount = likedBy.length;
  }

  void _toggleLike() async {
    final authController = Get.find<AuthController>();

    final ok = await authController.toggleLikeOnProject(
      workerUserId: widget.user.id,
      projectId: widget.project.id,
    );

    if (ok) {
      setState(() {
        _isLiked = !_isLiked;
        _likeCount = _isLiked ? _likeCount + 1 : _likeCount - 1;
      });

      print('ProjectGridItem: Updated local like state. Now liked: $_isLiked, count: $_likeCount');
    } else {
      Get.snackbar('خطأ', 'فشل تغيير حالة اللايك');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImages = widget.project.images.isNotEmpty;

    return GestureDetector(
      onTap: () {
        // Use the provided allPosts list or get all posts for the current user
        List<ProjectWithUser> postsToShow;
        int currentIndex;

        if (widget.allPosts != null && widget.initialIndex != null) {
          // Use the provided lists and index
          postsToShow = widget.allPosts!;
          currentIndex = widget.initialIndex!;
        } else {
          // Fallback to getting all posts for the current user
          final authController = Get.find<AuthController>();
          final currentUser = authController.currentUser.value;
          if (currentUser != null && currentUser.workerProfile != null) {
            final allProjects = currentUser.workerProfile!.projects;
            postsToShow = allProjects
                .map((project) => ProjectWithUser(project: project, user: currentUser))
                .toList();
            // Find the index of the tapped project
            currentIndex = allProjects.indexWhere((project) => project.id == widget.project.id);
          } else {
            // Fallback to single post
            postsToShow = [ProjectWithUser(project: widget.project, user: widget.user)];
            currentIndex = 0;
          }
        }

        // Open the detailed post view with all posts and current index
        Get.to(
          () => PostDetailView(
            project: widget.project,
            user: widget.user,
            allPosts: postsToShow,
            initialIndex: currentIndex,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
          color: Colors.grey[100],
        ),
        child: Stack(
          children: [
            // الصورة أو placeholder
            if (hasImages)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(widget.project.images.first),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              )
            else
              Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey, size: 40),
              ),

            // Gradient overlay مع الأيقونات
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),

            // عدد الصور والكلايك
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // عدد الصور
                  if (hasImages && widget.project.images.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.project.images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // عداد اللايكات
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '$_likeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // زر اللايك (في الزاوية العلوية اليمنى)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: _toggleLike,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                  child: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            // Three dots menu for post options (only for own posts)
            if (widget.user.id == Get.find<AuthController>().currentUser.value?.id)
              Positioned(
                top: 4,
                left: 4,
                child: GestureDetector(
                  onTap: _showDeleteConfirmationDialog,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.more_vert, color: Colors.white, size: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا المنشور؟'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              // Close the dialog
              Get.back();

              // Delete the project
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
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) return;

      // Get the updated projects list without the current project
      final workerProfile = currentUser.workerProfile;
      if (workerProfile == null) return;

      final updatedProjects = List<Project>.from(workerProfile.projects)
        ..removeWhere((project) => project.id == widget.project.id);

      final updatedProfile = workerProfile.copyWith(projects: updatedProjects);

      // Update the user with the updated profile
      final success = await authController.updateUser(workerProfile: updatedProfile);

      if (success) {
        Get.snackbar('نجاح', 'تم حذف المنشور بنجاح');
        // Notify the system that a post was deleted
        print('ProjectGridItem: Notifying post deleted');
        authController.notifyPostAdded();
      } else {
        Get.snackbar('خطأ', 'فشل في حذف المنشور');
      }
    } catch (e) {
      Get.snackbar('خطأ', 'حدث خطأ أثناء حذف المنشور: $e');
    }
  }
}

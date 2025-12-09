import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import '../features/posts/models/project_model.dart';
import '../features/profile/models/user_model.dart';
import '../features/posts/services/post_service.dart';
import '../features/posts/models/project_with_user.dart';
import '../features/comments/screens/comments_page.dart';

class PostDetailView extends StatefulWidget {
  final Project project;
  final User user;
  final List<ProjectWithUser> allPosts;
  final int initialIndex;

  const PostDetailView({
    super.key,
    required this.project,
    required this.user,
    required this.allPosts,
    required this.initialIndex,
  });

  @override
  State<PostDetailView> createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> {
  late PageController _pageController;
  late PageController _postController;
  int _currentPage = 0;
  int _currentPostIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _postController = PageController(initialPage: widget.initialIndex);
    _currentPostIndex = widget.initialIndex;
  }

  void _openComments(Project project, User user) {
    final postService = Get.find<PostService>();
    final future = Get.to(
      () => CommentsPage(project: project, user: user),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 300),
    );

    future?.then((_) => postService.refreshCommentCount(project.id));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _postController.dispose();
    super.dispose();
  }

  void _toggleLike(Project project, User user) async {
    final postService = Get.find<PostService>();
    await postService.toggleLike(user.id, project.id);
  }

  @override
  Widget build(BuildContext context) {
    final postService = Get.find<PostService>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _postController,
          scrollDirection: Axis.vertical,
          itemCount: widget.allPosts.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = 0;
              _currentPostIndex = index;
              _pageController = PageController();
            });
          },
          itemBuilder: (context, postIndex) {
            final postWithUser = widget.allPosts[postIndex];
            final hasImages = postWithUser.project.images.isNotEmpty;
            final imageCount = postWithUser.project.images.length;

            return Obx(() {
              // Listen to PostService updates
              postService.updateTrigger.value;
              final isLiked = postService.isLiked(postWithUser.project.id);
              final likeCount = postService.getLikeCount(postWithUser.project.id);
              final commentCount = postService.commentCounts[postWithUser.project.id] ?? 0;

              return Column(
                children: [
                  // Header with user info
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // User profile image
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: ClipOval(
                            child: _buildProfileImage(postWithUser.user.imagePath, 40),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // User name
                        Expanded(
                          child: Text(
                            postWithUser.user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Close button
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ),

                  // Main image area (taking most of the screen)
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Main image with page view for multiple images
                        if (hasImages)
                          PageView.builder(
                            controller: postIndex == _currentPostIndex ? _pageController : null,
                            itemCount: imageCount,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return InteractiveViewer(
                                child: Image.file(
                                  File(postWithUser.project.images[index]),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[900],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 48,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        else
                          Container(
                            color: Colors.grey[900],
                            child: const Icon(Icons.image, color: Colors.grey, size: 48),
                          ),

                        // Image counter for multiple images
                        if (hasImages && imageCount > 1)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${_currentPage + 1} / $imageCount',
                                style: const TextStyle(color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Post details section
                  Container(
                    color: Colors.black,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Like button and counters
                        Row(
                          children: [
                            // Like button
                            IconButton(
                              icon: Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.white,
                                size: 28,
                              ),
                              onPressed: () => _toggleLike(postWithUser.project, postWithUser.user),
                            ),
                            const SizedBox(width: 16),

                            // Comment button
                            IconButton(
                              icon: const Icon(
                                Icons.comment_outlined,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () =>
                                  _openComments(postWithUser.project, postWithUser.user),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$commentCount',
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(width: 16),

                            // Share button
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 28),
                              onPressed: () => Get.snackbar('معلومة', 'ميزة المشاركة قريباً'),
                            ),
                            const Spacer(),

                            // Bookmark button
                            IconButton(
                              icon: const Icon(
                                Icons.bookmark_border,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () => Get.snackbar('معلومة', 'ميزة الحفظ قريباً'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Like count
                        Text(
                          '$likeCount إعجاب',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Post title and description
                        Text(
                          postWithUser.project.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          postWithUser.project.description,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                        ),

                        const SizedBox(height: 8),

                        // Post date
                        Text(
                          _formatDate(postWithUser.project.createdAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),

                        const SizedBox(height: 16),

                        // Add comment section
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'أضف تعليقاً...',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.sentiment_satisfied, color: Colors.grey[600]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            });
          },
        ),
      ),
    );
  }

  /// Safely build a circular profile image from a local file path.
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
                color: Colors.grey[800],
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
      color: Colors.grey[800],
      alignment: Alignment.center,
      child: Icon(Icons.person, size: size * 0.5, color: Colors.grey[600]),
    );
  }

  /// Format date to a readable string
  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'قبل ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'قبل ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'قبل ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}

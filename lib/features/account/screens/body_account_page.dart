// account/body_account_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'dart:io';
import 'package:workers/features/posts/models/project_model.dart';
import 'package:workers/features/posts/services/post_service.dart';
import 'package:workers/features/comments/screens/comments_page.dart';
import 'package:workers/features/posts/models/project_with_user.dart';

class BodyAccountPage extends StatelessWidget {
  final dynamic user;
  final AuthController authController;
  final BuildContext context;

  const BodyAccountPage({
    super.key,
    required this.user,
    required this.authController,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final role = (user.role ?? '').toString().toLowerCase();
    final isWorker = role == 'worker' || user.workerProfile != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isWorker) {
      return _buildWorkerPostsGrid(context, isDark);
    } else {
      return _buildClientPlaceholder(isDark);
    }
  }

  Widget _buildWorkerPostsGrid(BuildContext context, bool isDark) {
    return Obx(() {
      // Listen to updates
      authController.postUpdateTrigger.value;

      // Get updated projects
      final updatedUser = authController.currentUser.value;
      final projects = updatedUser?.workerProfile?.projects ?? [];

      if (projects.isEmpty) {
        return _buildEmptyPostsState(isDark);
      }

      return GridView.builder(
        padding: EdgeInsets.all(1),
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          childAspectRatio: 1,
        ),
        itemCount: projects.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final project = projects[index];
          final allPostsWithUser = projects
              .map((p) => ProjectWithUser(project: p, user: updatedUser!))
              .toList();

          return GestureDetector(
            onTap: () => _openPostDetail(context, project, updatedUser!, allPostsWithUser, index),
            child: _buildGridItem(project, isDark),
          );
        },
      );
    });
  }

  Widget _buildGridItem(Project project, bool isDark) {
    final hasImages = project.images.isNotEmpty;
    final postService = Get.find<PostService>();

    return Container(
      decoration: BoxDecoration(color: isDark ? Colors.grey[800] : Colors.grey[200]),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          if (hasImages)
            Image.file(
              File(project.images.first),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder();
              },
            )
          else
            _buildPlaceholder(),

          // Multiple images indicator
          if (project.images.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.collections, color: Colors.white, size: 14),
                    SizedBox(width: 3),
                    Text(
                      '${project.images.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Stats Overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Likes
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Obx(() {
                        postService.updateTrigger.value;
                        final likeCount = postService.getLikeCount(project.id);
                        final value =
                            likeCount != 0 || postService.likeCounts.containsKey(project.id)
                            ? likeCount
                            : project.likes;
                        return Text(
                          _formatNumber(value),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        );
                      }),
                    ],
                  ),
                  // Price
                  if (project.price != null && project.price! > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 5, 95, 66),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_formatPrice(project.price!)} ر.س',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[500])),
    );
  }

  Widget _buildEmptyPostsState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera icon with circle border (Instagram style)
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2),
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 16),
          // Title
          Text(
            'لا توجد منشورات بعد',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientPlaceholder(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera icon with circle border (Instagram style)
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2),
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 16),
          // Title
          Text(
            'لا توجد منشورات بعد',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _openPostDetail(
    BuildContext context,
    Project project,
    dynamic user,
    List<ProjectWithUser> allPosts,
    int initialIndex,
  ) {
    Get.to(
      () => InstagramPostDetailPage(
        project: project,
        user: user,
        allPosts: allPosts,
        initialIndex: initialIndex,
        onLikeChanged: () => authController.notifyPostAdded(),
      ),
      transition: Transition.fadeIn,
      duration: Duration(milliseconds: 250),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(1)}k';
    }
    return price.toStringAsFixed(0);
  }
}

// Instagram-style Post Detail Page
class InstagramPostDetailPage extends StatefulWidget {
  final Project project;
  final dynamic user;
  final List<ProjectWithUser> allPosts;
  final int initialIndex;
  final VoidCallback? onLikeChanged;

  const InstagramPostDetailPage({
    super.key,
    required this.project,
    required this.user,
    required this.allPosts,
    required this.initialIndex,
    this.onLikeChanged,
  });

  @override
  State<InstagramPostDetailPage> createState() => _InstagramPostDetailPageState();
}

class _InstagramPostDetailPageState extends State<InstagramPostDetailPage> {
  PageController? _verticalPageController;
  int _currentPostIndex = 0;
  Map<int, int> _imageIndices = {};
  Map<int, PageController> _imageControllers = {};

  @override
  void initState() {
    super.initState();
    _currentPostIndex = widget.initialIndex;
    _verticalPageController = PageController(initialPage: widget.initialIndex);

    // Initialize image controllers for each post
    for (int i = 0; i < widget.allPosts.length; i++) {
      _imageIndices[i] = 0;
      _imageControllers[i] = PageController();
    }
  }

  @override
  void dispose() {
    _verticalPageController?.dispose();
    for (var controller in _imageControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_verticalPageController == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main PageView for posts
          PageView.builder(
            controller: _verticalPageController!,
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: widget.allPosts.length,
            onPageChanged: (index) {
              setState(() {
                _currentPostIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final postWithUser = widget.allPosts[index];
              return _buildPostView(postWithUser.project, postWithUser.user, index);
            },
          ),

          // Fixed top bar
          _buildTopBar(),

          // Scroll indicator
          if (widget.allPosts.length > 1)
            Positioned(
              right: 8,
              top: MediaQuery.of(context).size.height * 0.4,
              child: _buildScrollIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    if (widget.allPosts.isEmpty || _currentPostIndex >= widget.allPosts.length) {
      return SizedBox.shrink();
    }

    final currentPost = widget.allPosts[_currentPostIndex];
    final user = currentPost.user;

    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
              onPressed: () => Get.back(),
            ),

            // User info
            GestureDetector(
              onTap: () {
                // Navigate to user profile
              },
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ClipOval(
                      child: user.imagePath.isNotEmpty
                          ? Image.file(
                              File(user.imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Icon(Icons.person, color: Colors.white, size: 20),
                            )
                          : Container(
                              color: Colors.grey[700],
                              child: Icon(Icons.person, color: Colors.white, size: 20),
                            ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        user.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (currentPost.project.price != null && currentPost.project.price! > 0)
                        Text(
                          '${currentPost.project.price!.toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            color: Color(0xFF4CAF50),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            Spacer(),

            // More options
            IconButton(
              icon: Icon(Icons.more_horiz, color: Colors.white, size: 28),
              onPressed: () => _showOptions(context, currentPost.project),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.allPosts.length > 5 ? 5 : widget.allPosts.length, (index) {
          final actualIndex = widget.allPosts.length > 5
              ? (_currentPostIndex - 2 + index).clamp(0, widget.allPosts.length - 1)
              : index;
          final isActive = actualIndex == _currentPostIndex;

          return AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(vertical: 2),
            width: isActive ? 4 : 3,
            height: isActive ? 20 : 12,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPostView(Project project, dynamic user, int postIndex) {
    final authController = Get.find<AuthController>();
    final postService = Get.find<PostService>();

    return Obx(() {
      // Listen to PostService updates
      postService.updateTrigger.value;
      authController.postUpdateTrigger.value;

      // جلب البيانات المحدثة من الـ controller
      final updatedUser = authController.currentUser.value;
      final updatedProjects = updatedUser?.workerProfile?.projects ?? [];

      // جلب المشروع المحدث
      Project currentProject = project;
      if (postIndex < updatedProjects.length) {
        currentProject = updatedProjects[postIndex];
      }

      // استخدام PostService للحصول على حالة اللايك
      final isLiked = postService.isLiked(currentProject.id);
      final likeCount = postService.getLikeCount(currentProject.id);

      final imageController = _imageControllers[postIndex] ?? PageController();
      final currentImageIndex = _imageIndices[postIndex] ?? 0;

      return Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Images
            GestureDetector(
              onDoubleTap: () => _toggleLike(currentProject, postIndex),
              child: currentProject.images.isNotEmpty
                  ? PageView.builder(
                      controller: imageController,
                      itemCount: currentProject.images.length,
                      physics: BouncingScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() {
                          _imageIndices[postIndex] = index;
                        });
                      },
                      itemBuilder: (context, imgIndex) {
                        return Center(
                          child: Image.file(
                            File(currentProject.images[imgIndex]),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: Icon(Icons.image_not_supported, size: 80, color: Colors.grey)),
            ),

            // Image indicators (dots)
            if (currentProject.images.length > 1)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    currentProject.images.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      width: currentImageIndex == index ? 8 : 6,
                      height: currentImageIndex == index ? 8 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),

            // Image counter badge
            if (currentProject.images.length > 1)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.12,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentImageIndex + 1}/${currentProject.images.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.95),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Bottom content
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 70, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        currentProject.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Description
                      Text(
                        currentProject.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 12),

                      // Price tag
                      if (currentProject.price != null && currentProject.price! > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 5, 95, 66),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${currentProject.price!.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      SizedBox(height: 12),

                      // Likes count
                      Text(
                        '$likeCount إعجاب',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons (right side)
            Positioned(
              right: 12,
              bottom: MediaQuery.of(context).size.height * 0.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Like button
                  _buildActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '$likeCount',
                    onTap: () => _toggleLike(currentProject, postIndex),
                    color: isLiked ? Colors.red : Colors.white,
                    isLiked: isLiked,
                  ),
                  SizedBox(height: 20),

                  // Comment button
                  _buildActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${postService.commentCounts[currentProject.id] ?? 0}',
                    onTap: () {
                      _openComments(currentProject, user);
                    },
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),

                  // Share button
                  _buildActionButton(
                    icon: Icons.send,
                    label: '',
                    onTap: () {
                      Get.snackbar('مشاركة', 'تم نسخ الرابط', snackPosition: SnackPosition.BOTTOM);
                    },
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),

                  // Save button
                  _buildActionButton(
                    icon: Icons.bookmark_border,
                    label: '',
                    onTap: () {
                      Get.snackbar('حفظ', 'تم الحفظ', snackPosition: SnackPosition.BOTTOM);
                    },
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Swipe hint (only show on first post)
            if (postIndex == widget.initialIndex && widget.allPosts.length > 1)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _currentPostIndex == widget.initialIndex ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 500),
                    child: Column(
                      children: [
                        Icon(Icons.keyboard_arrow_up, color: Colors.white54, size: 30),
                        Text(
                          'اسحب للأعلى للمزيد',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
    bool isLiked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.3),
              border: Border.all(
                color: isLiked ? Colors.red.withOpacity(0.5) : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  void _openComments(Project project, dynamic user) {
    final postService = Get.find<PostService>();
    final future = Get.to(
      () => CommentsPage(project: project, user: user),
      transition: Transition.downToUp,
      duration: Duration(milliseconds: 300),
    );

    future?.then((_) => postService.refreshCommentCount(project.id));
  }

  void _toggleLike(Project project, int postIndex) async {
    final postService = Get.find<PostService>();
    await postService.toggleLike(project.workerId, project.id);
    widget.onLikeChanged?.call();
  }

  void _showOptions(BuildContext context, Project project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Color(0xFF262626) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              _buildOptionTile(Icons.share_outlined, 'مشاركة', () {
                Get.back();
                Get.snackbar('مشاركة', 'تم نسخ الرابط', snackPosition: SnackPosition.BOTTOM);
              }, isDark),
              _buildOptionTile(Icons.link, 'نسخ الرابط', () {
                Get.back();
                Get.snackbar('تم', 'تم نسخ الرابط', snackPosition: SnackPosition.BOTTOM);
              }, isDark),
              _buildOptionTile(Icons.bookmark_border, 'حفظ', () {
                Get.back();
                Get.snackbar('تم', 'تم الحفظ', snackPosition: SnackPosition.BOTTOM);
              }, isDark),
              Divider(color: Colors.grey[300]),
              _buildOptionTile(
                Icons.report_outlined,
                'إبلاغ',
                () {
                  Get.back();
                  Get.snackbar('شكراً', 'تم إرسال البلاغ', snackPosition: SnackPosition.BOTTOM);
                },
                isDark,
                isDestructive: true,
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionTile(
    IconData icon,
    String title,
    VoidCallback onTap,
    bool isDark, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87),
          fontSize: 16,
        ),
      ),
      onTap: onTap,
    );
  }
}

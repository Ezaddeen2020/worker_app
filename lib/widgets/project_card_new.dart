import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../features/posts/models/project_model.dart';
import '../features/profile/models/user_model.dart';
import '../features/posts/models/project_with_user.dart';
import '../features/auth/controller/auth_controller.dart';
import 'post_detail_view.dart';

class ProjectCard extends StatefulWidget {
  final Project project;
  final User user;
  final bool showUserHeader;
  final List<ProjectWithUser> allPosts;

  const ProjectCard({
    super.key,
    required this.project,
    required this.user,
    this.showUserHeader = true,
    required this.allPosts,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;

    _isLiked = widget.project.likedBy.contains(currentUserId);
    _likeCount = widget.project.likes;
  }

  void _toggleLike() async {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;

    if (currentUserId == null) return;

    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });

    // هنا يمكنك إضافة استدعاء الـ API لحفظ التغيير
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImages = widget.project.images.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User header
          if (widget.showUserHeader)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: widget.user.imagePath.isNotEmpty
                        ? CachedNetworkImageProvider(widget.user.imagePath)
                        : null,
                    backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                    child: widget.user.imagePath.isEmpty
                        ? Icon(Icons.person, color: isDark ? Colors.grey[400] : Colors.grey[600])
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (widget.user.role == 'worker')
                          Text(
                            'worker'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    onPressed: () {
                      // إضافة المزيد من الخيارات
                    },
                  ),
                ],
              ),
            ),

          // Project title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.project.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),

          // Project description
          if (widget.project.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.project.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Project images
          if (hasImages)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PageView.builder(
                  itemCount: widget.project.images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Find the index of this project in allPosts
                        final projectIndex = widget.allPosts.indexWhere(
                          (post) => post.project.id == widget.project.id,
                        );

                        Get.to(
                          () => PostDetailView(
                            project: widget.project,
                            user: widget.user,
                            allPosts: widget.allPosts,
                            initialIndex: projectIndex >= 0 ? projectIndex : 0,
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: widget.project.images[index],
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: isDark ? Colors.blue[400] : Colors.blue[600],
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: Icon(
                            Icons.broken_image,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Price if available
          if (widget.project.price != null && widget.project.price! > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.green[900] : Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isDark ? Colors.green[700]! : Colors.green[200]!),
                ),
                child: Text(
                  '${widget.project.price} ${'sar'.tr}',
                  style: TextStyle(
                    color: isDark ? Colors.green[300] : Colors.green[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          // Actions (like, comment, etc.)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked
                            ? Colors.red
                            : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$_likeCount',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Comment button
                GestureDetector(
                  onTap: () {
                    // Navigate to comments
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Share button
                GestureDetector(
                  onTap: () {
                    // Share functionality
                  },
                  child: Icon(
                    Icons.share_outlined,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    size: 24,
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

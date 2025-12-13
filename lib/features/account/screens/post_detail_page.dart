import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:workers/features/posts/models/project_model.dart';
import 'package:workers/features/posts/models/project_with_user.dart';
import 'package:workers/features/account/controllers/post_detail_controller.dart';

/// Instagram-style post detail page with vertical scrolling
class PostDetailPage extends StatelessWidget {
  final Project project;
  final dynamic user;
  final List<ProjectWithUser> allPosts;
  final int initialIndex;
  final VoidCallback? onLikeChanged;

  const PostDetailPage({
    super.key,
    required this.project,
    required this.user,
    required this.allPosts,
    required this.initialIndex,
    this.onLikeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Initialize controller with parameters
    final controller = Get.put(
      PostDetailController(
        project: project,
        user: user,
        allPosts: allPosts,
        initialIndex: initialIndex,
        onLikeChanged: onLikeChanged,
      ),
      tag: 'post_detail_${project.id}',
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.verticalPageController,
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            itemCount: allPosts.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final postWithUser = allPosts[index];
              return _PostView(
                controller: controller,
                postWithUser: postWithUser,
                postIndex: index,
              );
            },
          ),
          _TopBar(controller: controller),
          if (allPosts.length > 1)
            Obx(() => Positioned(
                  right: 8,
                  top: MediaQuery.of(context).size.height * 0.4,
                  child: _ScrollIndicator(
                    totalPosts: allPosts.length,
                    currentIndex: controller.currentPostIndex.value,
                  ),
                )),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final PostDetailController controller;

  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.allPosts.isEmpty ||
          controller.currentPostIndex.value >= controller.allPosts.length) {
        return SizedBox.shrink();
      }

      final currentPost = controller.currentPost;
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
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                onPressed: controller.goBack,
              ),
              GestureDetector(
                onTap: () {},
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
                        if (currentPost.project.price != null &&
                            currentPost.project.price! > 0)
                          Text(
                            '${currentPost.project.price!.toStringAsFixed(0)} ${'sar'.tr}',
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
              IconButton(
                icon: Icon(Icons.more_horiz, color: Colors.white, size: 28),
                onPressed: () => _showOptions(context, currentPost.project),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showOptions(BuildContext context, Project project) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Color(0xFF262626) : Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildOptionTile(Icons.share_outlined, 'sharePost'.tr, () {
                Get.back();
                controller.sharePost();
              }, isDark),
              _buildOptionTile(Icons.link, 'copyLink'.tr, () {
                Get.back();
                controller.copyLink();
              }, isDark),
              _buildOptionTile(Icons.bookmark_border, 'save'.tr, () {
                Get.back();
                controller.savePost();
              }, isDark),
              Divider(color: Colors.grey[300]),
              _buildOptionTile(
                Icons.report_outlined,
                'report'.tr,
                () {
                  Get.back();
                  controller.reportPost();
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

class _ScrollIndicator extends StatelessWidget {
  final int totalPosts;
  final int currentIndex;

  const _ScrollIndicator({
    required this.totalPosts,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalPosts > 5 ? 5 : totalPosts, (index) {
          final actualIndex = totalPosts > 5
              ? (currentIndex - 2 + index).clamp(0, totalPosts - 1)
              : index;
          final isActive = actualIndex == currentIndex;

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
}

class _PostView extends StatelessWidget {
  final PostDetailController controller;
  final ProjectWithUser postWithUser;
  final int postIndex;

  const _PostView({
    required this.controller,
    required this.postWithUser,
    required this.postIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      controller.postService.updateTrigger.value;
      controller.authController.postUpdateTrigger.value;

      final currentProject = controller.getUpdatedProject(postIndex);
      final isLiked = controller.isLiked(currentProject.id);
      final likeCount = controller.getLikeCount(currentProject.id);
      final currentImageIndex = controller.getImageIndex(postIndex);
      final imageController = controller.getImageController(postIndex);

      return Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Images
            GestureDetector(
              onDoubleTap: () => controller.toggleLike(currentProject),
              child: currentProject.images.isNotEmpty
                  ? PageView.builder(
                      controller: imageController,
                      itemCount: currentProject.images.length,
                      physics: BouncingScrollPhysics(),
                      onPageChanged: (index) =>
                          controller.onImagePageChanged(postIndex, index),
                      itemBuilder: (context, imgIndex) {
                        return Center(
                          child: Image.file(
                            File(currentProject.images[imgIndex]),
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[900],
                              child: Icon(Icons.broken_image,
                                  size: 80, color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(Icons.image_not_supported,
                          size: 80, color: Colors.grey)),
            ),

            // Image indicators
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
                      Text(
                        currentProject.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
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
                      if (currentProject.price != null &&
                          currentProject.price! > 0)
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 5, 95, 66),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${currentProject.price!.toStringAsFixed(0)} ${'sar'.tr}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      SizedBox(height: 12),
                      Text(
                        '$likeCount ${'likes'.tr}',
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

            // Action buttons
            Positioned(
              right: 12,
              bottom: MediaQuery.of(context).size.height * 0.15,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ActionButton(
                    icon: isLiked ? Icons.favorite : Icons.favorite_border,
                    label: '$likeCount',
                    onTap: () => controller.toggleLike(currentProject),
                    color: isLiked ? Colors.red : Colors.white,
                    isLiked: isLiked,
                  ),
                  SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: '${controller.getCommentCount(currentProject.id)}',
                    onTap: () =>
                        controller.openComments(currentProject, postWithUser.user),
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.send,
                    label: '',
                    onTap: controller.sharePost,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  _ActionButton(
                    icon: Icons.bookmark_border,
                    label: '',
                    onTap: controller.savePost,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Swipe hint
            if (postIndex == controller.initialIndex &&
                controller.allPosts.length > 1)
              Positioned(
                bottom: MediaQuery.of(context).size.height * 0.45,
                left: 0,
                right: 0,
                child: Center(
                  child: Obx(() => AnimatedOpacity(
                        opacity: controller.currentPostIndex.value ==
                                controller.initialIndex
                            ? 1.0
                            : 0.0,
                        duration: Duration(milliseconds: 500),
                        child: Column(
                          children: [
                            Icon(Icons.keyboard_arrow_up,
                                color: Colors.white54, size: 30),
                            Text(
                              'swipeUpForMore'.tr,
                              style:
                                  TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      )),
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isLiked;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isLiked = false,
  });

  @override
  Widget build(BuildContext context) {
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
                color: isLiked
                    ? Colors.red.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          if (label.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

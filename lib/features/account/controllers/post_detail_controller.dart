import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/posts/models/project_model.dart';
import 'package:workers/features/posts/services/post_service.dart';
import 'package:workers/features/posts/models/project_with_user.dart';
import 'package:workers/features/comments/screens/comments_page.dart';

class PostDetailController extends GetxController {
  final Project project;
  final dynamic user;
  final List<ProjectWithUser> allPosts;
  final int initialIndex;
  final VoidCallback? onLikeChanged;

  PostDetailController({
    required this.project,
    required this.user,
    required this.allPosts,
    required this.initialIndex,
    this.onLikeChanged,
  });

  // Controllers
  late PageController verticalPageController;
  final Map<int, PageController> imageControllers = {};

  // Observable states
  final RxInt currentPostIndex = 0.obs;
  final RxMap<int, int> imageIndices = <int, int>{}.obs;

  // Dependencies
  late AuthController authController;
  late PostService postService;

  @override
  void onInit() {
    super.onInit();
    authController = Get.find<AuthController>();
    postService = Get.find<PostService>();

    currentPostIndex.value = initialIndex;
    verticalPageController = PageController(initialPage: initialIndex);

    // إزالة الحلقة واستبدالها بتهيئة Lazy
    imageIndices[initialIndex] = 0;
    imageControllers[initialIndex] = PageController();
  }

  @override
  void onClose() {
    verticalPageController.dispose();
    for (var controller in imageControllers.values) {
      controller.dispose();
    }
    super.onClose();
  }

  // Getters
  ProjectWithUser get currentPost => allPosts[currentPostIndex.value];

  int getImageIndex(int postIndex) => imageIndices[postIndex] ?? 0;

  PageController getImageController(int postIndex) {
    if (!imageControllers.containsKey(postIndex)) {
      imageControllers[postIndex] = PageController();
    }
    return imageControllers[postIndex]!;
  }

  bool isLiked(String projectId) => postService.isLiked(projectId);

  int getLikeCount(String projectId) => postService.getLikeCount(projectId);

  int getCommentCount(String projectId) => postService.commentCounts[projectId] ?? 0;

  Project getUpdatedProject(int postIndex) {
    final updatedUser = authController.currentUser.value;
    final updatedProjects = updatedUser?.workerProfile?.projects ?? [];

    if (postIndex < updatedProjects.length) {
      return updatedProjects[postIndex];
    }
    return allPosts[postIndex].project;
  }

  // Methods
  void onPageChanged(int index) {
    currentPostIndex.value = index;
  }

  void onImagePageChanged(int postIndex, int imageIndex) {
    imageIndices[postIndex] = imageIndex;
  }

  Future<void> toggleLike(Project project) async {
    await postService.toggleLike(project.workerId, project.id);
    onLikeChanged?.call();
  }

  void openComments(Project project, dynamic user) {
    Get.to(
      () => CommentsPage(project: project, user: user),
      transition: Transition.downToUp,
      duration: Duration(milliseconds: 300),
    )?.then((_) => postService.refreshCommentCount(project.id));
  }

  void sharePost() {
    Get.snackbar('sharePost'.tr, 'linkCopied'.tr, snackPosition: SnackPosition.BOTTOM);
  }

  void savePost() {
    Get.snackbar('save'.tr, 'savedSuccessfully'.tr, snackPosition: SnackPosition.BOTTOM);
  }

  void reportPost() {
    Get.snackbar('thanks'.tr, 'reportSent'.tr, snackPosition: SnackPosition.BOTTOM);
  }

  void copyLink() {
    Get.snackbar('done'.tr, 'linkCopied'.tr, snackPosition: SnackPosition.BOTTOM);
  }

  void goBack() {
    Get.back();
  }
}

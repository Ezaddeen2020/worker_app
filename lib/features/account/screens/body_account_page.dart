import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/posts/models/project_model.dart';
import 'package:workers/features/posts/models/project_with_user.dart';
import 'package:workers/features/account/widgets/post_grid_item.dart';
import 'package:workers/features/account/screens/post_detail_page.dart';

/// Body section of account page showing posts grid
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
      return _buildEmptyState(isDark);
    }
  }

  Widget _buildWorkerPostsGrid(BuildContext context, bool isDark) {
    return Obx(() {
      authController.postUpdateTrigger.value;

      final updatedUser = authController.currentUser.value;
      final projects = updatedUser?.workerProfile?.projects ?? [];

      if (projects.isEmpty) {
        return _buildEmptyState(isDark);
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

          return PostGridItem(
            project: project,
            onTap: () => _openPostDetail(
              context,
              project,
              updatedUser!,
              allPostsWithUser,
              index,
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? Colors.white : Colors.black,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 32,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'noPostsYet'.tr,
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
      () => PostDetailPage(
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
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/post_service.dart';
import '../../../widgets/project_card_new.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PostService postService = Get.find<PostService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Color.fromRGBO(231, 230, 226, 0.2),
      body: Container(
        child: Column(
          children: [
            AppBar(
              title: Text(
                'posts'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: isDark ? Colors.white : Colors.black87,
            ),
            Expanded(
              child: Obx(() {
                final isLoading = postService.isLoading.value;
                final posts = postService.feedPosts;

                if (isLoading && posts.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: isDark ? Colors.blue[400] : Colors.blue[600],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: isDark ? Colors.blue[400] : Colors.blue[600],
                  backgroundColor: isDark ? Color(0xFF1E1E1E) : Color.fromRGBO(231, 230, 226, 0.2),
                  onRefresh: () async {
                    await postService.loadAllPosts();
                    await Future.delayed(const Duration(milliseconds: 200));
                  },
                  child: posts.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
                          children: [
                            Center(
                              child: Text(
                                'noPostsFound'.tr,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: posts.length,
                          cacheExtent: 500, // تخزين مؤقت للعناصر خارج الشاشة
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          itemBuilder: (context, index) {
                            final projectWithUser = posts[index];
                            return ProjectCard(
                              project: projectWithUser.project,
                              user: projectWithUser.user,
                              showUserHeader: true,
                              allPosts: posts,
                            );
                          },
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/post_service.dart';
import '../../../widgets/project_card.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PostService postService = Get.find<PostService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF434B53), Color(0xFF353E47)],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: Text(
                'posts'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
            ),
            Expanded(
              child: Obx(() {
                final isLoading = postService.isLoading.value;
                final posts = postService.feedPosts;

                if (isLoading && posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
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
                                style: TextStyle(color: isDark ? Colors.white : Colors.black),
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

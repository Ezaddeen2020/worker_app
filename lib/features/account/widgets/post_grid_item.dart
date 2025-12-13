import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:workers/features/posts/models/project_model.dart';
import 'package:workers/features/posts/services/post_service.dart';

/// Widget for displaying a single post in the grid
class PostGridItem extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const PostGridItem({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImages = project.images.isNotEmpty;
    final postService = Get.find<PostService>();

    return GestureDetector(
      onTap: onTap,
      child: Container(
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

            // Stats overlay
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
                          '${_formatPrice(project.price!)} ${'sar'.tr}',
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
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey[500])),
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

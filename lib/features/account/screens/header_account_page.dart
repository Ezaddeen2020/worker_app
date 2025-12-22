// account/header_account_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:workers/features/auth/controller/auth_controller.dart';

class HeaderAccountPage extends StatelessWidget {
  final dynamic user;
  final AuthController authController;
  final BuildContext context;
  final VoidCallback onEditProfilePressed;
  final VoidCallback onMenuPressed;

  const HeaderAccountPage({
    super.key,
    required this.user,
    required this.authController,
    required this.context,
    required this.onEditProfilePressed,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final projects = user.workerProfile?.projects ?? [];
    final postsCount = projects.length;
    final rating = user.workerProfile?.rating ?? 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF114577), Color(0xFF91ADC6), Color(0xFFF2F8F3).withOpacity(0.09)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Profile Stats Section - Instagram Style
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Profile Picture with Gradient Border (Story Style)
                GestureDetector(
                  onTap: () => _showProfilePictureFullscreen(context),
                  child: _buildProfilePicture(isDark),
                ),
                SizedBox(width: 28),
                // Stats
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('$postsCount', 'posts'.tr, isDark),
                      _buildStatColumn('0', 'followersCount'.tr, isDark),
                      _buildStatColumn('0', 'followingCount'.tr, isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Name and Bio Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF114577),
                  ),
                ),
                SizedBox(height: 4),
                // Role/Category with Rating
                Row(
                  children: [
                    if (user.role == 'worker')
                      Text(
                        'professionalWorker'.tr,
                        style: TextStyle(fontSize: 14, color: Color(0xFF91ADC6)),
                      )
                    else
                      Text(
                        'clientUser'.tr,
                        style: TextStyle(fontSize: 14, color: Color(0xFF91ADC6)),
                      ),
                    if (rating > 0) ...[
                      SizedBox(width: 8),
                      Icon(Icons.star, size: 14, color: Color(0xFFFFC107)),
                      Text(
                        ' $rating',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF114577),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 6),
                // Member Since
                Text(
                  '${'memberSince'.tr} ${_formatDateShort(user.createdAt)}',
                  style: TextStyle(fontSize: 13, color: Color(0xFF91ADC6)),
                ),
                // Phone Number
                if (user.phone != null && user.phone.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 13, color: Color(0xFF91ADC6)),
                      SizedBox(width: 4),
                      Text(user.phone, style: TextStyle(fontSize: 13, color: Color(0xFF91ADC6))),
                    ],
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 16),

          // Action Buttons - Instagram Style
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Edit Profile Button
                Expanded(
                  flex: 2,
                  child: _buildActionButton(
                    label: 'editProfileBtn'.tr,
                    onPressed: onEditProfilePressed,
                    isPrimary: false,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 8),
                // Share Profile Button
                Expanded(
                  child: _buildActionButton(
                    label: 'shareProfile'.tr,
                    onPressed: () => _shareProfile(),
                    isPrimary: false,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: 8),
                // Suggest User Button
                _buildIconButton(
                  icon: Icons.person_add_outlined,
                  onPressed: () {
                    Get.snackbar(
                      'comingSoon'.tr,
                      'suggestFriend'.tr,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: Duration(seconds: 2),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Story Highlights Section
          _buildStoryHighlights(isDark),

          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildProfilePicture(bool isDark) {
    final hasImage = user.imagePath != null && user.imagePath.isNotEmpty;

    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF114577), Color(0xFF91ADC6), Color(0xFFF2F8F3).withOpacity(0.09)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        padding: EdgeInsets.all(3),
        child: ClipOval(
          child: hasImage
              ? Image.file(
                  File(user.imagePath),
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholderAvatar(84, isDark);
                  },
                )
              : _buildPlaceholderAvatar(84, isDark),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(double size, bool isDark) {
    return Container(
      width: size,
      height: size,
      color: isDark ? Colors.grey[800] : Colors.grey[300],
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    );
  }

  Widget _buildStatColumn(String count, String label, bool isDark) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Color.fromARGB(255, 220, 225, 231),
          ),
        ),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 13, color: Color.fromARGB(255, 202, 216, 229))),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required bool isDark,
  }) {
    return SizedBox(
      height: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isPrimary
              ? Color.fromARGB(255, 5, 13, 21)
              : Color(0xFFF2F8F3).withOpacity(0.7),
          foregroundColor: isPrimary ? Colors.white : Color(0xFF114577),
          side: BorderSide(color: isPrimary ? Color(0xFF114577) : Color(0xFF91ADC6), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return SizedBox(
      height: 36,
      width: 36,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Color(0xFFF2F8F3).withOpacity(0.7),
          side: BorderSide(color: Color(0xFF91ADC6), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Icon(icon, size: 20, color: Color(0xFF114577)),
      ),
    );
  }

  Widget _buildStoryHighlights(bool isDark) {
    return Container(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildNewHighlight(isDark),
          _buildHighlightItem('myWorks'.tr, null, isDark),
          _buildHighlightItem('designs'.tr, null, isDark),
          _buildHighlightItem('projectsHighlight'.tr, null, isDark),
          _buildHighlightItem('certificates'.tr, null, isDark),
        ],
      ),
    );
  }

  Widget _buildNewHighlight(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Get.snackbar(
                'comingSoon'.tr,
                'storiesFeature'.tr,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF91ADC6), width: 1.5),
              ),
              child: Icon(Icons.add, color: Color(0xFF114577), size: 32),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'new'.tr,
            style: TextStyle(fontSize: 12, color: Color(0xFF91ADC6)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String title, String? imagePath, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Get.snackbar('comingSoon'.tr, title, snackPosition: SnackPosition.BOTTOM);
            },
            child: Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF2F8F3),
                border: Border.all(color: Color(0xFF91ADC6), width: 1.5),
              ),
              child: imagePath != null && imagePath.isNotEmpty
                  ? ClipOval(
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, color: Color(0xFF91ADC6), size: 30);
                        },
                      ),
                    )
                  : Icon(Icons.image, color: Color(0xFF91ADC6), size: 30),
            ),
          ),
          SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Color(0xFF91ADC6)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showProfilePictureFullscreen(BuildContext context) {
    if (user.imagePath == null || user.imagePath.isEmpty) {
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(File(user.imagePath), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareProfile() {
    Get.snackbar(
      'shareProfileTitle'.tr,
      '${'shareProfileMessage'.tr} ${user.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }

  String _formatDateShort(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year'.tr : 'years'.tr}';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month'.tr : 'months'.tr}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day'.tr : 'days'.tr}';
    } else {
      return 'today'.tr;
    }
  }
}

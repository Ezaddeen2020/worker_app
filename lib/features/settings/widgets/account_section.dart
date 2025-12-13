import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/widgets/edit_profile_dialog.dart';

class SettingsAccountSection extends StatelessWidget {
  final AuthController authController;
  final bool isDark;
  const SettingsAccountSection({required this.authController, required this.isDark, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('account'.tr, isDark),
        Obx(() {
          final user = authController.currentUser.value;
          return _buildSettingsTile(
            icon: Icons.person_outline,
            iconBgColor: isDark ? Colors.teal[900]! : Colors.teal[50]!,
            iconColor: Colors.teal,
            title: 'editProfile'.tr,
            isDark: isDark,
            onTap: () {
              if (user != null) {
                _showEditProfileDialog(context, authController, user);
              }
            },
          );
        }),
        _buildSettingsTile(
          icon: Icons.security,
          iconBgColor: isDark ? Colors.blue[900]! : Colors.blue[50]!,
          iconColor: Colors.blue,
          title: 'security'.tr,
          isDark: isDark,
          onTap: () => Get.snackbar('comingSoon'.tr, 'featureUnderDevelopment'.tr),
        ),
        _buildSettingsTile(
          icon: Icons.supervised_user_circle_outlined,
          iconBgColor: isDark ? Colors.cyan[900]! : Colors.cyan[50]!,
          iconColor: Colors.cyan,
          title: 'supervision'.tr,
          isDark: isDark,
          onTap: () => Get.snackbar('comingSoon'.tr, 'featureUnderDevelopment'.tr),
        ),
        // ... باقي عناصر الحساب ...
        _buildSectionHeader('helpAndSupport'.tr, isDark),
        _buildSettingsTile(
          icon: Icons.help_outline,
          iconBgColor: isDark ? Colors.blue[900]! : Colors.blue[50]!,
          iconColor: Colors.blue,
          title: 'helpCenter'.tr,
          isDark: isDark,
          onTap: () => Get.snackbar('comingSoon'.tr, 'featureUnderDevelopment'.tr),
        ),
        _buildSettingsTile(
          icon: Icons.info_outline,
          iconBgColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
          iconColor: isDark ? Colors.grey[400]! : Colors.grey[700]!,
          title: 'about'.tr,
          isDark: isDark,
          onTap: () => _showAboutDialog(context, isDark),
        ),
        // ... أزرار إضافة حساب وتسجيل الخروج ...
      ],
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey[400] : Colors.grey[600],
      ),
    ),
  );
  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) => ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: iconColor, size: 22),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black,
      ),
    ),
    subtitle: subtitle != null
        ? Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[500]))
        : null,
    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
  void _showEditProfileDialog(BuildContext context, AuthController authController, dynamic user) {
    Get.dialog(
      EditProfileDialog(user: user, authController: authController),
      barrierDismissible: false,
    );
  }

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF405DE6),
                    Color(0xFF5851DB),
                    Color(0xFF833AB4),
                    Color(0xFFC13584),
                    Color(0xFFE1306C),
                    Color(0xFFFD1D1D),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.work, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'appTitle'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('version'.tr + ' 1.0.0', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 12),
            Text(
              'appDescription'.tr,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 16),
            Text('copyright'.tr, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ok'.tr,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}

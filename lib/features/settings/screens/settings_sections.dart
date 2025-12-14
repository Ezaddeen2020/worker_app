import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/settings/controllers/theme_controller.dart';
import 'package:workers/features/settings/controllers/language_controller.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/widgets/home_config_modal.dart';
import 'package:workers/widgets/edit_profile_dialog.dart';

// القسم الأول: مركز الحسابات وشرح التطبيق
class SettingsMetaSection extends StatelessWidget {
  final bool isDark;
  const SettingsMetaSection({required this.isDark, super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('metaAccountsCenter'.tr, isDark),
        _buildMetaAccountsCenter(isDark),
        const SizedBox(height: 8),
        _buildSectionHeader('howToUseApp'.tr, isDark),
        // ... هنا يمكنك إضافة شرح أو روابط تعليمية ...
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
  Widget _buildMetaAccountsCenter(bool isDark) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Color(0xFF1E1E1E) : Color.fromRGBO(231, 230, 226, 0.2),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? Colors.grey[800]! : const Color.fromARGB(255, 56, 55, 55)!,
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.all_inclusive, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'metaAccountsCenter'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              Text(
                'accountCenterDescription'.tr,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
      ],
    ),
  );
}

// القسم الثاني: إعدادات التطبيق (اللغة، المظهر، التخصيص)
class SettingsAppSection extends StatelessWidget {
  final ThemeController themeController;
  final LanguageController languageController;
  final bool isDark;
  const SettingsAppSection({
    required this.themeController,
    required this.languageController,
    required this.isDark,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('appSettings'.tr, isDark),
        Obx(
          () => _buildSettingsTile(
            icon: Icons.language,
            iconBgColor: isDark ? Colors.indigo[900]! : Colors.indigo[50]!,
            iconColor: Colors.indigo,
            title: 'language'.tr,
            subtitle: languageController.currentLanguageName,
            isDark: isDark,
            onTap: () => _showLanguageDialog(context, languageController, isDark),
          ),
        ),
        _buildSettingsTile(
          icon: Icons.color_lens_outlined,
          iconBgColor: isDark ? Colors.pink[900]! : Colors.pink[50]!,
          iconColor: Colors.pink,
          title: 'customizeHomePage'.tr,
          isDark: isDark,
          onTap: () => _showHomeConfigModal(context),
        ),
        Obx(() => _buildDarkModeTile(themeController, isDark)),
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
  Widget _buildDarkModeTile(ThemeController themeController, bool isDark) => ListTile(
    leading: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? Colors.white : Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        color: isDark ? Colors.black : Colors.white,
        size: 22,
      ),
    ),
    title: Text(
      'darkMode'.tr,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : Colors.black,
      ),
    ),
    subtitle: Text(
      themeController.isDarkMode.value ? 'enabled'.tr : 'disabled'.tr,
      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
    ),
    trailing: Switch(
      value: themeController.isDarkMode.value,
      onChanged: (value) => themeController.setDarkMode(value),
      activeColor: Colors.blue,
      activeTrackColor: Colors.blue[200],
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
  void _showHomeConfigModal(BuildContext context) =>
      showDialog(context: context, builder: (context) => HomeConfigModal());
  void _showLanguageDialog(
    BuildContext context,
    LanguageController languageController,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'selectLanguage'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => _buildLanguageOption('arabic'.tr, 'ar', languageController, isDark)),
            const SizedBox(height: 8),
            Obx(() => _buildLanguageOption('english'.tr, 'en', languageController, isDark)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'close'.tr,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(
    String title,
    String languageCode,
    LanguageController controller,
    bool isDark,
  ) {
    final isSelected = controller.currentLanguage.value == languageCode;
    return InkWell(
      onTap: () {
        controller.changeLanguage(languageCode);
        Get.back();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Colors.indigo[900] : Colors.indigo[50])
              : (isDark ? Colors.grey[800] : Colors.grey[100]),
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.indigo, width: 2) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.indigo : (isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// القسم الثالث: الحساب والمساعدة
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

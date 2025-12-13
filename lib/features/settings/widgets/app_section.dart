import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/settings/controllers/theme_controller.dart';
import 'package:workers/features/settings/controllers/language_controller.dart';
import 'package:workers/widgets/home_config_modal.dart';

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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/settings/controllers/theme_controller.dart';
import 'package:workers/widgets/home_config_modal.dart';
import 'package:workers/widgets/edit_profile_dialog.dart';
import 'package:workers/features/auth/screens/register_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'الإعدادات والخصوصية',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF2C2C2C) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'بحث',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            // Meta Accounts Center Section
            _buildSectionHeader('مركز الحسابات', isDark),
            _buildMetaAccountsCenter(isDark),

            const SizedBox(height: 8),

            // How to use the app section
            _buildSectionHeader('كيفية استخدام التطبيق', isDark),
            _buildSettingsTile(
              icon: Icons.bookmark_border,
              iconBgColor: isDark ? Colors.purple[900]! : Colors.purple[50]!,
              iconColor: Colors.purple,
              title: 'المحفوظات',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'صفحة المحفوظات قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.archive_outlined,
              iconBgColor: isDark ? Colors.orange[900]! : Colors.orange[50]!,
              iconColor: Colors.orange,
              title: 'الأرشيف',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'صفحة الأرشيف قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.history,
              iconBgColor: isDark ? Colors.green[900]! : Colors.green[50]!,
              iconColor: Colors.green,
              title: 'نشاطك',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'صفحة النشاط قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.notifications_outlined,
              iconBgColor: isDark ? Colors.red[900]! : Colors.red[50]!,
              iconColor: Colors.red,
              title: 'الإشعارات',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'صفحة الإشعارات قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.access_time,
              iconBgColor: isDark ? Colors.blue[900]! : Colors.blue[50]!,
              iconColor: Colors.blue,
              title: 'الوقت المُستغرق',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'صفحة الوقت المستغرق قيد التطوير'),
            ),

            const SizedBox(height: 8),

            // Who can see your content section
            _buildSectionHeader('من يمكنه رؤية محتواك', isDark),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              iconBgColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
              iconColor: isDark ? Colors.white : Colors.black87,
              title: 'خصوصية الحساب',
              subtitle: 'خاص',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'إعدادات الخصوصية قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.star_border,
              iconBgColor: isDark ? Colors.amber[900]! : Colors.yellow[50]!,
              iconColor: Colors.amber,
              title: 'الأصدقاء المقربون',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'صفحة الأصدقاء المقربون قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.block,
              iconBgColor: isDark ? Colors.red[900]! : Colors.red[50]!,
              iconColor: Colors.red,
              title: 'الحظر',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'صفحة الحظر قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.visibility_off_outlined,
              iconBgColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
              iconColor: isDark ? Colors.grey[400]! : Colors.grey[700]!,
              title: 'إخفاء القصة والبث المباشر',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'إعدادات الإخفاء قيد التطوير'),
            ),

            const SizedBox(height: 8),

            // App Settings section
            _buildSectionHeader('إعدادات التطبيق', isDark),
            _buildSettingsTile(
              icon: Icons.language,
              iconBgColor: isDark ? Colors.indigo[900]! : Colors.indigo[50]!,
              iconColor: Colors.indigo,
              title: 'اللغة',
              subtitle: 'العربية',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'تغيير اللغة قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.color_lens_outlined,
              iconBgColor: isDark ? Colors.pink[900]! : Colors.pink[50]!,
              iconColor: Colors.pink,
              title: 'تخصيص الصفحة الرئيسية',
              isDark: isDark,
              onTap: () => _showHomeConfigModal(context),
            ),
            // Dark Mode Toggle
            Obx(() => _buildDarkModeTile(themeController, isDark)),

            const SizedBox(height: 8),

            // Account section
            _buildSectionHeader('الحساب', isDark),
            Obx(() {
              final user = authController.currentUser.value;
              return _buildSettingsTile(
                icon: Icons.person_outline,
                iconBgColor: isDark ? Colors.teal[900]! : Colors.teal[50]!,
                iconColor: Colors.teal,
                title: 'تعديل الملف الشخصي',
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
              title: 'الأمان',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'إعدادات الأمان قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.supervised_user_circle_outlined,
              iconBgColor: isDark ? Colors.cyan[900]! : Colors.cyan[50]!,
              iconColor: Colors.cyan,
              title: 'الإشراف',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'إعدادات الإشراف قيد التطوير'),
            ),

            const SizedBox(height: 8),

            // Help section
            _buildSectionHeader('المزيد من المعلومات والدعم', isDark),
            _buildSettingsTile(
              icon: Icons.help_outline,
              iconBgColor: isDark ? Colors.blue[900]! : Colors.blue[50]!,
              iconColor: Colors.blue,
              title: 'المساعدة',
              isDark: isDark,
              onTap: () => Get.snackbar('قريباً', 'صفحة المساعدة قيد التطوير'),
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              iconBgColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
              iconColor: isDark ? Colors.grey[400]! : Colors.grey[700]!,
              title: 'حول',
              isDark: isDark,
              onTap: () => _showAboutDialog(context, isDark),
            ),

            const SizedBox(height: 16),

            // Add Account & Logout buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Add Account Button
                  InkWell(
                    onTap: () => Get.snackbar('قريباً', 'إضافة حساب قيد التطوير'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'إضافة حساب',
                        style: TextStyle(
                          color: Colors.blue[400],
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Logout Button
                  InkWell(
                    onTap: () => _showLogoutDialog(context, authController, isDark),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
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
  }

  Widget _buildMetaAccountsCenter(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      'مركز الحسابات',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'كلمة المرور، الأمان، المعلومات الشخصية، تفضيلات الإعلانات',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[500]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
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
  }

  Widget _buildDarkModeTile(ThemeController themeController, bool isDark) {
    return ListTile(
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
        'الوضع الداكن',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      subtitle: Text(
        themeController.isDarkMode.value ? 'مفعّل' : 'مغلق',
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
  }

  void _showHomeConfigModal(BuildContext context) {
    showDialog(context: context, builder: (context) => HomeConfigModal());
  }

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
              'تطبيق العمال',
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
            Text('الإصدار 1.0.0', style: TextStyle(color: Colors.grey[500])),
            const SizedBox(height: 12),
            Text(
              'تطبيق للتواصل بين العمال والحرفيين والعملاء. يمكنك عرض أعمالك والتواصل مع العملاء بسهولة.',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2025 جميع الحقوق محفوظة',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController, bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'تسجيل الخروج',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟',
          style: TextStyle(fontSize: 15, color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await authController.logout();
              Get.offAll(() => const RegisterPage());
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

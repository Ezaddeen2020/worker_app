import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/posts/services/post_service.dart';
import 'package:workers/features/auth/screens/register_page.dart';
import 'package:workers/features/settings/screens/setting_page.dart';
import 'package:workers/widgets/add_project_dialog.dart';
import 'package:workers/widgets/edit_profile_dialog.dart';

class AccountController extends GetxController with GetSingleTickerProviderStateMixin {
  late final AuthController authController;
  late final PostService postService;
  late TabController tabController;

  // Observable states
  final RxInt currentTabIndex = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    authController = Get.find<AuthController>();
    postService = Get.isRegistered<PostService>()
        ? Get.find<PostService>()
        : Get.put<PostService>(PostService(), permanent: true);
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  // Getters
  bool get isLoggedIn => authController.isUserLoggedIn.value;
  dynamic get currentUser => authController.currentUser.value;

  bool get isWorker {
    final user = currentUser;
    if (user == null) return false;
    final role = (user.role ?? '').toString().toLowerCase();
    return role == 'worker' || user.workerProfile != null;
  }

  int get postsCount {
    final user = currentUser;
    return user?.workerProfile?.projects?.length ?? 0;
  }

  double get rating {
    final user = currentUser;
    return user?.workerProfile?.rating ?? 0;
  }

  List<dynamic> get projects {
    final user = currentUser;
    return user?.workerProfile?.projects ?? [];
  }

  bool get isDark => Get.isDarkMode;

  // Methods
  void changeTab(int index) {
    currentTabIndex.value = index;
    tabController.animateTo(index);
  }

  Future<void> refreshProfile() async {
    isLoading.value = true;
    try {
      authController.notifyPostAdded();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authController.logout();
    Get.offAll(() => const RegisterPage());
  }

  void notifyPostAdded() {
    authController.notifyPostAdded();
  }

  void showAddProjectDialog(BuildContext context) {
    final user = currentUser;
    if (user == null) return;

    Get.dialog(
      AddProjectDialog(user: user, authController: authController, postService: postService),
      barrierDismissible: false,
    );
  }

  void showEditProfileDialog(BuildContext context) {
    final user = currentUser;
    if (user == null) return;

    Get.dialog(
      EditProfileDialog(user: user, authController: authController),
      barrierDismissible: false,
    );
  }

  void showOptionsMenu(BuildContext context, bool isDark) {
    final user = currentUser;
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildMenuOption(Icons.settings_outlined, 'settings'.tr, () {
                Get.back();
                Get.to(() => const SettingsPage());
              }, isDark: isDark),
              _buildMenuOption(Icons.history, 'activity'.tr, () {
                Get.back();
                Get.snackbar('comingSoon'.tr, 'featureUnderDevelopment'.tr);
              }, isDark: isDark),
              _buildMenuOption(Icons.qr_code_2, 'qrCode'.tr, () {
                Get.back();
                Get.snackbar('comingSoon'.tr, 'yourQrCode'.tr);
              }, isDark: isDark),
              _buildMenuOption(Icons.bookmark_outline, 'savedItems'.tr, () {
                Get.back();
                tabController.animateTo(2);
              }, isDark: isDark),
              Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
              _buildMenuOption(
                Icons.logout,
                'logout'.tr,
                () {
                  Get.back();
                  showLogoutDialog(context);
                },
                isDestructive: true,
                isDark: isDark,
              ),
              SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
    bool isDark = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87),
        size: 26,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : (isDark ? Colors.white : Colors.black87),
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  void showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('logout'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('logoutQuestion'.tr, style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await logout();
            },
            child: Text(
              'logout'.tr,
              style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void goToRegisterPage() {
    Get.to(() => const RegisterPage());
  }
}

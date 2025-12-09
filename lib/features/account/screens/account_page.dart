// account_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/posts/services/post_service.dart';
import 'package:workers/features/auth/screens/register_page.dart';
import 'package:workers/features/settings/screens/setting_page.dart';
import 'package:workers/widgets/add_project_dialog.dart';
import 'package:workers/widgets/edit_profile_dialog.dart';
import 'package:workers/features/account/screens/header_account_page.dart';
import 'package:workers/features/account/screens/body_account_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (!authController.isUserLoggedIn.value || authController.currentUser.value == null) {
        return Scaffold(
          backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
          body: _buildNotLoggedInView(context, isDark),
        );
      }

      final user = authController.currentUser.value!;
      // Debug: print user info to console
      print('AccountPage: user.role = ${user.role}, workerProfile = ${user.workerProfile != null}');
      // Show add button for ALL users (workers can post, clients can become workers)
      final isWorker = true; // Allow all users to add posts

      return Scaffold(
        backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Instagram-style AppBar
              SliverAppBar(
                backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
                foregroundColor: isDark ? Colors.white : Colors.black,
                elevation: 0,
                pinned: false,
                floating: true,
                title: Row(
                  children: [
                    Icon(Icons.lock_outline, size: 16, color: isDark ? Colors.white : Colors.black),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ],
                ),
                actions: [
                  if (isWorker)
                    IconButton(
                      icon: Icon(
                        Icons.add_box_outlined,
                        size: 28,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      onPressed: () => _showAddProjectDialog(context, user, authController),
                      tooltip: 'إضافة منشور جديد',
                    ),
                  IconButton(
                    icon: Icon(Icons.menu, size: 28, color: isDark ? Colors.white : Colors.black),
                    onPressed: () => _showOptionsMenu(context, authController, user, isDark),
                    tooltip: 'القائمة',
                  ),
                ],
              ),
            ];
          },
          body: CustomScrollView(
            slivers: [
              // Profile Header
              SliverToBoxAdapter(
                child: HeaderAccountPage(
                  user: user,
                  authController: authController,
                  context: context,
                  onEditProfilePressed: () => _showEditProfileDialog(context, authController, user),
                  onMenuPressed: () => _showOptionsMenu(context, authController, user, isDark),
                ),
              ),

              // Tab Bar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: isDark ? Colors.white : Colors.black,
                    indicatorWeight: 1,
                    labelColor: isDark ? Colors.white : Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on, size: 26)),
                      Tab(icon: Icon(Icons.person_pin_outlined, size: 26)),
                      Tab(icon: Icon(Icons.bookmark_border, size: 26)),
                    ],
                  ),
                  isDark: isDark,
                ),
              ),

              // Tab Content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Posts
                    BodyAccountPage(user: user, authController: authController, context: context),
                    // Tagged
                    _buildTaggedSection(),
                    // Saved
                    _buildSavedSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddProjectDialog(context, user, authController),
          backgroundColor: Color.fromARGB(255, 5, 95, 66),
          elevation: 6,
          child: Icon(Icons.add, size: 30, color: Colors.white),
        ),
      );
    });
  }

  Widget _buildNotLoggedInView(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_outlined,
              size: 120,
              color: isDark ? Colors.grey[600] : Colors.grey[300],
            ),
            SizedBox(height: 32),
            Text(
              'لم تقم بتسجيل الدخول',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'قم بإنشاء حساب للبدء في مشاركة\nأعمالك والتواصل مع العملاء',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const RegisterPage()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0095F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.to(() => const RegisterPage()),
              child: Text(
                'لديك حساب بالفعل؟ تسجيل الدخول',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF0095F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaggedSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2),
                ),
                child: Icon(
                  Icons.person_pin_outlined,
                  size: 50,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'الصور والفيديوهات التي تم الإشارة إليك فيها',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'عندما يشير إليك الأشخاص في الصور\nومقاطع الفيديو، ستظهر هنا',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isDark ? Colors.white : Colors.black, width: 2),
                ),
                child: Icon(
                  Icons.bookmark_border,
                  size: 50,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'حفظ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'احفظ الصور والفيديوهات التي تريد\nرؤيتها مرة أخرى. لن يعلم أحد بما تحفظه',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context, dynamic user, AuthController authController) {
    final postService = Get.isRegistered<PostService>()
        ? Get.find<PostService>()
        : Get.put<PostService>(PostService(), permanent: true);
    Get.dialog(
      AddProjectDialog(user: user, authController: authController, postService: postService),
      barrierDismissible: false,
    );
  }

  void _showEditProfileDialog(BuildContext context, AuthController authController, dynamic user) {
    Get.dialog(
      EditProfileDialog(user: user, authController: authController),
      barrierDismissible: false,
    );
  }

  void _showOptionsMenu(
    BuildContext context,
    AuthController authController,
    dynamic user,
    bool isDark,
  ) {
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
              _buildMenuOption(Icons.settings_outlined, 'الإعدادات', () {
                Get.back();
                Get.to(() => const SettingsPage());
              }, isDark: isDark),
              _buildMenuOption(Icons.history, 'نشاطك', () {
                Get.back();
                Get.snackbar('قريباً', 'صفحة النشاط قيد التطوير');
              }, isDark: isDark),
              _buildMenuOption(Icons.qr_code_2, 'رمز QR', () {
                Get.back();
                Get.snackbar('قريباً', 'رمز QR الخاص بك');
              }, isDark: isDark),
              _buildMenuOption(Icons.bookmark_outline, 'المحفوظات', () {
                Get.back();
                _tabController.animateTo(2);
              }, isDark: isDark),
              Divider(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]),
              _buildMenuOption(
                Icons.logout,
                'تسجيل الخروج',
                () {
                  Get.back();
                  _showLogoutDialog(context, authController);
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

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('تسجيل الخروج', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد من تسجيل الخروج من حسابك؟', style: TextStyle(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await authController.logout();
              Get.offAll(() => const RegisterPage());
            },
            child: Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, {this.isDark = false});

  final TabBar _tabBar;
  final bool isDark;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: isDark ? Color(0xFF121212) : Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => oldDelegate.isDark != isDark;
}

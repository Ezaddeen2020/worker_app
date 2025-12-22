// account_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/account/controllers/account_controller.dart';
import 'package:workers/features/account/screens/header_account_page.dart';
import 'package:workers/features/account/screens/body_account_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AccountController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (!controller.authController.isUserLoggedIn.value ||
          controller.authController.currentUser.value == null) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF114577), Color(0xFF91ADC6), Color(0xFFF2F8F3).withOpacity(0.09)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: _NotLoggedInView(controller: controller, isDark: isDark),
          ),
        );
      }

      final user = controller.authController.currentUser.value!;

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF114577), Color(0xFF91ADC6), Color(0xFFF2F8F3).withOpacity(0.09)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Instagram-style AppBar
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Color(0xFF114577),
                  elevation: 0,
                  pinned: false,
                  floating: true,
                  title: Row(
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: Color(0xFF114577)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF114577),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF114577)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.add_box_outlined, size: 28, color: Color(0xFF114577)),
                      onPressed: () => controller.showAddProjectDialog(context),
                      tooltip: 'addNewPost'.tr,
                    ),
                    IconButton(
                      icon: Icon(Icons.menu, size: 28, color: Color(0xFF114577)),
                      onPressed: () => controller.showOptionsMenu(context, isDark),
                      tooltip: 'menu'.tr,
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
                    authController: controller.authController,
                    context: context,
                    onEditProfilePressed: () => controller.showEditProfileDialog(context),
                    onMenuPressed: () => controller.showOptionsMenu(context, isDark),
                  ),
                ),

                // Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      controller: controller.tabController,
                      indicatorColor: Color(0xFF114577),
                      indicatorWeight: 2,
                      labelColor: Color(0xFF114577),
                      unselectedLabelColor: Color(0xFF91ADC6),
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
                    controller: controller.tabController,
                    children: [
                      // Posts
                      BodyAccountPage(
                        user: user,
                        authController: controller.authController,
                        context: context,
                      ),
                      // Tagged
                      _TaggedSection(isDark: isDark),
                      // Saved
                      _SavedSection(isDark: isDark),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => controller.showAddProjectDialog(context),
          backgroundColor: Color(0xFF114577),
          elevation: 6,
          child: Icon(Icons.add, size: 30, color: Colors.white),
        ),
      );
    });
  }
}

class _NotLoggedInView extends StatelessWidget {
  final AccountController controller;
  final bool isDark;

  const _NotLoggedInView({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
              'notLoggedIn'.tr,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'createAccountToStart'.tr,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.goToRegisterPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0095F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  'createNewAccount'.tr,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: controller.goToRegisterPage,
              child: Text(
                'alreadyHaveAccount'.tr,
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
}

class _TaggedSection extends StatelessWidget {
  final bool isDark;

  const _TaggedSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
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
                'taggedPhotos'.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'taggedDescription'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SavedSection extends StatelessWidget {
  final bool isDark;

  const _SavedSection({required this.isDark});

  @override
  Widget build(BuildContext context) {
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
                'save'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'savedDescription'.tr,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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

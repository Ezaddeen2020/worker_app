import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/home/controllers/home_controller.dart';
import 'package:workers/features/home/controllers/home_config_controller.dart';
import 'package:workers/features/workers/controllers/worker_controller.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'header_home.dart';
import 'search_home.dart';
import 'ratings_home.dart';
import 'body_home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = [
      HomeContent(
        controller: controller.workerController,
        configController: controller.configController,
      ),
      // ... باقي الصفحات كما في السابق ...
    ];
    return Scaffold(
      body: Obx(() => IndexedStack(index: controller.currentIndex.value, children: pages)),
      bottomNavigationBar: _BottomNav(controller: controller, isDark: isDark),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final HomeController controller;
  final bool isDark;
  const _BottomNav({required this.controller, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: controller.currentIndex.value,
        onTap: controller.changeTab,
        selectedItemColor: Color.fromARGB(255, 5, 95, 66),
        unselectedItemColor: Colors.grey,
        backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'homePageTitle'.tr),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'favoritesPageTitle'.tr),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'postsPageTitle'.tr),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'accountPageTitle'.tr),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final WorkerController controller;
  final HomeConfigController configController;
  const HomeContent({required this.controller, required this.configController, super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? Color(0xFF121212) : Colors.white,
      child: ListView.builder(
        itemCount: 4, // عدد الويدجتس الرئيسية
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return HeaderHome(authController: authController);
            case 1:
              return SearchHome(
                controller: controller,
                configController: configController,
                isDark: isDark,
              );
            case 2:
              return RatingsHome(
                controller: controller,
                configController: configController,
                isDark: isDark,
              );
            case 3:
              return BodyHome(
                controller: controller,
                configController: configController,
                isDark: isDark,
              );
            default:
              return SizedBox.shrink();
          }
        },
      ),
    );
  }
}

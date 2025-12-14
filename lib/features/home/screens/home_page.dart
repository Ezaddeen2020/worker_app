import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;
import 'package:workers/features/profile/screens/worker_profile_page.dart';
import 'dart:io';
import 'package:workers/features/workers/controllers/worker_controller.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/home/controllers/home_config_controller.dart';
import 'package:workers/features/home/controllers/home_controller.dart';
import 'package:workers/features/workers/models/worker_model.dart';
import 'package:workers/features/favorit/favorites_page.dart';
import 'package:workers/features/posts/screens/posts_page.dart';
import 'package:workers/features/account/screens/account_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pageController = PageController(initialPage: controller.currentIndex.value);

    final pages = [
      HomeContent(
        controller: controller.workerController,
        configController: controller.configController,
      ),
      const FavoritesPage(),
      const PostsPage(),
      const AccountPage(),
    ];

    void onPageChanged(int index) {
      controller.currentIndex.value = index;
    }

    void onNavTap(int index) {
      controller.changeTab(index);
      pageController.animateToPage(
        index,
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }

    return Scaffold(
      body: Obx(
        () => PageView(
          controller: pageController,
          onPageChanged: onPageChanged,
          children: pages,
          physics: const BouncingScrollPhysics(),
        ),
      ),
      bottomNavigationBar: _BottomNav(controller: controller, isDark: isDark, onTap: onNavTap),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final HomeController controller;
  final bool isDark;
  final void Function(int)? onTap;

  const _BottomNav({required this.controller, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.transparent,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
          onTap: onTap ?? controller.changeTab,
          backgroundColor: Colors.black,
          selectedItemColor: Color.fromARGB(255, 215, 184, 133),
          unselectedItemColor: Colors.grey,
          elevation: 0,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'homePageTitle'.tr),
            BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'favoritesPageTitle'.tr),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'postsPageTitle'.tr),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'accountPageTitle'.tr),
          ],
        ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF434B53), // أزرق رمادي داكن
            Color(0xFF353E47), // رمادي مزرق
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _HeaderSection(authController: authController),
            SizedBox(height: 20),
            _SearchBar(controller: controller, configController: configController, isDark: isDark),
            SizedBox(height: 20),
            _TopWorkersSection(
              controller: controller,
              configController: configController,
              isDark: isDark,
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => Text(
                    configController.config.categoriesTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD6C3A5), // لون ذهبي فاتح للعناوين
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            _CategoriesFilter(
              controller: controller,
              configController: configController,
              isDark: isDark,
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: Obx(
                  () => Text(
                    configController.config.allWorkersTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD6C3A5), // لون ذهبي فاتح للعناوين
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            _WorkersList(
              controller: controller,
              configController: configController,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final AuthController authController;

  const _HeaderSection({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF434B53), // نفس لون بداية البودي
            Color(0xFF353E47), // نفس لون نهاية البودي
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final user = authController.currentUser.value;
            return Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                      // colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.imagePath != null && File(user!.imagePath).existsSync()
                        ? FileImage(File(user.imagePath))
                        : null,
                    child: user?.imagePath == null || !File(user!.imagePath).existsSync()
                        ? Icon(Icons.person, size: 32, color: Color.fromARGB(255, 5, 95, 66))
                        : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'homePageTitle'.tr,
                        style: TextStyle(color: Color.fromARGB(255, 186, 172, 159), fontSize: 14),
                      ),
                      Text(
                        user?.name ?? 'client'.tr,
                        style: TextStyle(
                          color: Color(0xFFD6C3A5),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final WorkerController controller;
  final HomeConfigController configController;
  final bool isDark;

  const _SearchBar({
    required this.controller,
    required this.configController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 8, offset: Offset(0, 2)),
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(
        () => TextField(
          textAlign: TextAlign.right,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: configController.config.searchHint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700]),
            prefixIcon: Icon(Icons.search, color: Colors.black),
            filled: true,
            fillColor: Color.fromARGB(255, 231, 230, 226),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.black12, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
          onChanged: (value) => controller.searchWorkers(value),
        ),
      ),
    );
  }
}

class _TopWorkersSection extends StatelessWidget {
  final WorkerController controller;
  final HomeConfigController configController;
  final bool isDark;

  const _TopWorkersSection({
    required this.controller,
    required this.configController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final topWorkers = controller.workers.where((w) => w.rating >= 4.5).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));

      if (topWorkers.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                configController.config.featuredWorkersTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Color(0xFFD6C3A5),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: topWorkers.take(5).length,
              itemBuilder: (context, index) {
                final worker = topWorkers[index];
                return _TopWorkerCard(worker: worker, isDark: isDark);
              },
            ),
          ),
        ],
      );
    });
  }
}

class _TopWorkerCard extends StatelessWidget {
  final Worker worker;
  final bool isDark;

  const _TopWorkerCard({required this.worker, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 10, offset: Offset(0, 3)),
        ],
        border: Border.all(color: Color(0xFFD6C3A5).withOpacity(0.22), width: 1.1),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => const WorkerProfilePage(), arguments: worker),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isDark
                    ? [Color(0xFF353E47), Color(0xFF434B53)]
                    : [Color(0xFF434B53), Color(0xFF353E47)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(worker.imageUrl),
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                      ),
                    ),
                    Positioned(
                      top: 0.5,
                      right: 0.5,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              '${worker.rating}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        worker.name,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        worker.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: Color.fromARGB(255, 250, 251, 251),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey),
                          SizedBox(width: 2),
                          Text(worker.city, style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoriesFilter extends StatelessWidget {
  final WorkerController controller;
  final HomeConfigController configController;
  final bool isDark;

  const _CategoriesFilter({
    required this.controller,
    required this.configController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.transparent,
      child: Obx(() {
        final cats = configController.config.categories;
        final selected = controller.selectedCategory.value;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12),
          itemCount: cats.length,
          itemBuilder: (context, index) {
            final category = cats[index];
            final isSelected = selected == category.name;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (selected) => controller.filterByCategory(category.name),
                selectedColor: Color(0xFFD6C3A5),
                backgroundColor: isDark ? Color(0xFF262626) : Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected
                      ? const Color.fromARGB(255, 41, 39, 39)
                      : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _WorkersList extends StatelessWidget {
  final WorkerController controller;
  final HomeConfigController configController;
  final bool isDark;

  const _WorkersList({
    required this.controller,
    required this.configController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final workers = controller.filteredWorkers.toList();

      if (isLoading) {
        return Center(child: CircularProgressIndicator());
      }

      if (workers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
              SizedBox(height: 16),
              Obx(
                () => Text(
                  configController.config.emptyResultsMessage,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: workers
            .map(
              (worker) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _WorkerCard(worker: worker, controller: controller, isDark: isDark),
              ),
            )
            .toList(),
      );
    });
  }
}

class _WorkerCard extends StatelessWidget {
  final Worker worker;
  final WorkerController controller;
  final bool isDark;

  const _WorkerCard({required this.worker, required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 5,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => Get.to(() => const WorkerProfilePage(), arguments: worker),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: isDark
                  ? [Color(0xFF353E47), Color(0xFF434B53)]
                  : [Color(0xFF434B53), Color(0xFF353E47)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.13),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
            border: Border.all(color: Color(0xFFD6C3A5).withOpacity(0.32), width: 1.3),
          ),
          child: Padding(
            padding: EdgeInsets.all(0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundImage: NetworkImage(worker.imageUrl),
                          backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, size: 12, color: Colors.white),
                                SizedBox(width: 3),
                                Text(
                                  '${worker.rating}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                              shadows: [
                                if (!isDark)
                                  Shadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 6),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 235, 238, 237).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              worker.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color.fromARGB(255, 235, 238, 237),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: const Color.fromARGB(255, 243, 239, 239),
                              ),
                              SizedBox(width: 4),
                              Text(
                                worker.city,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color.fromARGB(255, 211, 204, 204),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.work_history,
                                size: 14,
                                color: const Color.fromARGB(255, 211, 204, 204),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${worker.experience} ${'yearsOfExperience'.tr}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color.fromARGB(255, 211, 204, 204),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Obx(() {
                      final currentWorker = controller.workers.firstWhere(
                        (w) => w.id == worker.id,
                        orElse: () => worker,
                      );
                      return IconButton(
                        icon: Icon(
                          currentWorker.isFollowing ? Icons.favorite : Icons.favorite_border,
                          color: currentWorker.isFollowing ? Colors.red : Colors.grey,
                        ),
                        onPressed: () => controller.toggleFollow(currentWorker),
                      );
                    }),
                  ],
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Color(0xFF434B53), Color(0xFF353E47)]
                          : [Color(0xFF353E47), Color(0xFF434B53)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Color(0xFFD6C3A5).withOpacity(0.18), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'reviews'.tr,
                        value: '${worker.reviewsCount}',
                        icon: Icons.rate_review,
                        isDark: isDark,
                      ),
                      _StatColumn(
                        label: 'followers'.tr,
                        value: '${worker.followersCount}',
                        icon: Icons.people,
                        isDark: isDark,
                      ),
                      _StatColumn(
                        label: 'rating'.tr,
                        value: '${worker.rating}',
                        icon: Icons.star,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.makePhoneCall(worker.phone),
                        icon: Icon(Icons.phone, size: 18, color: Colors.black),
                        label: Text('phone'.tr),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 231, 230, 226),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => controller.openWhatsApp(worker.whatsapp),
                        icon: Icon(Icons.chat, size: 18, color: Colors.black),
                        label: Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 231, 230, 226),
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isDark;

  const _StatColumn({
    required this.label,
    required this.value,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Color.fromARGB(255, 229, 182, 111)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Color.fromARGB(255, 215, 210, 200),
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: const Color.fromARGB(255, 172, 171, 171)),
        ),
      ],
    );
  }
}

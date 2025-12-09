import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;
import 'dart:io';
import 'package:workers/features/workers/controllers/worker_controller.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/home/controllers/home_config_controller.dart';
import 'package:workers/core/localization/localization_delegate.dart';
import 'package:workers/features/workers/models/worker_model.dart';
import 'package:workers/features/profile/screens/profile_page.dart';
import 'package:workers/features/home/screens/favorites_page.dart';
import 'package:workers/features/posts/screens/posts_page.dart';
import 'package:workers/features/account/screens/account_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WorkerController controller = Get.find<WorkerController>();
  final HomeConfigController configController = Get.find<HomeConfigController>();
  int _currentIndex = 0;

  // Pages for bottom navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      // Home content is built via helper methods below
      HomeContent(controller: controller, configController: configController),
      const FavoritesPage(),
      const PostsPage(),
      // Account / profile tab
      const AccountPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: Color.fromARGB(255, 5, 95, 66),
      unselectedItemColor: Colors.grey,
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.white,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context).homePageTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: AppLocalizations.of(context).favoritesPageTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message),
          label: AppLocalizations.of(context).postsPageTitle,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppLocalizations.of(context).accountPageTitle,
        ),
      ],
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderSection(authController),
            SizedBox(height: 20),
            _buildSearchBar(isDark),
            SizedBox(height: 20),
            _buildTopWorkersSection(isDark),
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
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildCategoriesFilter(isDark),
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
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            _buildWorkersList(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(AuthController authController) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 5, 95, 66), Color.fromARGB(255, 10, 150, 100)],
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
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            user?.imagePath != null && File(user!.imagePath).existsSync()
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
                            AppLocalizations.of(context).homePageTitle,
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            user?.name ?? AppLocalizations.of(context).client,
                            style: TextStyle(
                              color: Colors.white,
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
      },
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.transparent,
      child: Obx(
        () => TextField(
          textAlign: TextAlign.right,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: configController.config.searchHint,
            hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 5, 95, 66)),
            filled: true,
            fillColor: isDark ? Color(0xFF262626) : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          ),
          onChanged: (value) => controller.searchWorkers(value),
        ),
      ),
    );
  }

  Widget _buildTopWorkersSection(bool isDark) {
    return Obx(() {
      // الحصول على أفضل العمال بناءً على التقييم
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
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Container(
            height: 210,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              itemCount: topWorkers.take(5).length,
              itemBuilder: (context, index) {
                final worker = topWorkers[index];
                return _buildTopWorkerCard(worker, isDark);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTopWorkerCard(Worker worker, bool isDark) {
    return Container(
      width: 160,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        child: InkWell(
          onTap: () => Get.to(() => WorkerProfilePage(worker: worker)),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isDark
                    ? [Color(0xFF1E1E1E), Color(0xFF262626)]
                    : [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          color: Color.fromARGB(255, 5, 95, 66),
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

  Widget _buildCategoriesFilter(bool isDark) {
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
                selectedColor: Color.fromARGB(255, 5, 95, 66),
                backgroundColor: isDark ? Color(0xFF262626) : Colors.grey[200],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildWorkersList(bool isDark) {
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
                child: _buildWorkerCard(worker, isDark),
              ),
            )
            .toList(),
      );
    });
  }

  Widget _buildWorkerCard(Worker worker, bool isDark) {
    return Builder(
      builder: (BuildContext context) {
        return Card(
          margin: EdgeInsets.zero,
          elevation: 3,
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: InkWell(
            onTap: () => Get.to(() => WorkerProfilePage(worker: worker)),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: isDark
                      ? [Color(0xFF1E1E1E), Color(0xFF262626)]
                      : [Colors.white, Colors.grey[50]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(14),
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
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 6),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 5, 95, 66).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  worker.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 5, 95, 66),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    worker.city,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.work_history, size: 14, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    '${worker.experience} ${AppLocalizations.of(context).yearsOfExperience}',
                                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
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
                        color: isDark ? Color(0xFF262626) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatColumn(
                            AppLocalizations.of(context).reviews,
                            '${worker.reviewsCount}',
                            Icons.rate_review,
                            isDark,
                          ),
                          _buildStatColumn(
                            AppLocalizations.of(context).followers,
                            '${worker.followersCount}',
                            Icons.people,
                            isDark,
                          ),
                          _buildStatColumn(
                            AppLocalizations.of(context).rating,
                            '${worker.rating}',
                            Icons.star,
                            isDark,
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
                            icon: Icon(Icons.phone, size: 18),
                            label: Text(AppLocalizations.of(context).phone),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 5, 95, 66),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => controller.openWhatsApp(worker.whatsapp),
                            icon: Icon(Icons.chat, size: 18),
                            label: Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
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
      },
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Color.fromARGB(255, 5, 95, 66)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}

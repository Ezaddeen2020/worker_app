import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../workers/controllers/worker_controller.dart';
import '../controllers/worker_profile_controller.dart';
import '../../reviews/models/review_model.dart';

class WorkerProfilePage extends StatelessWidget {
  const WorkerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkerProfileController());
    final workerController = Get.find<WorkerController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader(controller)),
          ),
          SliverToBoxAdapter(child: _buildStatsSection(controller, isDark)),
          SliverToBoxAdapter(child: _buildActionButtons(controller, workerController, isDark)),
          SliverToBoxAdapter(child: _buildBioSection(controller, isDark)),
          SliverToBoxAdapter(child: _buildTabBar(controller, isDark)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 400,
              child: TabBarView(
                controller: controller.tabController,
                children: [
                  _buildPortfolioSection(controller, isDark),
                  _buildReviewsSection(controller, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(WorkerProfileController controller) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 5, 95, 66), Color.fromARGB(255, 10, 150, 100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          const Opacity(
            opacity: 0.1,
            child: Icon(Icons.construction, size: 200, color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: controller.worker.imageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(controller.worker.imageUrl)
                      : null,
                  backgroundColor: Colors.white,
                  child: controller.worker.imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Color.fromARGB(255, 5, 95, 66))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                controller.worker.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  controller.worker.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    controller.worker.city,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(WorkerProfileController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            '${controller.worker.rating}',
            'rating'.tr,
            Icons.star,
            Colors.amber,
            isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            '${controller.worker.reviewsCount}',
            'reviews'.tr,
            Icons.rate_review,
            Colors.blue,
            isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            '${controller.worker.followersCount}',
            'followers'.tr,
            Icons.people,
            Colors.pink,
            isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            '${controller.worker.experience}',
            'yearsOfExperience'.tr,
            Icons.work_history,
            Colors.green,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon, Color color, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDivider(bool isDark) =>
      Container(height: 40, width: 1, color: isDark ? Colors.grey[700] : Colors.grey[300]);

  Widget _buildActionButtons(
    WorkerProfileController controller,
    WorkerController workerController,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Builder(
        builder: (context) {
          final currentWorker = workerController.workers.firstWhere(
            (w) => w.id == controller.worker.id,
            orElse: () => controller.worker,
          );
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => workerController.toggleFollow(currentWorker),
                  icon: Icon(currentWorker.isFollowing ? Icons.favorite : Icons.favorite_border),
                  label: Text(currentWorker.isFollowing ? 'following'.tr : 'follow'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentWorker.isFollowing
                        ? Colors.red.withValues(alpha: 0.2)
                        : const Color.fromARGB(255, 5, 95, 66),
                    foregroundColor: currentWorker.isFollowing ? Colors.red : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: currentWorker.isFollowing
                          ? const BorderSide(color: Colors.red, width: 1.5)
                          : BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => workerController.openWhatsApp(controller.worker.whatsapp),
                  icon: const Icon(Icons.message),
                  label: Text('message'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => workerController.makePhoneCall(controller.worker.phone),
                  icon: const Icon(Icons.phone),
                  label: Text('phone'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 5, 95, 66),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBioSection(WorkerProfileController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'aboutWorker'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF262626) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            child: Text(
              controller.worker.bio,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 5, 95, 66).withValues(alpha: 0.05),
                  const Color.fromARGB(255, 10, 150, 100).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color.fromARGB(255, 5, 95, 66).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color.fromARGB(255, 5, 95, 66), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'additionalInfo'.tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 5, 95, 66),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${'experience'.tr}: ${controller.worker.experience} ${'yearsOfExperience'.tr} • ${'rating'.tr}: ${controller.worker.rating}/5.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabBar(WorkerProfileController controller, bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: TabBar(
        controller: controller.tabController,
        indicatorColor: const Color.fromARGB(255, 5, 95, 66),
        indicatorWeight: 3,
        labelColor: const Color.fromARGB(255, 5, 95, 66),
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(icon: const Icon(Icons.image_not_supported), text: 'portfolio'.tr),
          Tab(icon: const Icon(Icons.star), text: 'reviews'.tr),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(WorkerProfileController controller, bool isDark) {
    if (controller.worker.portfolio.isEmpty) {
      return Container(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text('noWorksFound'.tr, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Container(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: controller.worker.portfolio.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: CachedNetworkImage(
                imageUrl: controller.worker.portfolio[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  child: Icon(Icons.broken_image, color: Colors.grey[600]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewsSection(WorkerProfileController controller, bool isDark) {
    return Obx(() {
      if (controller.isLoadingReviews.value) {
        return Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.hasError.value) {
        return Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Center(
            child: Text(
              '${'error'.tr}: ${controller.errorMessage.value}',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
        );
      }

      if (controller.reviews.isEmpty) {
        return Container(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rate_review, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text('noReviewsFound'.tr, style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  'beFirstToReview'.tr,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.reviews.length,
          itemBuilder: (context, index) =>
              _buildReviewCard(controller, controller.reviews[index], isDark),
        ),
      );
    });
  }

  Widget _buildReviewCard(WorkerProfileController controller, Review review, bool isDark) {
    final formattedDate = controller.formatDate(review.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue[100], shape: BoxShape.circle),
                child: Text(
                  'U',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'client'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (idx) => Icon(
                            idx < review.rating ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

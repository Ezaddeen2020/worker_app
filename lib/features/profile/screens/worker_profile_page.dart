import 'package:flutter/material.dart';
import 'package:get/get.dart' as get_package;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:workers/core/localization/localization_delegate.dart';
import '../../workers/models/worker_model.dart';
import '../../workers/controllers/worker_controller.dart';
import '../../reviews/models/review_model.dart';
import '../../reviews/services/review_service.dart';

class WorkerProfilePage extends StatefulWidget {
  final Worker worker;

  const WorkerProfilePage({required this.worker, super.key});

  @override
  State<WorkerProfilePage> createState() => _WorkerProfilePageState();
}

class _WorkerProfilePageState extends State<WorkerProfilePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WorkerController controller = get_package.Get.find();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? Color(0xFF121212) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
          ),
          SliverToBoxAdapter(child: _buildStatsSection(isDark)),
          SliverToBoxAdapter(child: _buildActionButtons(isDark)),
          SliverToBoxAdapter(child: _buildBioSection(isDark)),
          SliverToBoxAdapter(child: _buildTabBar(isDark)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [_buildPortfolioSection(isDark), _buildReviewsSection(isDark)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 5, 95, 66), Color.fromARGB(255, 10, 150, 100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Opacity(opacity: 0.1, child: Icon(Icons.construction, size: 200, color: Colors.white)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage: widget.worker.imageUrl.isNotEmpty
                      ? CachedNetworkImageProvider(widget.worker.imageUrl)
                      : null,
                  backgroundColor: Colors.white,
                  child: widget.worker.imageUrl.isEmpty
                      ? Icon(Icons.person, size: 50, color: Color.fromARGB(255, 5, 95, 66))
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.worker.name,
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
                  widget.worker.category,
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
                    widget.worker.city,
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
                  onPressed: () => get_package.Get.back(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
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
            '${widget.worker.rating}',
            AppLocalizations.of(context).rating,
            Icons.star,
            Colors.amber,
            isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            '${widget.worker.reviewsCount}',
            AppLocalizations.of(context).reviews,
            Icons.rate_review,
            Colors.blue,
            isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            '${widget.worker.followersCount}',
            AppLocalizations.of(context).followers,
            Icons.people,
            Colors.pink,
            isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            '${widget.worker.experience}',
            AppLocalizations.of(context).yearsOfExperience,
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

  Widget _buildActionButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? Color(0xFF1E1E1E) : Colors.white,
      child: get_package.Obx(() {
        final currentWorker = controller.workers.firstWhere(
          (w) => w.id == widget.worker.id,
          orElse: () => widget.worker,
        );

        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => controller.toggleFollow(currentWorker),
                icon: Icon(currentWorker.isFollowing ? Icons.favorite : Icons.favorite_border),
                label: Text(
                  currentWorker.isFollowing
                      ? AppLocalizations.of(context).following
                      : AppLocalizations.of(context).follow,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentWorker.isFollowing
                      ? Colors.red.withValues(alpha: 0.2)
                      : Color.fromARGB(255, 5, 95, 66),
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
                onPressed: () => controller.openWhatsApp(widget.worker.whatsapp),
                icon: const Icon(Icons.message),
                label: Text(AppLocalizations.of(context).message),
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
                onPressed: () => controller.makePhoneCall(widget.worker.phone),
                icon: const Icon(Icons.phone),
                label: Text(AppLocalizations.of(context).phone),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 5, 95, 66),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBioSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context).aboutWorker,
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
              color: isDark ? Color(0xFF262626) : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
            ),
            child: Text(
              widget.worker.bio,
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
                  Color.fromARGB(255, 5, 95, 66).withValues(alpha: 0.05),
                  Color.fromARGB(255, 10, 150, 100).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color.fromARGB(255, 5, 95, 66).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Color.fromARGB(255, 5, 95, 66), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).additionalInfo,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 5, 95, 66),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context).experience}: ${widget.worker.experience} ${AppLocalizations.of(context).yearsOfExperience} • ${AppLocalizations.of(context).rating}: ${widget.worker.rating}/5.0',
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

  Widget _buildTabBar(bool isDark) {
    return Container(
      color: isDark ? Color(0xFF1E1E1E) : Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Color.fromARGB(255, 5, 95, 66),
        indicatorWeight: 3,
        labelColor: Color.fromARGB(255, 5, 95, 66),
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(icon: Icon(Icons.image_not_supported), text: AppLocalizations.of(context).portfolio),
          Tab(icon: Icon(Icons.star), text: AppLocalizations.of(context).reviews),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection(bool isDark) {
    if (widget.worker.portfolio.isEmpty) {
      return Container(
        color: isDark ? Color(0xFF1E1E1E) : Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                AppLocalizations.of(context).noWorksFound,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: isDark ? Color(0xFF1E1E1E) : Colors.white,
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: widget.worker.portfolio.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
              ),
              child: CachedNetworkImage(
                imageUrl: widget.worker.portfolio[index],
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  child: const CircularProgressIndicator(),
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

  Widget _buildReviewsSection(bool isDark) {
    return FutureBuilder<List<Review>>(
      future: ReviewService.getReviewsForWorker(widget.worker.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: isDark ? Color(0xFF1E1E1E) : Colors.white,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            color: isDark ? Color(0xFF1E1E1E) : Colors.white,
            child: Center(
              child: Text(
                '${AppLocalizations.of(context).error}: ${snapshot.error}',
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
              ),
            ),
          );
        }

        final workerReviews = snapshot.data ?? [];

        if (workerReviews.isEmpty) {
          return Container(
            color: isDark ? Color(0xFF1E1E1E) : Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.rate_review, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).noReviewsFound,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).beFirstToReview,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: isDark ? Color(0xFF1E1E1E) : Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: workerReviews.length,
            itemBuilder: (context, index) => _buildReviewCard(workerReviews[index], isDark),
          ),
        );
      },
    );
  }

  Widget _buildReviewCard(Review review, bool isDark) {
    // Format the date for display
    final formattedDate =
        '${review.createdAt.year}-${review.createdAt.month.toString().padLeft(2, '0')}-${review.createdAt.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF262626) : Colors.grey[50],
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
                  'U', // Initial of user
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue[700]),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(
                        context,
                      ).client, // In a real app, we would fetch the user's name
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

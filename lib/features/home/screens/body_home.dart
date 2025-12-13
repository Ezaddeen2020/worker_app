import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/workers/controllers/worker_controller.dart';
import 'package:workers/features/home/controllers/home_config_controller.dart';

class BodyHome extends StatelessWidget {
  final WorkerController controller;
  final HomeConfigController configController;
  final bool isDark;
  const BodyHome({
    required this.controller,
    required this.configController,
    required this.isDark,
    super.key,
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
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(), // حتى لا يتعارض مع SingleChildScrollView الخارجي
        shrinkWrap: true,
        itemCount: workers.length,
        itemBuilder: (context, index) {
          final worker = workers[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _WorkerCard(worker: worker, controller: controller, isDark: isDark),
          );
        },
      );
    });
  }
}

class _WorkerCard extends StatelessWidget {
  final dynamic worker;
  final WorkerController controller;
  final bool isDark;
  const _WorkerCard({required this.worker, required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => Get.toNamed('/worker_profile', arguments: worker),
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
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Color(0xFFD6C3A5).withOpacity(0.25), // لمسة ذهبية خفيفة
              width: 1.2,
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
                              color: Color(0xFFD6C3A5).withOpacity(0.13),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              worker.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFD6C3A5),
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
                                '${worker.experience} ${'yearsOfExperience'.tr}',
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
                    color: isDark ? Color(0xFF434B53) : Color(0xFF353E47),
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
                        icon: Icon(Icons.phone, size: 18),
                        label: Text('phone'.tr),
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

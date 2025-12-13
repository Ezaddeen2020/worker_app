import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;
import 'package:workers/features/profile/screens/worker_profile_page.dart';
import 'package:workers/features/workers/controllers/worker_controller.dart';
import 'package:workers/features/home/controllers/home_config_controller.dart';
import 'package:workers/features/workers/models/worker_model.dart';

class RatingsHome extends StatelessWidget {
  final WorkerController controller;
  final HomeConfigController configController;
  final bool isDark;
  const RatingsHome({
    required this.controller,
    required this.configController,
    required this.isDark,
    super.key,
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
}

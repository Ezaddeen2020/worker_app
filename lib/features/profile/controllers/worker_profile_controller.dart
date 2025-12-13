import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;
import 'package:workers/features/workers/models/worker_model.dart';
import 'package:workers/features/reviews/models/review_model.dart';
import 'package:workers/features/reviews/services/review_service.dart';

class WorkerProfileController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  late Worker worker;

  final isLoadingReviews = false.obs;
  final reviews = <Review>[].obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    worker = Get.arguments as Worker;
    tabController = TabController(length: 2, vsync: this);
    loadReviews();
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> loadReviews() async {
    try {
      isLoadingReviews.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final workerReviews = await ReviewService.getReviewsForWorker(worker.id);
      reviews.value = workerReviews;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoadingReviews.value = false;
    }
  }

  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

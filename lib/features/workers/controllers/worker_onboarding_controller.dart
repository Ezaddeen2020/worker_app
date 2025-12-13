import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/workers/models/worker_profile_model.dart';
import 'package:workers/features/posts/models/project_model.dart';
import 'package:workers/features/workers/services/worker_profile_service.dart';
import 'package:workers/features/home/screens/home_page.dart';

class WorkerOnboardingController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  // Text Controllers
  final bioController = TextEditingController();
  final servicesController = TextEditingController();
  final projectTitleController = TextEditingController();
  final projectDescController = TextEditingController();
  final projectPriceController = TextEditingController();

  // Observable state
  final saving = false.obs;

  @override
  void onClose() {
    bioController.dispose();
    servicesController.dispose();
    projectTitleController.dispose();
    projectDescController.dispose();
    projectPriceController.dispose();
    super.onClose();
  }

  Future<void> saveProfile() async {
    final user = authController.currentUser.value;
    if (user == null) return;

    saving.value = true;

    final services = servicesController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final projectList = <Project>[];
    if (projectTitleController.text.trim().isNotEmpty) {
      final proj = Project(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workerId: user.id,
        title: projectTitleController.text.trim(),
        description: projectDescController.text.trim(),
        images: [],
        price: double.tryParse(projectPriceController.text) ?? 0.0,
        createdAt: DateTime.now(),
      );

      // Validate the project before adding it
      if (!proj.isValid()) {
        Get.snackbar('error'.tr, 'invalidProjectData'.tr);
        saving.value = false;
        return;
      }

      projectList.add(proj);
    }

    final profile = WorkerProfile(
      id: user.id,
      userId: user.id,
      bio: bioController.text.trim(),
      services: services,
      projects: projectList,
      rating: user.workerProfile?.rating ?? 0.0,
    );

    // Validate the profile before saving
    if (!profile.isValid()) {
      Get.snackbar('error'.tr, 'failedToSaveWorkerProfile'.tr);
      saving.value = false;
      return;
    }

    final saved = await WorkerProfileService.saveProfile(profile);

    if (saved) {
      // update current user with workerProfile
      await authController.updateUser(workerProfile: profile);
      Get.offAll(() => const HomePage());
      Get.snackbar('success'.tr, 'workerProfileCreatedSuccessfully'.tr);
    } else {
      Get.snackbar('error'.tr, 'failedToSaveWorkerProfile'.tr);
    }

    saving.value = false;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/workers/controllers/worker_onboarding_controller.dart';

class WorkerOnboardingPage extends StatelessWidget {
  const WorkerOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkerOnboardingController());

    return Scaffold(
      appBar: AppBar(
        title: Text('setupWorkerAccount'.tr),
        backgroundColor: const Color.fromARGB(255, 5, 95, 66),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text('aboutYou'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.bioController,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'writeBriefBio'.tr,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'servicesSeparatedByCommas'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.servicesController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'servicesExample'.tr,
              ),
            ),
            const SizedBox(height: 24),
            Text('addInitialProject'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller.projectTitleController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'projectTitle'.tr,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.projectDescController,
              maxLines: 3,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'projectDescription'.tr,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.projectPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: 'priceOptional'.tr,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.saving.value ? null : controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 5, 95, 66),
                  ),
                  child: controller.saving.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('saveAndComplete'.tr),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

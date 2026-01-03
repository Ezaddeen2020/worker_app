import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/workers/controllers/worker_onboarding_controller.dart';

class WorkerOnboardingPage extends StatelessWidget {
  const WorkerOnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkerOnboardingController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF1E1E1E) : Color.fromRGBO(231, 230, 226, 0.2),
      appBar: AppBar(
        title: Text(
          'setupWorkerAccount'.tr,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDark ? Color(0xFF1E1E1E) : Color.fromRGBO(231, 230, 226, 0.2),
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              'aboutYou'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.bioController,
              maxLines: 4,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                ),
                hintText: 'writeBriefBio'.tr,
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                fillColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'servicesSeparatedByCommas'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.servicesController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                ),
                hintText: 'servicesExample'.tr,
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                fillColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'addInitialProject'.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.projectTitleController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                ),
                hintText: 'projectTitle'.tr,
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                fillColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.projectDescController,
              maxLines: 3,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                ),
                hintText: 'projectDescription'.tr,
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                fillColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.projectPriceController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[400]!),
                ),
                hintText: 'priceOptional'.tr,
                hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                fillColor: isDark ? Color(0xFF2C2C2C) : Colors.white,
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.saving.value ? null : controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.indigo[600] : Colors.indigo[700],
                    foregroundColor: Colors.white,
                  ),
                  child: controller.saving.value
                      ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          'saveAndComplete'.tr,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

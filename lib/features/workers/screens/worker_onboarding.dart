import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/core/localization/localization_delegate.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/workers/models/worker_profile_model.dart';
import 'package:workers/features/posts/models/project_model.dart';
import 'package:workers/features/workers/services/worker_profile_service.dart';
import 'package:workers/features/home/screens/home_page.dart';

class WorkerOnboardingPage extends StatefulWidget {
  const WorkerOnboardingPage({super.key});

  @override
  State<WorkerOnboardingPage> createState() => _WorkerOnboardingPageState();
}

class _WorkerOnboardingPageState extends State<WorkerOnboardingPage> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController servicesController = TextEditingController();

  // initial project
  final TextEditingController projectTitleController = TextEditingController();
  final TextEditingController projectDescController = TextEditingController();
  final TextEditingController projectPriceController = TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    bioController.dispose();
    servicesController.dispose();
    projectTitleController.dispose();
    projectDescController.dispose();
    projectPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = authController.currentUser.value;
    if (user == null) return;

    setState(() => saving = true);

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
        Get.snackbar(
          AppLocalizations.of(context).error,
          AppLocalizations.of(context).invalidProjectData,
        );
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
      Get.snackbar(
        AppLocalizations.of(context).error,
        AppLocalizations.of(context).failedToSaveWorkerProfile,
      );
      return;
    }

    final saved = await WorkerProfileService.saveProfile(profile);

    if (saved) {
      // update current user with workerProfile
      await authController.updateUser(workerProfile: profile);
      Get.offAll(() => HomePage());
      Get.snackbar(
        AppLocalizations.of(context).success,
        AppLocalizations.of(context).workerProfileCreatedSuccessfully,
      );
    } else {
      Get.snackbar(
        AppLocalizations.of(context).error,
        AppLocalizations.of(context).failedToSaveWorkerProfile,
      );
    }

    setState(() => saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).setupWorkerAccount),
        backgroundColor: const Color.fromARGB(255, 5, 95, 66),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).aboutYou,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bioController,
              maxLines: 4,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context).writeBriefBio,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).servicesSeparatedByCommas,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: servicesController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context).servicesExample,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              AppLocalizations.of(context).addInitialProject,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: projectTitleController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context).projectTitle,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: projectDescController,
              maxLines: 3,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context).projectDescription,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: projectPriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: AppLocalizations.of(context).priceOptional,
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 5, 95, 66),
                ),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(AppLocalizations.of(context).saveAndComplete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/home/screens/home_page.dart';
import 'package:workers/features/workers/screens/worker_onboarding.dart';

class RegisterController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  // Text Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Observable states
  final RxnString selectedImagePath = RxnString(null);
  final RxString selectedRole = 'client'.obs;

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Getters
  bool get hasImage => selectedImagePath.value != null;
  String? get imagePath => selectedImagePath.value;

  // Methods
  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> pickImageFromGallery() async {
    final imagePath = await authController.pickImage(source: ImageSource.gallery);
    if (imagePath != null) {
      selectedImagePath.value = imagePath;
    }
  }

  Future<void> pickImageFromCamera() async {
    final imagePath = await authController.pickImage(source: ImageSource.camera);
    if (imagePath != null) {
      selectedImagePath.value = imagePath;
    }
  }

  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color.fromARGB(255, 5, 95, 66)),
                title: Text('camera'.tr),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Color.fromARGB(255, 5, 95, 66)),
                title: Text('gallery'.tr),
                onTap: () {
                  Navigator.pop(context);
                  pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> register() async {
    if (nameController.text.isEmpty) {
      Get.snackbar('error'.tr, 'nameRequired'.tr);
      return;
    }

    if (phoneController.text.isEmpty) {
      Get.snackbar('error'.tr, 'phoneRequired'.tr);
      return;
    }

    if (selectedImagePath.value == null) {
      Get.snackbar('error'.tr, 'selectProfileImage'.tr);
      return;
    }

    final success = await authController.registerUser(
      name: nameController.text,
      phone: phoneController.text,
      imagePath: selectedImagePath.value!,
      role: selectedRole.value,
    );

    if (success) {
      if (selectedRole.value == 'worker') {
        Get.offAll(() => WorkerOnboardingPage());
      } else {
        Get.offAll(() => HomePage());
      }
    }
  }
}

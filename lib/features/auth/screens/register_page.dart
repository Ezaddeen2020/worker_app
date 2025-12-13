import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:workers/features/auth/controller/register_controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RegisterController());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 95, 66),
              Color.fromARGB(255, 10, 150, 100)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header
                  const SizedBox(height: 20),
                  Text(
                    'createNewAccount'.tr,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'completeProfileInfo'.tr,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // Profile Image
                  _ProfileImagePicker(controller: controller),
                  const SizedBox(height: 12),
                  Text(
                    'tapToSelectImage'.tr,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // Name Field
                  _NameField(controller: controller),
                  const SizedBox(height: 20),

                  // Role Selection
                  _RoleSelection(controller: controller),
                  const SizedBox(height: 20),

                  // Phone Field
                  _PhoneField(controller: controller),
                  const SizedBox(height: 40),

                  // Register Button
                  _RegisterButton(controller: controller),
                  const SizedBox(height: 20),

                  // Info Box
                  _InfoBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileImagePicker extends StatelessWidget {
  final RegisterController controller;

  const _ProfileImagePicker({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.showImagePickerOptions(context),
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 5, 95, 66),
              Color.fromARGB(255, 10, 150, 100),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Obx(() {
          final imagePath = controller.selectedImagePath.value;
          if (imagePath == null) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.camera_alt, size: 50, color: Colors.white),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.2),
                ),
                child: const Icon(Icons.edit, size: 30, color: Colors.white),
              ),
            );
          }
        }),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final RegisterController controller;

  const _NameField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.nameController,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'enterYourFullName'.tr,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: const Icon(Icons.person, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class _RoleSelection extends StatelessWidget {
  final RegisterController controller;

  const _RoleSelection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'accountType'.tr,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('client'.tr),
                    selected: controller.selectedRole.value == 'client',
                    onSelected: (s) => controller.setRole('client'),
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: controller.selectedRole.value == 'client'
                          ? Color.fromARGB(255, 5, 95, 66)
                          : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: Text('worker'.tr),
                    selected: controller.selectedRole.value == 'worker',
                    onSelected: (s) => controller.setRole('worker'),
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: controller.selectedRole.value == 'worker'
                          ? Color.fromARGB(255, 5, 95, 66)
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            )),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final RegisterController controller;

  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.phoneController,
      keyboardType: TextInputType.phone,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'phoneNumberPlaceholder'.tr,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        prefixIcon: const Icon(Icons.phone, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  final RegisterController controller;

  const _RegisterButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.authController.isLoading.value;
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : controller.register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Color.fromARGB(255, 5, 95, 66),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 5, 95, 66),
                    ),
                  ),
                )
              : Text(
                  'createAccount'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      );
    });
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'importantInformation'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          _InfoRow(text: 'mustEnterValidName'.tr),
          const SizedBox(height: 6),
          _InfoRow(text: 'phoneNumberMustBeValid'.tr),
          const SizedBox(height: 6),
          _InfoRow(text: 'imageMustBeClear'.tr),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String text;

  const _InfoRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.right,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
          ),
        ),
      ],
    );
  }
}

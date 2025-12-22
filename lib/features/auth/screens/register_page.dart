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
            colors: [Color(0xFFF2F3F5), Color(0xFF91ADC6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
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
                      color: Color(0xFF114577),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'المعلومات الكاملة'.tr,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF071B33)),
                  ),
                  const SizedBox(height: 40),

                  // Profile Image
                  _ProfileImagePicker(controller: controller),
                  const SizedBox(height: 12),
                  Text(
                    'انقر لاختيار صورة'.tr,
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
                  // _InfoBox(),
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Obx(() {
          final imagePath = controller.selectedImagePath.value;
          if (imagePath == null) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF91ADC6).withOpacity(0.15),
              ),
              child: const Icon(Icons.camera_alt, size: 50, color: Color(0xFF114577)),
            );
          } else {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(image: FileImage(File(imagePath)), fit: BoxFit.cover),
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.18),
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
      style: const TextStyle(color: Color(0xFF071B33)),
      decoration: InputDecoration(
        hintText: 'ادخل اسمك الكامل'.tr,
        hintStyle: TextStyle(color: Color(0xFF91ADC6)),
        prefixIcon: const Icon(Icons.person, color: Color(0xFF114577)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF91ADC6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF91ADC6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF114577), width: 2),
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
          child: Text('نوع الحساب', style: TextStyle(color: Color(0xFF071B33), fontSize: 14)),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Text('client'.tr),
                  selected: controller.selectedRole.value == 'client',
                  onSelected: (s) => controller.setRole('client'),
                  selectedColor: Color(0xFF91ADC6),
                  backgroundColor: Colors.white.withOpacity(0.7),
                  labelStyle: TextStyle(
                    color: controller.selectedRole.value == 'client'
                        ? Color(0xFF114577)
                        : Color(0xFF071B33),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: Text('worker'.tr),
                  selected: controller.selectedRole.value == 'worker',
                  onSelected: (s) => controller.setRole('worker'),
                  selectedColor: Color(0xFF91ADC6),
                  backgroundColor: Colors.white.withOpacity(0.7),
                  labelStyle: TextStyle(
                    color: controller.selectedRole.value == 'worker'
                        ? Color(0xFF114577)
                        : Color(0xFF071B33),
                  ),
                ),
              ),
            ],
          ),
        ),
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
      style: const TextStyle(color: Color(0xFF071B33)),
      decoration: InputDecoration(
        hintText: 'ادخل رقم هاتفك'.tr,
        hintStyle: TextStyle(color: Color(0xFF91ADC6)),
        prefixIcon: const Icon(Icons.phone, color: Color(0xFF114577)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.85),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF91ADC6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF91ADC6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF114577), width: 2),
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
            backgroundColor: Color(0xFF114577),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            disabledBackgroundColor: Color(0xFF91ADC6).withOpacity(0.5),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF91ADC6)),
                  ),
                )
              : Text(
                  'انشاء حساب'.tr,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workers/core/localization/localization_delegate.dart';
import 'dart:io';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/features/home/screens/home_page.dart';
import 'package:workers/features/workers/screens/worker_onboarding.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? selectedImagePath;
  String selectedRole = 'client';

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  /// اختيار الصورة من الهاتف
  Future<void> _pickImageFromGallery() async {
    final imagePath = await authController.pickImage(source: ImageSource.gallery);
    if (imagePath != null) {
      setState(() {
        selectedImagePath = imagePath;
      });
    }
  }

  /// التقاط صورة من الكاميرا
  Future<void> _pickImageFromCamera() async {
    final imagePath = await authController.pickImage(source: ImageSource.camera);
    if (imagePath != null) {
      setState(() {
        selectedImagePath = imagePath;
      });
    }
  }

  /// عرض خيارات اختيار الصورة
  void _showImagePickerOptions() {
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
                title: Text(AppLocalizations.of(context).camera),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Color.fromARGB(255, 5, 95, 66)),
                title: Text(AppLocalizations.of(context).gallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// التحقق والتسجيل
  Future<void> _register() async {
    if (nameController.text.isEmpty) {
      Get.snackbar(AppLocalizations.of(context).error, AppLocalizations.of(context).nameRequired);
      return;
    }

    if (phoneController.text.isEmpty) {
      Get.snackbar(AppLocalizations.of(context).error, AppLocalizations.of(context).phoneRequired);
      return;
    }

    if (selectedImagePath == null) {
      Get.snackbar(
        AppLocalizations.of(context).error,
        AppLocalizations.of(context).selectProfileImage,
      );
      return;
    }

    final success = await authController.registerUser(
      name: nameController.text,
      phone: phoneController.text,
      imagePath: selectedImagePath!,
      role: selectedRole,
    );

    if (success) {
      if (selectedRole == 'worker') {
        // After successful registration, navigate worker to onboarding to setup profile/projects
        Get.offAll(() => WorkerOnboardingPage());
      } else {
        Get.offAll(() => HomePage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 5, 95, 66), Color.fromARGB(255, 10, 150, 100)],
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
                    AppLocalizations.of(context).createNewAccount,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).completeProfileInfo,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // صورة البروفايل
                  GestureDetector(
                    onTap: _showImagePickerOptions,
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
                      child: selectedImagePath == null
                          ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                              child: const Icon(Icons.camera_alt, size: 50, color: Colors.white),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: FileImage(File(selectedImagePath!)),
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
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(context).tapToSelectImage,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // حقل الاسم
                  TextField(
                    controller: nameController,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).enterYourFullName,
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
                  ),
                  const SizedBox(height: 20),
                  // اختيار دور المستخدم (عميل أم عامل)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      AppLocalizations.of(context).accountType,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(AppLocalizations.of(context).client),
                          selected: selectedRole == 'client',
                          onSelected: (s) {
                            setState(() => selectedRole = 'client');
                          },
                          selectedColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: selectedRole == 'client'
                                ? Color.fromARGB(255, 5, 95, 66)
                                : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(AppLocalizations.of(context).worker),
                          selected: selectedRole == 'worker',
                          onSelected: (s) {
                            setState(() => selectedRole = 'worker');
                          },
                          selectedColor: Colors.white,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          labelStyle: TextStyle(
                            color: selectedRole == 'worker'
                                ? Color.fromARGB(255, 5, 95, 66)
                                : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // حقل الهاتف
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).phoneNumberPlaceholder,
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
                  ),
                  const SizedBox(height: 40),

                  // زر التسجيل
                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authController.isLoading.value ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color.fromARGB(255, 5, 95, 66),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: Colors.white.withValues(alpha: 0.5),
                        ),
                        child: authController.isLoading.value
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
                                AppLocalizations.of(context).createAccount,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  // معلومات إضافية
                  Container(
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
                          AppLocalizations.of(context).importantInformation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(AppLocalizations.of(context).mustEnterValidName),
                        const SizedBox(height: 6),
                        _buildInfoRow(AppLocalizations.of(context).phoneNumberMustBeValid),
                        const SizedBox(height: 6),
                        _buildInfoRow(AppLocalizations.of(context).imageMustBeClear),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String text) {
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

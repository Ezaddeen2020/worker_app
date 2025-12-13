import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'dart:io';

class HeaderHome extends StatelessWidget {
  final AuthController authController;
  const HeaderHome({required this.authController, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 5, 95, 66), Color.fromARGB(255, 10, 150, 100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final user = authController.currentUser.value;
            return Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage: user?.imagePath != null && File(user!.imagePath).existsSync()
                        ? FileImage(File(user.imagePath))
                        : null,
                    child: user?.imagePath == null || !File(user!.imagePath).existsSync()
                        ? Icon(Icons.person, size: 32, color: Color.fromARGB(255, 5, 95, 66))
                        : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'homePageTitle'.tr,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        user?.name ?? 'client'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

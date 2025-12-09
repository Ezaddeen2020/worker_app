import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import 'package:workers/core/localization/localization_delegate.dart';
import 'package:workers/features/home/screens/home_page.dart';
import 'package:workers/features/auth/screens/register_page.dart';

class SplashController extends GetxController {
  final AuthController authController = Get.find<AuthController>();

  @override
  void onReady() {
    super.onReady();
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() async {
    // انتظار حتى ينتهي التحميل
    await Future.delayed(const Duration(milliseconds: 2000));

    // الانتقال للصفحة المناسبة مع transition سلس
    if (authController.isUserLoggedIn.value) {
      Get.offAll(
        () => HomePage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400),
      );
    } else {
      Get.offAll(
        () => RegisterPage(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 400),
      );
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A1929), // Navy Dark
              Color(0xFF1A2332),
              Color(0xFF1E3A5F),
              Color(0xFF2C5282), // Navy Light
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            _buildBackgroundCircles(),

            // Main content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Logo
                  _buildLogo(),

                  const SizedBox(height: 40),

                  // App title
                  _buildTitle(context),

                  const SizedBox(height: 16),

                  // Description
                  _buildDescription(context),

                  const Spacer(flex: 2),

                  // Loading indicator - ثابت بدون Obx لتجنب إعادة البناء
                  _buildLoadingIndicator(),

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCircles() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
        ),
        Positioned(
          top: 150,
          left: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Color(0xFF2C5282).withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A1929), Color(0xFF2C5282)],
            ),
          ),
          child: Icon(Icons.work_rounded, size: 60, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).splashScreenTitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.0), Colors.white, Colors.white.withOpacity(0.0)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        AppLocalizations.of(context).splashScreenDescription,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16,
          height: 1.5,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'جاري التحميل...',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, letterSpacing: 1),
        ),
      ],
    );
  }
}

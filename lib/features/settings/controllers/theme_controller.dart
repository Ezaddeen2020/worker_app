import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers/core/theme/app_colors.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'isDarkMode';

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  Future<void> _loadThemeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_themeKey) ?? false;
    _updateTheme();
  }

  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    await _saveThemeToStorage();
    _updateTheme();
  }

  Future<void> setDarkMode(bool value) async {
    isDarkMode.value = value;
    await _saveThemeToStorage();
    _updateTheme();
  }

  Future<void> _saveThemeToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode.value);
  }

  void _updateTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Light Theme
  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.background,
    dividerColor: AppColors.text.withOpacity(0.15),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      iconTheme: IconThemeData(color: AppColors.text),
      titleTextStyle: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.buttonBackground,
      unselectedItemColor: AppColors.text,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBackground,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: AppColors.text),
      bodyLarge: TextStyle(fontSize: 18, height: 1.5, color: AppColors.text),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
    ),
    iconTheme: const IconThemeData(color: AppColors.text),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.text, textColor: AppColors.text),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.buttonBackground,
      contentTextStyle: TextStyle(color: AppColors.white),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.buttonBackground,
      secondary: AppColors.text,
      surface: AppColors.background,
      error: Colors.red,
    ),
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.background,
    cardColor: AppColors.background,
    dividerColor: AppColors.text.withOpacity(0.15),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.background,
      iconTheme: IconThemeData(color: AppColors.text),
      titleTextStyle: TextStyle(color: AppColors.text, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.buttonBackground,
      unselectedItemColor: AppColors.text,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonBackground,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: AppColors.text),
      bodyLarge: TextStyle(fontSize: 18, height: 1.5, color: AppColors.text),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
    ),
    iconTheme: const IconThemeData(color: AppColors.text),
    listTileTheme: const ListTileThemeData(iconColor: AppColors.text, textColor: AppColors.text),
    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.buttonBackground,
      contentTextStyle: TextStyle(color: AppColors.white),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.buttonBackground,
      secondary: AppColors.text,
      surface: AppColors.background,
      error: Colors.red,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.background,
      filled: true,
      hintStyle: TextStyle(color: AppColors.text),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

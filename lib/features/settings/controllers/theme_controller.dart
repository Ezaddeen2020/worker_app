import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    primarySwatch: Colors.blue,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: Colors.grey[50],
    cardColor: Colors.white,
    dividerColor: Colors.grey[200],
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.blue[800]),
      titleTextStyle: TextStyle(color: Colors.blue[800], fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 18, height: 1.5, color: Colors.black87),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
    ),
    iconTheme: IconThemeData(color: Colors.black87),
    listTileTheme: ListTileThemeData(iconColor: Colors.black87, textColor: Colors.black87),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black87,
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blue[700]!,
      surface: Colors.white,
      error: Colors.red,
    ),
  );

  // Dark Theme
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: Color(0xFF121212),
    cardColor: Color(0xFF1E1E1E),
    dividerColor: Colors.grey[800],
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF121212),
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF121212),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[600],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: Colors.blue[700],
      ),
    ),
    textTheme: TextTheme(
      bodyMedium: TextStyle(fontSize: 16, height: 1.5, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 18, height: 1.5, color: Colors.white),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    ),
    iconTheme: IconThemeData(color: Colors.white),
    listTileTheme: ListTileThemeData(iconColor: Colors.white, textColor: Colors.white),
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey[800],
      contentTextStyle: TextStyle(color: Colors.white),
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue[400]!,
      secondary: Colors.blue[300]!,
      surface: Color(0xFF1E1E1E),
      error: Colors.red[400]!,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Color(0xFF2C2C2C),
      filled: true,
      hintStyle: TextStyle(color: Colors.grey[500]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

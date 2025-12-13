import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'language';

  final RxString currentLanguage = 'ar'.obs;
  final Rx<Locale> locale = const Locale('ar').obs;

  @override
  void onInit() {
    super.onInit();
    _loadLanguageFromStorage();
  }

  Future<void> _loadLanguageFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'ar';
    currentLanguage.value = savedLanguage;
    locale.value = Locale(savedLanguage);
    _updateLocale();
  }

  Future<void> changeLanguage(String languageCode) async {
    currentLanguage.value = languageCode;
    locale.value = Locale(languageCode);
    await _saveLanguageToStorage();
    _updateLocale();
  }

  Future<void> toggleLanguage() async {
    final newLanguage = currentLanguage.value == 'ar' ? 'en' : 'ar';
    await changeLanguage(newLanguage);
  }

  Future<void> _saveLanguageToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, currentLanguage.value);
  }

  void _updateLocale() {
    Get.updateLocale(locale.value);
  }

  String get currentLanguageName {
    return currentLanguage.value == 'ar' ? 'العربية' : 'English';
  }

  bool get isArabic => currentLanguage.value == 'ar';
  bool get isEnglish => currentLanguage.value == 'en';
}

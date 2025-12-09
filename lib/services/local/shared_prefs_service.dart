/// SharedPreferences Service - خدمة التخزين المحلي
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static SharedPreferences? _prefs;

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _firstTimeKey = 'first_time';

  /// تهيئة SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// الحصول على instance
  static SharedPreferences get instance {
    if (_prefs == null) {
      throw Exception('SharedPrefsService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ==================== Token ====================

  /// حفظ التوكن
  static Future<bool> saveToken(String token) async {
    await init();
    return _prefs!.setString(_tokenKey, token);
  }

  /// جلب التوكن
  static Future<String?> getToken() async {
    await init();
    return _prefs!.getString(_tokenKey);
  }

  /// حذف التوكن
  static Future<bool> removeToken() async {
    await init();
    return _prefs!.remove(_tokenKey);
  }

  /// حفظ Refresh Token
  static Future<bool> saveRefreshToken(String token) async {
    await init();
    return _prefs!.setString(_refreshTokenKey, token);
  }

  /// جلب Refresh Token
  static Future<String?> getRefreshToken() async {
    await init();
    return _prefs!.getString(_refreshTokenKey);
  }

  // ==================== User ====================

  /// حفظ بيانات المستخدم
  static Future<bool> saveUser(Map<String, dynamic> user) async {
    await init();
    return _prefs!.setString(_userKey, jsonEncode(user));
  }

  /// جلب بيانات المستخدم
  static Future<Map<String, dynamic>?> getUser() async {
    await init();
    final userJson = _prefs!.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson) as Map<String, dynamic>;
  }

  /// حذف بيانات المستخدم
  static Future<bool> removeUser() async {
    await init();
    return _prefs!.remove(_userKey);
  }

  // ==================== Login State ====================

  /// حفظ حالة تسجيل الدخول
  static Future<bool> setLoggedIn(bool value) async {
    await init();
    return _prefs!.setBool(_isLoggedInKey, value);
  }

  /// التحقق من تسجيل الدخول
  static Future<bool> isLoggedIn() async {
    await init();
    return _prefs!.getBool(_isLoggedInKey) ?? false;
  }

  // ==================== Theme ====================

  /// حفظ الثيم
  static Future<bool> saveTheme(String theme) async {
    await init();
    return _prefs!.setString(_themeKey, theme);
  }

  /// جلب الثيم
  static Future<String> getTheme() async {
    await init();
    return _prefs!.getString(_themeKey) ?? 'system';
  }

  // ==================== Language ====================

  /// حفظ اللغة
  static Future<bool> saveLanguage(String language) async {
    await init();
    return _prefs!.setString(_languageKey, language);
  }

  /// جلب اللغة
  static Future<String> getLanguage() async {
    await init();
    return _prefs!.getString(_languageKey) ?? 'ar';
  }

  // ==================== First Time ====================

  /// التحقق من أول مرة
  static Future<bool> isFirstTime() async {
    await init();
    return _prefs!.getBool(_firstTimeKey) ?? true;
  }

  /// تحديد أنه ليس أول مرة
  static Future<bool> setNotFirstTime() async {
    await init();
    return _prefs!.setBool(_firstTimeKey, false);
  }

  // ==================== Generic Methods ====================

  /// حفظ String
  static Future<bool> setString(String key, String value) async {
    await init();
    return _prefs!.setString(key, value);
  }

  /// جلب String
  static Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  /// حفظ int
  static Future<bool> setInt(String key, int value) async {
    await init();
    return _prefs!.setInt(key, value);
  }

  /// جلب int
  static Future<int?> getInt(String key) async {
    await init();
    return _prefs!.getInt(key);
  }

  /// حفظ bool
  static Future<bool> setBool(String key, bool value) async {
    await init();
    return _prefs!.setBool(key, value);
  }

  /// جلب bool
  static Future<bool?> getBool(String key) async {
    await init();
    return _prefs!.getBool(key);
  }

  /// حفظ List<String>
  static Future<bool> setStringList(String key, List<String> value) async {
    await init();
    return _prefs!.setStringList(key, value);
  }

  /// جلب List<String>
  static Future<List<String>?> getStringList(String key) async {
    await init();
    return _prefs!.getStringList(key);
  }

  /// حذف قيمة
  static Future<bool> remove(String key) async {
    await init();
    return _prefs!.remove(key);
  }

  /// مسح كل البيانات
  static Future<bool> clear() async {
    await init();
    return _prefs!.clear();
  }

  /// التحقق من وجود مفتاح
  static Future<bool> containsKey(String key) async {
    await init();
    return _prefs!.containsKey(key);
  }

  // ==================== Logout ====================

  /// تسجيل الخروج - مسح بيانات المصادقة
  static Future<void> logout() async {
    await removeToken();
    await _prefs!.remove(_refreshTokenKey);
    await removeUser();
    await setLoggedIn(false);
  }
}

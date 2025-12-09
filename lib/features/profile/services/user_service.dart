/// User Service - خدمة المستخدم
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers/core/localization/localization_delegate.dart';
import '../models/user_model.dart';

class UserService {
  static const String _userKey = 'current_user';
  static const String _allUsersKey = 'all_users'; // Key for storing all users

  /// حفظ بيانات المستخدم محلياً
  static Future<bool> saveUser(User user) async {
    try {
      // Validate the user before saving
      if (!user.isValid()) {
        print('Invalid User data');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toMap());
      return await prefs.setString(_userKey, userJson);
    } catch (e) {
      print('${AppLocalizations.of(Get.context!).error} saving user: $e');
      return false;
    }
  }

  /// استرجاع بيانات المستخدم المحفوظة
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) return null;

      final userMap = jsonDecode(userJson);
      return User.fromMap(userMap);
    } catch (e) {
      print('${AppLocalizations.of(Get.context!).error} retrieving user: $e');
      return null;
    }
  }

  /// التحقق من وجود مستخدم مسجل
  static Future<bool> hasUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_userKey);
    } catch (e) {
      return false;
    }
  }

  /// حذف بيانات المستخدم (تسجيل خروج)
  static Future<bool> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userKey);
    } catch (e) {
      print('${AppLocalizations.of(Get.context!).error} deleting user: $e');
      return false;
    }
  }

  /// تحديث بيانات المستخدم
  static Future<bool> updateUser(User user) async {
    try {
      // Validate the user before updating
      if (!user.isValid()) {
        print('Invalid User data');
        return false;
      }

      print('UserService: Updating user ${user.name}');

      // First save the current user
      final saved = await saveUser(user);

      // Then update the user in the all users list
      if (saved) {
        print('UserService: Current user saved, now updating all users list');
        await saveUserToAllUsersList(user);
      }

      print('UserService: User update completed. Success: $saved');
      return saved;
    } catch (e) {
      print('${AppLocalizations.of(Get.context!).error} updating user: $e');
      return false;
    }
  }

  /// التحقق من صحة البيانات
  static bool validateUserData({required String name, required String phone}) {
    // التحقق من الاسم
    if (name.isEmpty || name.length < 2) {
      return false;
    }

    // التحقق من الهاتف (رقم سعودي)
    if (phone.isEmpty || phone.length < 9) {
      return false;
    }

    // التحقق من أن الهاتف يحتوي على أرقام فقط
    if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(phone)) {
      return false;
    }

    return true;
  }

  /// Save user to the all users list
  static Future<bool> saveUserToAllUsersList(User user) async {
    try {
      // Validate the user before saving
      if (!user.isValid()) {
        print('Invalid User data');
        return false;
      }

      print(
        'UserService: Saving user ${user.name} with ${user.workerProfile?.projects.length ?? 0} projects to all users list',
      );

      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      List<User> allUsers = [];
      final allUsersJson = prefs.getString(_allUsersKey);
      if (allUsersJson != null) {
        final List<dynamic> allUsersList = jsonDecode(allUsersJson);
        allUsers = allUsersList.map((e) => User.fromMap(e)).toList();
        print('UserService: Found ${allUsers.length} existing users in storage');
      }

      // Check if user already exists
      final existingIndex = allUsers.indexWhere((u) => u.id == user.id);
      if (existingIndex != -1) {
        // Update existing user
        print('UserService: Updating existing user at index $existingIndex');
        allUsers[existingIndex] = user;
      } else {
        // Add new user
        print('UserService: Adding new user to list');
        allUsers.add(user);
      }

      // Save updated list
      final allUsersMap = allUsers.map((u) => u.toMap()).toList();
      final allUsersJsonString = jsonEncode(allUsersMap);
      final result = await prefs.setString(_allUsersKey, allUsersJsonString);

      print('UserService: Saved ${allUsers.length} users to storage. Success: $result');
      return result;
    } catch (e) {
      print('${AppLocalizations.of(Get.context!).error} saving user to all users list: $e');
      return false;
    }
  }

  /// Get all users
  static Future<List<User>> getAllUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsersJson = prefs.getString(_allUsersKey);

      if (allUsersJson == null) {
        print('UserService: No users found in storage');
        return [];
      }

      final List<dynamic> allUsersList = jsonDecode(allUsersJson);
      final users = allUsersList.map((e) => User.fromMap(e)).toList();

      // Print debug info
      print('UserService: Found ${users.length} users in storage');
      for (var user in users) {
        print(
          'UserService: User ${user.name} has ${user.workerProfile?.projects.length ?? 0} projects',
        );
      }

      return users;
    } catch (e) {
      print('${AppLocalizations.of(Get.context!).error} retrieving all users: $e');
      return [];
    }
  }

  /// Get user by ID
  static Future<User?> getUserById(String userId) async {
    try {
      final allUsers = await getAllUsers();
      return allUsers.firstWhereOrNull((u) => u.id == userId);
    } catch (e) {
      print('${AppLocalizations.of(Get.context!).error} retrieving user by ID: $e');
      return null;
    }
  }

  /// Initialize all users list with current user if it's empty
  static Future<void> initializeAllUsersList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allUsersJson = prefs.getString(_allUsersKey);

      // If all users list is empty, initialize it with current user
      if (allUsersJson == null) {
        final currentUser = await getUser();
        if (currentUser != null) {
          await saveUserToAllUsersList(currentUser);
        }
      }
    } catch (e) {
      print('${AppLocalizations.of(Get.context!).error} initializing all users list: $e');
    }
  }
}

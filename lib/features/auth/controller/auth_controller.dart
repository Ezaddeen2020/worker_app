import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:workers/core/localization/localization_delegate.dart';
import 'dart:io';
import 'package:workers/features/profile/models/user_model.dart';
import 'package:workers/features/workers/models/worker_profile_model.dart';
import 'package:workers/features/workers/services/worker_profile_service.dart';
import 'package:workers/features/profile/services/user_service.dart';

class AuthController extends GetxController {
  // ============== Observable Variables ==============
  final RxBool isUserLoggedIn = false.obs;
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt postUpdateTrigger = 0.obs; // Observable to trigger post updates
  final RxInt likeUpdateTrigger = 0.obs; // Observable to trigger like updates

  // ============== Token for API ==============
  String? _token;
  String? get token => _token;

  void setToken(String? newToken) {
    _token = newToken;
  }

  // ============== Lifecycle ==============
  @override
  void onInit() {
    super.onInit();
    checkUserStatus();
  }

  // ============== Main Methods ==============

  /// التحقق من وجود مستخدم مسجل
  Future<void> checkUserStatus() async {
    try {
      isLoading.value = true;
      final user = await UserService.getUser();
      if (user != null) {
        currentUser.value = user;

        // Ensure worker profile is attached even if role flag is missing or stale
        if (currentUser.value?.workerProfile == null) {
          final profile = await WorkerProfileService.getProfileByUserId(user.id);
          if (profile != null) {
            final updated = user.copyWith(
              workerProfile: profile,
              role: (user.role.isNotEmpty) ? user.role : 'worker',
            );
            currentUser.value = updated;
            // Persist the updated snapshot so subsequent launches keep the linkage
            await UserService.updateUser(updated);
          }
        }
        isUserLoggedIn.value = true;

        // Initialize all users list
        await UserService.initializeAllUsersList();
      } else {
        isUserLoggedIn.value = false;
      }
    } catch (e) {
      isUserLoggedIn.value = false;
      Get.snackbar(
        AppLocalizations.of(Get.context!).error,
        AppLocalizations.of(Get.context!).failedToChangeLikeStatus,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل مستخدم جديد باستخدام Model بشكل صحيح
  Future<bool> registerUser({
    required String name,
    required String phone,
    required String imagePath,
    String role = 'client',
  }) async {
    try {
      // التحقق من البيانات
      if (!UserService.validateUserData(name: name, phone: phone)) {
        errorMessage.value = AppLocalizations.of(Get.context!).invalidProjectData;
        Get.snackbar(AppLocalizations.of(Get.context!).error, errorMessage.value);
        return false;
      }

      if (imagePath.isEmpty) {
        errorMessage.value = AppLocalizations.of(Get.context!).selectProfileImage;
        Get.snackbar(AppLocalizations.of(Get.context!).error, errorMessage.value);
        return false;
      }

      isLoading.value = true;

      // إنشاء مستخدم جديد باستخدام User Model
      final uid = DateTime.now().millisecondsSinceEpoch.toString();

      WorkerProfile? profile;
      if (role == 'worker') {
        profile = WorkerProfile(id: uid, userId: uid);
      }

      final user = User(
        id: uid,
        name: name.trim(),
        phone: phone.trim(),
        imagePath: imagePath,
        role: role,
        workerProfile: profile,
        createdAt: DateTime.now(),
      );

      // التحقق من صحة النموذج
      if (!user.isValid()) {
        errorMessage.value = AppLocalizations.of(Get.context!).invalidProjectData;
        Get.snackbar(AppLocalizations.of(Get.context!).error, errorMessage.value);
        return false;
      }

      // حفظ المستخدم
      final saved = await UserService.saveUser(user);

      if (saved) {
        // إذا كان دور المستخدم عامل، احفظ ملف العامل منفصلاً لضمان مرونة التخزين
        if (profile != null) {
          final profileSaved = await WorkerProfileService.saveProfile(profile);
          if (!profileSaved) {
            // لا نريد إلغاء تسجيل المستخدم لكن نعلِم المستخدم
            Get.snackbar(
              AppLocalizations.of(Get.context!).warning,
              AppLocalizations.of(Get.context!).accountCreatedButWorkerProfileNotSaved,
            );
          }
        }

        currentUser.value = user;
        isUserLoggedIn.value = true;

        errorMessage.value = '';
        Get.snackbar(
          AppLocalizations.of(Get.context!).success,
          AppLocalizations.of(Get.context!).accountCreatedSuccessfully,
        );

        // Add user to all users list
        await UserService.saveUserToAllUsersList(user);

        return true;
      } else {
        errorMessage.value = AppLocalizations.of(Get.context!).failedToAddPost;
        Get.snackbar(AppLocalizations.of(Get.context!).error, errorMessage.value);
        return false;
      }
    } catch (e) {
      errorMessage.value = '${AppLocalizations.of(Get.context!).error}: $e';
      Get.snackbar(AppLocalizations.of(Get.context!).error, errorMessage.value);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث بيانات المستخدم
  Future<bool> updateUser({
    String? name,
    String? phone,
    String? imagePath,
    String? role,
    WorkerProfile? workerProfile,
  }) async {
    try {
      if (currentUser.value == null) return false;

      isLoading.value = true;

      final updatedUser = currentUser.value!.copyWith(
        name: name ?? currentUser.value!.name,
        phone: phone ?? currentUser.value!.phone,
        imagePath: imagePath ?? currentUser.value!.imagePath,
        role: role ?? currentUser.value!.role,
        workerProfile: workerProfile ?? currentUser.value!.workerProfile,
      );

      print(
        'AuthController: Updating user ${updatedUser.name} with ${updatedUser.workerProfile?.projects.length ?? 0} projects',
      );

      final updated = await UserService.updateUser(updatedUser);

      if (updated) {
        // إذا تم تعديل ملف العامل أيضاً، خزّنه منفصلاً مع تحقق بسيط للملكية
        if (workerProfile != null) {
          final ok = await WorkerProfileService.updateProfile(
            workerProfile,
            requesterUserId: currentUser.value!.id,
          );
          if (!ok) {
            Get.snackbar(
              AppLocalizations.of(Get.context!).error,
              AppLocalizations.of(Get.context!).failedToSaveWorkerProfile,
            );
            // لكن نستمر ونحدث user المحلي
          }
        }

        currentUser.value = updatedUser;

        // Also update the user in the all users list to ensure consistency
        await UserService.saveUserToAllUsersList(updatedUser);

        // Notify that a post has been added/updated
        notifyPostAdded();

        Get.snackbar(
          AppLocalizations.of(Get.context!).success,
          AppLocalizations.of(Get.context!).dataUpdatedSuccessfully,
        );
        print('AuthController: User update successful');
        return true;
      } else {
        Get.snackbar(
          AppLocalizations.of(Get.context!).error,
          AppLocalizations.of(Get.context!).errorOccurredWhileDeletingPost,
        );
        print('AuthController: User update failed');
        return false;
      }
    } catch (e) {
      Get.snackbar(
        AppLocalizations.of(Get.context!).error,
        '${AppLocalizations.of(Get.context!).error}: $e',
      );
      print('AuthController: User update error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// تسجيل خروج المستخدم
  Future<bool> logout() async {
    try {
      isLoading.value = true;
      final deleted = await UserService.deleteUser();

      if (deleted) {
        currentUser.value = null;
        isUserLoggedIn.value = false;
        Get.snackbar(
          AppLocalizations.of(Get.context!).success,
          AppLocalizations.of(Get.context!).loggedOutSuccessfully,
        );
        return true;
      } else {
        Get.snackbar(
          AppLocalizations.of(Get.context!).error,
          AppLocalizations.of(Get.context!).failedToDeletePost,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        AppLocalizations.of(Get.context!).error,
        '${AppLocalizations.of(Get.context!).error}: $e',
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// اختيار صورة من الجهاز أو الكاميرا - محسّن
  Future<String?> pickImage({required ImageSource source}) async {
    try {
      final ImagePicker picker = ImagePicker();

      // محاولة اختيار الصورة مع تحسينات
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 85, // جودة الصورة (80-100)
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image != null) {
        // التأكد من أن الملف موجود فعلاً
        final fileExists = await File(image.path).exists();
        if (fileExists) {
          // التأكد من أن الملف ليس فارغاً
          final fileSize = await File(image.path).length();
          if (fileSize > 0) {
            return image.path;
          } else {
            Get.snackbar(
              AppLocalizations.of(Get.context!).error,
              AppLocalizations.of(Get.context!).invalidProjectData,
            );
            return null;
          }
        } else {
          Get.snackbar(
            AppLocalizations.of(Get.context!).error,
            AppLocalizations.of(Get.context!).failedToDeletePost,
          );
          return null;
        }
      } else {
        // المستخدم ألغى الاختيار
        return null;
      }
    } on Exception catch (e) {
      Get.snackbar(
        AppLocalizations.of(Get.context!).error,
        '${AppLocalizations.of(Get.context!).failedToChangeLikeStatus}: ${e.toString()}',
      );
      return null;
    } catch (e) {
      Get.snackbar(
        AppLocalizations.of(Get.context!).error,
        '${AppLocalizations.of(Get.context!).errorOccurredWhileDeletingPost}: ${e.toString()}',
      );
      return null;
    }
  }

  /// الحصول على الاسم المختصر للمستخدم
  String getUserInitials() {
    if (currentUser.value == null) return '';
    final names = currentUser.value!.name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return currentUser.value!.name[0].toUpperCase();
  }

  /// Toggle like on a worker's project.
  /// Returns true on success and updates local user state when appropriate.
  Future<bool> toggleLikeOnProject({
    required String workerUserId,
    required String projectId,
  }) async {
    try {
      print('AuthController: Toggling like for project $projectId on user $workerUserId');

      if (currentUser.value == null) {
        print('AuthController: No current user found');
        return false;
      }
      final likerId = currentUser.value!.id;
      print('AuthController: Current user ID: $likerId');

      final updatedProfile = await WorkerProfileService.toggleLikeOnProject(
        workerUserId: workerUserId,
        projectId: projectId,
        likerUserId: likerId,
      );

      if (updatedProfile == null) {
        print('AuthController: Failed to toggle like on project service');
        return false;
      }

      print('AuthController: Successfully toggled like, updating user data');

      // If the currently loaded user is the worker whose profile was updated, refresh it locally
      if (currentUser.value!.id == workerUserId) {
        print('AuthController: Current user is the worker, updating local user data');
        final newUser = currentUser.value!.copyWith(workerProfile: updatedProfile);
        currentUser.value = newUser;
        // persist the user record as well so UI across app stays consistent
        await UserService.updateUser(newUser);
      }

      // Also update the user in the all users list
      print('AuthController: Updating all users list');
      final allUsers = await UserService.getAllUsers();
      final userIndex = allUsers.indexWhere((u) => u.id == workerUserId);
      if (userIndex != -1) {
        print('AuthController: Found user in all users list, updating');
        final updatedUser = allUsers[userIndex].copyWith(workerProfile: updatedProfile);
        await UserService.saveUserToAllUsersList(updatedUser);
      } else {
        print('AuthController: User not found in all users list');
      }

      // Notify that a like has been updated
      notifyLikeUpdated();

      print('AuthController: Like toggle completed successfully');
      return true;
    } catch (e) {
      print('AuthController: Error toggling like: $e');
      Get.snackbar(
        AppLocalizations.of(Get.context!).error,
        '${AppLocalizations.of(Get.context!).failedToChangeLikeStatus}: $e',
      );
      return false;
    }
  }

  /// Notify that a new post has been added
  void notifyPostAdded() {
    print(
      'AuthController: Notifying post added. Current trigger value: ${postUpdateTrigger.value}',
    );
    // Increment the trigger to notify listeners
    postUpdateTrigger.value++;
    print(
      'AuthController: Post added notification sent. New trigger value: ${postUpdateTrigger.value}',
    );
  }

  /// Notify that a like has been updated
  void notifyLikeUpdated() {
    print(
      'AuthController: Notifying like updated. Current trigger value: ${likeUpdateTrigger.value}',
    );
    // Increment the trigger to notify listeners
    likeUpdateTrigger.value++;
    print(
      'AuthController: Like updated notification sent. New trigger value: ${likeUpdateTrigger.value}',
    );
  }
}

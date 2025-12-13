/// WorkerProfileService - إدارة حفظ واسترجاع ملفات العاملين محلياً
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/worker_profile_model.dart';
import '../../posts/models/project_model.dart';

class WorkerProfileService {
  // نستخدم مفتاحاً مميزاً لكل ملف عامل: worker_profile_<userId>
  static String _keyFor(String userId) => 'worker_profile_$userId';

  /// حفظ ملف العامل
  static Future<bool> saveProfile(WorkerProfile profile) async {
    try {
      // Validate the profile before saving
      if (!profile.isValid()) {
        print('Invalid WorkerProfile data');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(profile.toMap());
      return await prefs.setString(_keyFor(profile.userId), json);
    } catch (e) {
      print('${'error'.tr} saving WorkerProfile: $e');
      return false;
    }
  }

  /// استرجاع ملف العامل بحسب userId
  static Future<WorkerProfile?> getProfileByUserId(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_keyFor(userId));
      if (json == null) return null;
      final map = jsonDecode(json);
      return WorkerProfile.fromMap(Map<String, dynamic>.from(map));
    } catch (e) {
      print('${'error'.tr} retrieving WorkerProfile: $e');
      return null;
    }
  }

  /// Toggle like for a project belonging to a worker.
  /// Returns the updated WorkerProfile or null on failure.
  static Future<WorkerProfile?> toggleLikeOnProject({
    required String workerUserId,
    required String projectId,
    required String likerUserId,
  }) async {
    try {
      print(
        'WorkerProfileService: Toggling like for project $projectId on user $workerUserId by user $likerUserId',
      );

      final profile = await getProfileByUserId(workerUserId);
      if (profile == null) {
        print('WorkerProfileService: Profile not found for user $workerUserId');
        return null;
      }

      final projects = List<Project>.from(profile.projects);
      final idx = projects.indexWhere((p) => p.id == projectId);
      if (idx == -1) {
        print('WorkerProfileService: Project $projectId not found in user profile');
        return null;
      }

      final proj = projects[idx];
      final likedBy = List<String>.from(proj.likedBy);

      print('WorkerProfileService: Project currently has ${likedBy.length} likes');

      if (likedBy.contains(likerUserId)) {
        // unlike
        print('WorkerProfileService: Removing like from user $likerUserId');
        likedBy.remove(likerUserId);
      } else {
        print('WorkerProfileService: Adding like from user $likerUserId');
        likedBy.add(likerUserId);
      }

      // Update both the likedBy list and the likes count
      final updatedProj = proj.copyWith(likes: likedBy.length, likedBy: likedBy);
      projects[idx] = updatedProj;

      print('WorkerProfileService: Project now has ${likedBy.length} likes');

      final updatedProfile = profile.copyWith(projects: projects);
      final saved = await saveProfile(updatedProfile);
      if (!saved) {
        print('WorkerProfileService: Failed to save updated profile');
        return null;
      }

      print('WorkerProfileService: Successfully updated profile with new like count');
      return updatedProfile;
    } catch (e) {
      print('${'error'.tr} toggling like on project: $e');
      return null;
    }
  }

  /// تحديث ملف العامل (كافئ لحفظ)
  static Future<bool> updateProfile(
    WorkerProfile profile, {
    required String requesterUserId,
  }) async {
    // Validate the profile before updating
    if (!profile.isValid()) {
      print('Invalid WorkerProfile data');
      return false;
    }

    // أمان بسيط: تأكد أن من يطلب التحديث هو صاحب الملف
    if (profile.userId != requesterUserId) {
      print('محاولة تحديث غير مصرح بها لملف عامل (userId mismatch)');
      return false;
    }
    return saveProfile(profile);
  }

  /// حذف ملف العامل
  static Future<bool> deleteProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyFor(userId));
    } catch (e) {
      print('${'error'.tr} deleting WorkerProfile: $e');
      return false;
    }
  }
}


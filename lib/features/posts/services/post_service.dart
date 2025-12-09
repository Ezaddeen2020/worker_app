import 'package:get/get.dart';
import '../models/project_model.dart';
import '../../workers/models/worker_profile_model.dart';
import '../../profile/services/user_service.dart';
import '../../workers/services/worker_profile_service.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import '../models/project_with_user.dart';
import '../../comments/services/comment_local_service.dart';

class PostService extends GetxService {
  // Observable list of all posts
  final RxList<Project> allPosts = <Project>[].obs;

  // Observable map to track like states for efficient updates
  final RxMap<String, bool> likeStates = <String, bool>{}.obs;

  // Observable map to track like counts
  final RxMap<String, int> likeCounts = <String, int>{}.obs;

  // Observable map to track comment counts
  final RxMap<String, int> commentCounts = <String, int>{}.obs;

  // Trigger for forcing UI updates
  final RxInt updateTrigger = 0.obs;

  // Feed-ready list of posts coupled with their owners
  final RxList<ProjectWithUser> feedPosts = <ProjectWithUser>[].obs;

  // Loading flag for the feed
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllPosts();
  }

  /// Force UI update
  void notifyListeners() {
    updateTrigger.value++;
  }

  /// Load all posts from all users
  Future<void> loadAllPosts() async {
    isLoading.value = true;
    try {
      final users = await UserService.getAllUsers();
      final posts = <Project>[];
      final postsWithUsers = <ProjectWithUser>[];

      for (final user in users) {
        if (user.workerProfile?.projects != null) {
          for (final project in user.workerProfile!.projects) {
            posts.add(project);
            postsWithUsers.add(ProjectWithUser(project: project, user: user));
          }
        }
      }

      // Sort by creation date (newest first)
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      postsWithUsers.sort((a, b) => b.project.createdAt.compareTo(a.project.createdAt));

      allPosts.assignAll(posts);
      feedPosts.assignAll(postsWithUsers);
      if (posts.isEmpty) {
        commentCounts.clear();
        commentCounts.refresh();
      } else {
        await _refreshCommentCounts(posts);
      }
      _initializeLikeStates();
      notifyListeners();
    } catch (e) {
      print('PostService: Error loading posts: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Initialize like states and counts for all posts
  void _initializeLikeStates() {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      // Initialize like states for all posts
      for (final post in allPosts) {
        final likedBy = post.likedBy;
        final isLiked = currentUser != null && likedBy.contains(currentUser.id);
        likeStates[post.id] = isLiked;
        likeCounts[post.id] = likedBy.length;
      }
    } catch (e) {
      print('PostService: Error initializing like states: $e');
    }
  }

  /// Re-initialize like states (call after user login/logout)
  void refreshLikeStates() {
    _initializeLikeStates();
    notifyListeners();
  }

  /// Update like state for a specific project
  void updateLikeState(String projectId, bool isLiked, int likeCount) {
    likeStates[projectId] = isLiked;
    likeCounts[projectId] = likeCount;
    notifyListeners();
  }

  /// Toggle like on a project
  Future<bool> toggleLike(String workerUserId, String projectId) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      if (currentUser == null) return false;

      // Get current state before toggling
      final wasLiked = likeStates[projectId] ?? false;
      final currentCount = likeCounts[projectId] ?? 0;

      // Optimistic update - update UI immediately
      likeStates[projectId] = !wasLiked;
      likeCounts[projectId] = wasLiked ? currentCount - 1 : currentCount + 1;
      notifyListeners();

      WorkerProfile? updatedProfile = await WorkerProfileService.toggleLikeOnProject(
        workerUserId: workerUserId,
        projectId: projectId,
        likerUserId: currentUser.id,
      );

      if (updatedProfile == null) {
        final fallbackUser =
            await UserService.getUserById(workerUserId) ??
            (workerUserId == currentUser.id ? authController.currentUser.value : null);

        if (fallbackUser?.workerProfile != null) {
          final persisted = await WorkerProfileService.saveProfile(fallbackUser!.workerProfile!);
          if (persisted) {
            updatedProfile = await WorkerProfileService.toggleLikeOnProject(
              workerUserId: workerUserId,
              projectId: projectId,
              likerUserId: currentUser.id,
            );
          }
        }
      }

      if (updatedProfile == null) {
        // Revert on failure
        likeStates[projectId] = wasLiked;
        likeCounts[projectId] = currentCount;
        notifyListeners();
        return false;
      }

      // Update the user data
      if (currentUser.id == workerUserId) {
        final newUser = currentUser.copyWith(workerProfile: updatedProfile);
        authController.currentUser.value = newUser;
        await UserService.updateUser(newUser);
        // Notify auth controller
        authController.notifyPostAdded();
      }

      // Update the user in the all users list
      final allUsers = await UserService.getAllUsers();
      final userIndex = allUsers.indexWhere((u) => u.id == workerUserId);
      if (userIndex != -1) {
        final updatedUser = allUsers[userIndex].copyWith(workerProfile: updatedProfile);
        await UserService.saveUserToAllUsersList(updatedUser);
      }

      // Update local allPosts list
      final projectIndex = allPosts.indexWhere((p) => p.id == projectId);
      if (projectIndex != -1) {
        final project = allPosts[projectIndex];
        final updatedLikedBy = List<String>.from(project.likedBy);
        if (wasLiked) {
          updatedLikedBy.remove(currentUser.id);
        } else {
          updatedLikedBy.add(currentUser.id);
        }
        final updatedProject = project.copyWith(
          likedBy: updatedLikedBy,
          likes: updatedLikedBy.length,
        );
        allPosts[projectIndex] = updatedProject;
        likeCounts[projectId] = updatedLikedBy.length;

        final feedIndex = feedPosts.indexWhere((entry) => entry.project.id == projectId);
        if (feedIndex != -1) {
          final entry = feedPosts[feedIndex];
          feedPosts[feedIndex] = entry.copyWith(project: updatedProject);
        }
      }

      return true;
    } catch (e) {
      print('PostService: Error toggling like: $e');
      return false;
    }
  }

  /// Add a new post
  Future<bool> addPost(Project project, String workerUserId) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      // Try to load the owning user from storage, fall back to the in-memory user.
      var user = await UserService.getUserById(workerUserId) ?? currentUser;
      if (user == null) {
        print('PostService: User $workerUserId not found when adding post ${project.id}');
        return false;
      }

      // Resolve the worker profile even if the stored snapshot is missing it.
      var workerProfile = user.workerProfile;
      workerProfile ??= await WorkerProfileService.getProfileByUserId(workerUserId);
      if (workerProfile == null && currentUser != null && currentUser.id == workerUserId) {
        workerProfile = currentUser.workerProfile;
      }

      // إذا لم يكن هناك workerProfile، ننشئ واحداً جديداً
      if (workerProfile == null) {
        print('PostService: Creating new worker profile for user $workerUserId');
        workerProfile = WorkerProfile(
          id: 'wp_${workerUserId}_${DateTime.now().millisecondsSinceEpoch}',
          userId: workerUserId,
          bio: '',
          projects: [],
        );
        // حفظ البروفايل الجديد
        await WorkerProfileService.saveProfile(workerProfile);
      }

      final updatedProjects = List<Project>.from(workerProfile.projects)..insert(0, project);
      final updatedProfile = workerProfile.copyWith(projects: updatedProjects);
      final updatedUser = user.copyWith(workerProfile: updatedProfile);

      var persisted = await UserService.updateUser(updatedUser);
      if (!persisted) {
        print(
          'PostService: UserService.updateUser failed for ${updatedUser.id}, attempting fallback save.',
        );
        persisted = await UserService.saveUserToAllUsersList(updatedUser);
        if (!persisted) {
          print(
            'PostService: Failed to persist user ${updatedUser.id} after fallback during addPost.',
          );
          return false;
        }
      }

      // Keep the standalone worker profile store in sync when possible.
      if (updatedProfile.isValid()) {
        await WorkerProfileService.saveProfile(updatedProfile);
      }

      // Update the in-memory auth controller state for instant UI feedback.
      if (currentUser != null && currentUser.id == workerUserId) {
        authController.currentUser.value = updatedUser;
      }

      // Update local caches used by the feed.
      allPosts.insert(0, project);
      feedPosts.insert(0, ProjectWithUser(project: project, user: updatedUser));
      likeStates[project.id] = false;
      likeCounts[project.id] = 0;
      commentCounts[project.id] = 0;
      commentCounts.refresh();

      notifyListeners();
      authController.notifyPostAdded();
      return true;
    } catch (e) {
      print('PostService: Error adding post: $e');
      return false;
    }
  }

  /// Delete a post
  Future<bool> deletePost(String projectId, String workerUserId) async {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser.value;

      // استخدام المستخدم من الذاكرة أولاً ثم من التخزين
      var user = (currentUser != null && currentUser.id == workerUserId)
          ? currentUser
          : await UserService.getUserById(workerUserId);

      if (user == null) {
        print('PostService: User $workerUserId not found when deleting post $projectId');
        return false;
      }

      // جلب workerProfile من الذاكرة أو التخزين
      var workerProfile = user.workerProfile;
      workerProfile ??= await WorkerProfileService.getProfileByUserId(workerUserId);

      if (workerProfile == null) {
        print('PostService: WorkerProfile not found for user $workerUserId');
        return false;
      }

      // التحقق من وجود المنشور
      final projectExists = workerProfile.projects.any((p) => p.id == projectId);
      if (!projectExists) {
        print('PostService: Project $projectId not found in workerProfile');
        // حذف من القوائم المحلية على أي حال
        allPosts.removeWhere((project) => project.id == projectId);
        feedPosts.removeWhere((entry) => entry.project.id == projectId);
        likeStates.remove(projectId);
        likeCounts.remove(projectId);
        commentCounts.remove(projectId);
        notifyListeners();
        authController.notifyPostAdded();
        return true;
      }

      final updatedProjects = List<Project>.from(workerProfile.projects)
        ..removeWhere((project) => project.id == projectId);

      final updatedProfile = workerProfile.copyWith(projects: updatedProjects);
      final updatedUser = user.copyWith(workerProfile: updatedProfile);

      // حفظ في التخزين
      var success = await UserService.updateUser(updatedUser);
      if (!success) {
        success = await UserService.saveUserToAllUsersList(updatedUser);
      }

      // حفظ البروفايل أيضاً
      await WorkerProfileService.saveProfile(updatedProfile);

      // تحديث الذاكرة
      if (currentUser != null && currentUser.id == workerUserId) {
        authController.currentUser.value = updatedUser;
      }

      // حذف من القوائم المحلية
      allPosts.removeWhere((project) => project.id == projectId);
      feedPosts.removeWhere((entry) => entry.project.id == projectId);
      likeStates.remove(projectId);
      likeCounts.remove(projectId);
      commentCounts.remove(projectId);
      commentCounts.refresh();

      notifyListeners();
      authController.notifyPostAdded();

      print('PostService: Successfully deleted post $projectId');
      return true;
    } catch (e) {
      print('PostService: Error deleting post: $e');
      return false;
    }
  }

  /// Get like state for a project
  bool isLiked(String projectId) {
    return likeStates[projectId] ?? false;
  }

  /// Get like count for a project
  int getLikeCount(String projectId) {
    return likeCounts[projectId] ?? 0;
  }

  /// Get comment count for a project
  int getCommentCount(String projectId) {
    return commentCounts[projectId] ?? 0;
  }

  /// Refresh comment count for a specific project
  Future<void> refreshCommentCount(String projectId) async {
    try {
      final count = await CommentLocalService.getCommentsCount(projectId);
      commentCounts[projectId] = count;
      commentCounts.refresh();
      notifyListeners();
    } catch (e) {
      print('PostService: Error refreshing comment count for $projectId: $e');
    }
  }

  Future<void> _refreshCommentCounts(List<Project> projects) async {
    try {
      final projectIds = projects.map((project) => project.id).toSet();
      commentCounts.removeWhere((key, value) => !projectIds.contains(key));

      for (final projectId in projectIds) {
        final count = await CommentLocalService.getCommentsCount(projectId);
        commentCounts[projectId] = count;
      }
      commentCounts.refresh();
      notifyListeners();
    } catch (e) {
      print('PostService: Error loading comment counts: $e');
    }
  }
}

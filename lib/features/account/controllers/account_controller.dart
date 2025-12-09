import 'package:get/get.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';

class AccountController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  // Observable states
  final RxInt currentTabIndex = 0.obs;
  final RxBool isLoading = false.obs;

  // Getters
  bool get isLoggedIn => _authController.isUserLoggedIn.value;
  dynamic get currentUser => _authController.currentUser.value;

  bool get isWorker {
    final user = currentUser;
    if (user == null) return false;
    final role = (user.role ?? '').toString().toLowerCase();
    return role == 'worker' || user.workerProfile != null;
  }

  int get postsCount {
    final user = currentUser;
    return user?.workerProfile?.projects?.length ?? 0;
  }

  double get rating {
    final user = currentUser;
    return user?.workerProfile?.rating ?? 0;
  }

  List<dynamic> get projects {
    final user = currentUser;
    return user?.workerProfile?.projects ?? [];
  }

  // Methods
  void changeTab(int index) {
    currentTabIndex.value = index;
  }

  Future<void> refreshProfile() async {
    isLoading.value = true;
    try {
      // Trigger UI update
      _authController.notifyPostAdded();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authController.logout();
  }

  void notifyPostAdded() {
    _authController.notifyPostAdded();
  }
}

import 'package:get/get.dart';
import '../features/settings/controllers/theme_controller.dart';
import 'package:workers/features/auth/controller/auth_controller.dart';
import '../features/home/controllers/home_config_controller.dart';
import '../features/workers/controllers/worker_controller.dart';
import '../features/posts/services/post_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ThemeController>()) {
      Get.put<ThemeController>(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
    if (!Get.isRegistered<HomeConfigController>()) {
      Get.put<HomeConfigController>(HomeConfigController(), permanent: true);
    }
    if (!Get.isRegistered<PostService>()) {
      Get.put<PostService>(PostService(), permanent: true);
    }
    if (!Get.isRegistered<WorkerController>()) {
      Get.lazyPut<WorkerController>(() => WorkerController(), fenix: true);
    }
  }
}

import 'package:get/get.dart';
import 'package:workers/features/workers/controllers/worker_controller.dart';
import 'package:workers/features/home/controllers/home_config_controller.dart';

class HomeController extends GetxController {
  late final WorkerController workerController;
  late final HomeConfigController configController;

  // Observable states
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    workerController = Get.find<WorkerController>();
    configController = Get.find<HomeConfigController>();
  }

  // Methods
  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToHome() => currentIndex.value = 0;
  void goToFavorites() => currentIndex.value = 1;
  void goToPosts() => currentIndex.value = 2;
  void goToAccount() => currentIndex.value = 3;
}

import 'package:get/get.dart' hide Worker;
import 'package:url_launcher/url_launcher.dart';
import '../models/worker_model.dart';
import '../services/worker_service.dart';

class WorkerController extends GetxController {
  // ============== Observable Variables ==============
  final RxList<Worker> workers = <Worker>[].obs;
  final RxList<Worker> filteredWorkers = <Worker>[].obs;
  final RxString selectedCategory = 'all'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  /// التخصصات المتاحة - مفاتيح ثابتة يتم تحويلها للترجمة عند العرض
  static const List<String> categoryKeys = [
    'all',
    'electrician',
    'carpenter',
    'blacksmith',
    'plumber',
    'painter',
    'construction',
    'airConditioning',
    'mechanic',
  ];

  /// الحصول على اسم التصنيف المترجم
  String getCategoryDisplayName(String key) {
    switch (key) {
      case 'all':
        return 'all'.tr;
      case 'electrician':
        return 'electrician'.tr;
      case 'carpenter':
        return 'carpenter'.tr;
      case 'blacksmith':
        return 'blacksmith'.tr;
      case 'plumber':
        return 'plumber'.tr;
      case 'painter':
        return 'painter'.tr;
      case 'construction':
        return 'construction'.tr;
      case 'airConditioning':
        return 'airConditioning'.tr;
      case 'mechanic':
        return 'mechanic'.tr;
      default:
        return key;
    }
  }

  // ============== Lifecycle ==============
  @override
  void onInit() {
    super.onInit();
    loadAllWorkers();
  }

  // ============== Main Methods ==============

  /// تحميل جميع العمال من الخدمة
  Future<void> loadAllWorkers() async {
    try {
      isLoading.value = true;
      final workersList = await WorkerService.fetchWorkers();
      workers.assignAll(workersList);
      filteredWorkers.assignAll(workersList);
    } catch (e) {
      Get.snackbar('error'.tr, 'فشل تحميل البيانات: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// البحث عن عمال حسب الاسم/المدينة/التخصص
  void searchWorkers(String query) {
    searchQuery.value = query;
    _applyFilters();
  }

  /// تصفية العمال حسب التخصص
  void filterByCategory(String category) {
    selectedCategory.value = category;
    _applyFilters();
  }

  /// تطبيق جميع المرشحات (البحث + التخصص)
  void _applyFilters() {
    List<Worker> result = List<Worker>.from(workers);

    // تطبيق البحث
    if (searchQuery.isNotEmpty) {
      result = WorkerService.searchWorkers(result, searchQuery.value);
    }

    // تطبيق التصفية حسب التخصص
    result = WorkerService.filterByCategory(result, selectedCategory.value);

    filteredWorkers.assignAll(result);
  }

  /// الحصول على أفضل العمال
  List<Worker> getTopWorkers({int limit = 5}) {
    return WorkerService.getTopWorkers(List<Worker>.from(workers), limit: limit);
  }

  /// تبديل حالة المتابعة (Follow/Unfollow)
  void toggleFollow(Worker worker) {
    final index = workers.indexWhere((w) => w.id == worker.id);
    if (index != -1) {
      workers[index] = worker.copyWith(isFollowing: !worker.isFollowing);
      _applyFilters();
    }
  }

  /// فتح WhatsApp للتواصل
  Future<void> openWhatsApp(String phone) async {
    try {
      final whatsappUrl = 'https://wa.me/$phone';
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('error'.tr, 'failedToDeletePost'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'failedToDeletePost'.tr}: $e');
    }
  }

  /// إجراء مكالمة هاتفية
  Future<void> makePhoneCall(String phone) async {
    try {
      final phoneUrl = 'tel:$phone';
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        Get.snackbar('error'.tr, 'failedToDeletePost'.tr);
      }
    } catch (e) {
      Get.snackbar('error'.tr, '${'errorOccurredWhileDeletingPost'.tr}: $e');
    }
  }

  /// الحصول على عامل من خلال ID
  Worker? getWorkerById(String id) {
    try {
      return workers.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  /// مسح البحث والمرشحات
  void clearFilters() {
    searchQuery.value = '';
    selectedCategory.value = 'all';
    filteredWorkers.assignAll(workers);
  }
}

import 'package:get/get.dart' hide Worker;
import 'package:url_launcher/url_launcher.dart';
import 'package:workers/core/localization/localization_delegate.dart';
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
    if (Get.context == null) return key;
    final loc = AppLocalizations.of(Get.context!);
    switch (key) {
      case 'all':
        return loc.all;
      case 'electrician':
        return loc.electrician;
      case 'carpenter':
        return loc.carpenter;
      case 'blacksmith':
        return loc.blacksmith;
      case 'plumber':
        return loc.plumber;
      case 'painter':
        return loc.painter;
      case 'construction':
        return loc.construction;
      case 'airConditioning':
        return loc.airConditioning;
      case 'mechanic':
        return loc.mechanic;
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
      Get.snackbar(AppLocalizations.of(Get.context!).error, 'فشل تحميل البيانات: $e');
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
        Get.snackbar(
          AppLocalizations.of(Get.context!).error,
          AppLocalizations.of(Get.context!).failedToDeletePost,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppLocalizations.of(Get.context!).error,
        '${AppLocalizations.of(Get.context!).failedToDeletePost}: $e',
      );
    }
  }

  /// إجراء مكالمة هاتفية
  Future<void> makePhoneCall(String phone) async {
    try {
      final phoneUrl = 'tel:$phone';
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        Get.snackbar(
          AppLocalizations.of(Get.context!).error,
          AppLocalizations.of(Get.context!).failedToDeletePost,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppLocalizations.of(Get.context!).error,
        '${AppLocalizations.of(Get.context!).errorOccurredWhileDeletingPost}: $e',
      );
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

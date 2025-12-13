import 'package:get/get.dart';
import '../models/home_config_model.dart';
import '../services/home_config_service.dart';

/// Home Configuration Controller - متحكم إعدادات الصفحة الرئيسية
class HomeConfigController extends GetxController {
  final Rx<HomeConfig> _config = HomeConfigService.getDefaultConfig().obs;
  HomeConfig get config => _config.value;

  @override
  void onInit() {
    super.onInit();
    _loadConfig();
  }

  /// تحميل الإعدادات
  Future<void> _loadConfig() async {
    try {
      final loadedConfig = await HomeConfigService.loadConfig();
      _config.value = loadedConfig;
    } catch (e) {
      print('Error loading config: $e');
      // Use default config if loading fails
      _config.value = HomeConfigService.getDefaultConfig();
    }
  }

  /// حفظ الإعدادات
  Future<void> saveConfig(HomeConfig newConfig) async {
    try {
      // Validate the config before saving
      if (!newConfig.isValid()) {
        Get.snackbar(
          'error'.tr,
          'invalidProjectData'.tr,
        );
        return;
      }

      await HomeConfigService.saveConfig(newConfig);
      _config.value = newConfig;
    } catch (e) {
      print('Error saving config: $e');
      Get.snackbar(
        'error'.tr,
        'failedToAddPost'.tr,
      );
    }
  }

  /// تحديث عنوان الرأسية
  void updateHeaderTitle(String title) {
    final updatedConfig = config.copyWith(headerTitle: title);
    _config.value = updatedConfig;
  }

  /// تحديث العنوان الفرعي للرأسية
  void updateHeaderSubtitle(String subtitle) {
    final updatedConfig = config.copyWith(headerSubtitle: subtitle);
    _config.value = updatedConfig;
  }

  /// تحديث نص البحث
  void updateSearchHint(String hint) {
    final updatedConfig = config.copyWith(searchHint: hint);
    _config.value = updatedConfig;
  }

  /// تحديث عنوان العمال المميزين
  void updateFeaturedWorkersTitle(String title) {
    final updatedConfig = config.copyWith(featuredWorkersTitle: title);
    _config.value = updatedConfig;
  }

  /// تحديث عنوان التصنيفات
  void updateCategoriesTitle(String title) {
    final updatedConfig = config.copyWith(categoriesTitle: title);
    _config.value = updatedConfig;
  }

  /// تحديث عنوان جميع العمال
  void updateAllWorkersTitle(String title) {
    final updatedConfig = config.copyWith(allWorkersTitle: title);
    _config.value = updatedConfig;
  }

  /// تحديث رسالة عدم وجود نتائج
  void updateEmptyResultsMessage(String message) {
    final updatedConfig = config.copyWith(emptyResultsMessage: message);
    _config.value = updatedConfig;
  }

  /// تحديث ألوان الثيم
  void updateThemeColors(List<ColorConfig> colors) {
    final updatedConfig = config.copyWith(themeColors: colors);
    _config.value = updatedConfig;
  }

  /// تحديث التصنيفات
  void updateCategories(List<CategoryConfig> categories) {
    final updatedConfig = config.copyWith(categories: categories);
    _config.value = updatedConfig;
  }

  /// إعادة تعيين الإعدادات الافتراضية
  Future<void> resetToDefault() async {
    final defaultConfig = HomeConfigService.getDefaultConfig();
    await saveConfig(defaultConfig);
  }
}


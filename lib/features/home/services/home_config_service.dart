import 'package:shared_preferences/shared_preferences.dart';
import '../models/home_config_model.dart';

/// Home Configuration Service - خدمة إعدادات الصفحة الرئيسية
class HomeConfigService {
  static const String _configKey = 'home_config';

  /// الحصول على الإعدادات الافتراضية
  static HomeConfig getDefaultConfig() {
    return HomeConfig(
      headerTitle: 'أهلاً وسهلاً',
      headerSubtitle: 'مرحباً بك في تطبيق العمال والحرفيين',
      searchHint: 'ابحث عن عامل  ...',
      featuredWorkersTitle: 'العمال المميزين',
      categoriesTitle: 'اختر من التخصصات',
      allWorkersTitle: 'جميع العمال والحرفيين',
      emptyResultsMessage: 'لا توجد نتائج',
      themeColors: [
        ColorConfig(
          name: 'default',
          primaryColor: 0xFF055F42, // Color.fromARGB(255, 5, 95, 66)
          secondaryColor: 0xFF0A9664, // Color.fromARGB(255, 10, 150, 100)
          accentColor: 0xFFFB923C, // Orange accent
        ),
      ],
      categories: [
        CategoryConfig(name: 'الكل', displayName: 'الكل', icon: 'all'),
        CategoryConfig(name: 'كهربائي', displayName: 'كهربائي', icon: 'electrician'),
        CategoryConfig(name: 'نجار', displayName: 'نجار', icon: 'carpenter'),
        CategoryConfig(name: 'حداد', displayName: 'حداد', icon: 'blacksmith'),
        CategoryConfig(name: 'سباك', displayName: 'سباك', icon: 'plumber'),
        CategoryConfig(name: 'دهان', displayName: 'دهان', icon: 'painter'),
        CategoryConfig(name: 'بناء', displayName: 'بناء', icon: 'builder'),
        CategoryConfig(name: 'تكييف', displayName: 'تكييف', icon: 'ac'),
        CategoryConfig(name: 'ميكانيكي', displayName: 'ميكانيكي', icon: 'mechanic'),
      ],
    );
  }

  /// تحميل الإعدادات من التخزين المحلي
  static Future<HomeConfig> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configString = prefs.getString(_configKey);

      if (configString != null) {
        return HomeConfig.fromJson(configString);
      }
    } catch (e) {
      // If there's an error loading the config, return default
      print('Error loading home config: $e');
    }

    return getDefaultConfig();
  }

  /// حفظ الإعدادات في التخزين المحلي
  static Future<void> saveConfig(HomeConfig config) async {
    try {
      // Validate the config before saving
      if (!config.isValid()) {
        print('Invalid HomeConfig data');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final configString = config.toJson();
      await prefs.setString(_configKey, configString);
    } catch (e) {
      print('Error saving home config: $e');
    }
  }

  /// تحديث إعدادات التصنيفات
  static HomeConfig updateCategories(HomeConfig config, List<String> newCategories) {
    final updatedCategories = <CategoryConfig>[
      CategoryConfig(name: 'الكل', displayName: 'الكل', icon: 'all'),
      ...newCategories.map(
        (cat) => CategoryConfig(name: cat, displayName: cat, icon: _getIconForCategory(cat)),
      ),
    ];

    return config.copyWith(categories: updatedCategories);
  }

  /// الحصول على أيقونة التصنيف
  static String _getIconForCategory(String category) {
    final categoryIcons = {
      'كهربائي': 'electrician',
      'نجار': 'carpenter',
      'حداد': 'blacksmith',
      'سباك': 'plumber',
      'دهان': 'painter',
      'بناء': 'builder',
      'تكييف': 'ac',
      'ميكانيكي': 'mechanic',
    };

    return categoryIcons[category] ?? 'worker';
  }
}

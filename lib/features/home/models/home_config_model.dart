// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// Home Page Configuration Model - نموذج إعدادات الصفحة الرئيسية
class HomeConfig {
  final String headerTitle;
  final String headerSubtitle;
  final String searchHint;
  final String featuredWorkersTitle;
  final String categoriesTitle;
  final String allWorkersTitle;
  final String emptyResultsMessage;
  final List<ColorConfig> themeColors;
  final List<CategoryConfig> categories;

  HomeConfig({
    required this.headerTitle,
    required this.headerSubtitle,
    required this.searchHint,
    required this.featuredWorkersTitle,
    required this.categoriesTitle,
    required this.allWorkersTitle,
    required this.emptyResultsMessage,
    required this.themeColors,
    required this.categories,
  });

  HomeConfig copyWith({
    String? headerTitle,
    String? headerSubtitle,
    String? searchHint,
    String? featuredWorkersTitle,
    String? categoriesTitle,
    String? allWorkersTitle,
    String? emptyResultsMessage,
    List<ColorConfig>? themeColors,
    List<CategoryConfig>? categories,
  }) {
    return HomeConfig(
      headerTitle: headerTitle ?? this.headerTitle,
      headerSubtitle: headerSubtitle ?? this.headerSubtitle,
      searchHint: searchHint ?? this.searchHint,
      featuredWorkersTitle: featuredWorkersTitle ?? this.featuredWorkersTitle,
      categoriesTitle: categoriesTitle ?? this.categoriesTitle,
      allWorkersTitle: allWorkersTitle ?? this.allWorkersTitle,
      emptyResultsMessage: emptyResultsMessage ?? this.emptyResultsMessage,
      themeColors: themeColors ?? this.themeColors,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'headerTitle': headerTitle,
      'headerSubtitle': headerSubtitle,
      'searchHint': searchHint,
      'featuredWorkersTitle': featuredWorkersTitle,
      'categoriesTitle': categoriesTitle,
      'allWorkersTitle': allWorkersTitle,
      'emptyResultsMessage': emptyResultsMessage,
      'themeColors': themeColors.map((x) => x.toMap()).toList(),
      'categories': categories.map((x) => x.toMap()).toList(),
    };
  }

  factory HomeConfig.fromMap(Map<String, dynamic> map) {
    return HomeConfig(
      headerTitle: map['headerTitle'] as String,
      headerSubtitle: map['headerSubtitle'] as String,
      searchHint: map['searchHint'] as String,
      featuredWorkersTitle: map['featuredWorkersTitle'] as String,
      categoriesTitle: map['categoriesTitle'] as String,
      allWorkersTitle: map['allWorkersTitle'] as String,
      emptyResultsMessage: map['emptyResultsMessage'] as String,
      themeColors: List<ColorConfig>.from(
        (map['themeColors'] as List<dynamic>).map<ColorConfig>(
          (x) => ColorConfig.fromMap(x as Map<String, dynamic>),
        ),
      ),
      categories: List<CategoryConfig>.from(
        (map['categories'] as List<dynamic>).map<CategoryConfig>(
          (x) => CategoryConfig.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory HomeConfig.fromJson(String source) =>
      HomeConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  /// التحقق من صحة نموذج إعدادات الصفحة الرئيسية
  bool isValid() {
    if (headerTitle.isEmpty) return false;
    if (headerSubtitle.isEmpty) return false;
    if (searchHint.isEmpty) return false;
    if (featuredWorkersTitle.isEmpty) return false;
    if (categoriesTitle.isEmpty) return false;
    if (allWorkersTitle.isEmpty) return false;
    if (emptyResultsMessage.isEmpty) return false;
    if (themeColors.isEmpty) return false;
    if (categories.isEmpty) return false;
    return true;
  }

  /// التحقق من صحة البيانات وإرجاع جميع الأخطاء
  List<String> validate() {
    final errors = <String>[];

    if (headerTitle.isEmpty) errors.add('عنوان الرأسية مطلوب');
    if (headerSubtitle.isEmpty) errors.add('العنوان الفرعي للرأسية مطلوب');
    if (searchHint.isEmpty) errors.add('نص البحث مطلوب');
    if (featuredWorkersTitle.isEmpty) errors.add('عنوان العمال المميزين مطلوب');
    if (categoriesTitle.isEmpty) errors.add('عنوان التصنيفات مطلوب');
    if (allWorkersTitle.isEmpty) errors.add('عنوان جميع العمال مطلوب');
    if (emptyResultsMessage.isEmpty) errors.add('رسالة عدم وجود نتائج مطلوبة');
    if (themeColors.isEmpty) errors.add('ألوان الثيم مطلوبة');
    if (categories.isEmpty) errors.add('التصنيفات مطلوبة');

    return errors;
  }

  @override
  String toString() {
    return 'HomeConfig(headerTitle: $headerTitle, headerSubtitle: $headerSubtitle, '
        'searchHint: $searchHint, featuredWorkersTitle: $featuredWorkersTitle, '
        'categoriesTitle: $categoriesTitle, allWorkersTitle: $allWorkersTitle, '
        'emptyResultsMessage: $emptyResultsMessage, themeColors: $themeColors, categories: $categories)';
  }
}

/// Color Configuration Model - نموذج إعدادات الألوان
class ColorConfig {
  final String name;
  final int primaryColor;
  final int secondaryColor;
  final int accentColor;

  ColorConfig({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  ColorConfig copyWith({String? name, int? primaryColor, int? secondaryColor, int? accentColor}) {
    return ColorConfig(
      name: name ?? this.name,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
    };
  }

  factory ColorConfig.fromMap(Map<String, dynamic> map) {
    return ColorConfig(
      name: map['name'] as String,
      primaryColor: map['primaryColor'] as int,
      secondaryColor: map['secondaryColor'] as int,
      accentColor: map['accentColor'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory ColorConfig.fromJson(String source) =>
      ColorConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  /// التحقق من صحة نموذج إعدادات الألوان
  bool isValid() {
    if (name.isEmpty) return false;
    return true;
  }

  /// التحقق من صحة البيانات وإرجاع جميع الأخطاء
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) errors.add('اسم اللون مطلوب');

    return errors;
  }

  @override
  String toString() {
    return 'ColorConfig(name: $name, primaryColor: $primaryColor, '
        'secondaryColor: $secondaryColor, accentColor: $accentColor)';
  }
}

/// Category Configuration Model - نموذج إعدادات التصنيفات
class CategoryConfig {
  final String name;
  final String displayName;
  final String icon;

  CategoryConfig({required this.name, required this.displayName, required this.icon});

  CategoryConfig copyWith({String? name, String? displayName, String? icon}) {
    return CategoryConfig(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'displayName': displayName, 'icon': icon};
  }

  factory CategoryConfig.fromMap(Map<String, dynamic> map) {
    return CategoryConfig(
      name: map['name'] as String,
      displayName: map['displayName'] as String,
      icon: map['icon'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryConfig.fromJson(String source) =>
      CategoryConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  /// التحقق من صحة نموذج إعدادات التصنيفات
  bool isValid() {
    if (name.isEmpty) return false;
    if (displayName.isEmpty) return false;
    if (icon.isEmpty) return false;
    return true;
  }

  /// التحقق من صحة البيانات وإرجاع جميع الأخطاء
  List<String> validate() {
    final errors = <String>[];

    if (name.isEmpty) errors.add('اسم التصنيف مطلوب');
    if (displayName.isEmpty) errors.add('اسم العرض للتصنيف مطلوب');
    if (icon.isEmpty) errors.add('الأيقونة للتصنيف مطلوبة');

    return errors;
  }

  @override
  String toString() => 'CategoryConfig(name: $name, displayName: $displayName, icon: $icon)';
}

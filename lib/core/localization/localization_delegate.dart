import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Singleton instance for fallback
  static AppLocalizations? _instance;

  // Helper method to get the current AppLocalizations instance
  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    if (localizations != null) {
      return localizations;
    }
    // إرجاع instance افتراضي إذا لم يتم العثور على الترجمة
    _instance ??= AppLocalizations(const Locale('ar'));
    return _instance!;
  }

  // Static map to hold our localized values
  static Map<String, dynamic> _localizedValues = {};

  // Load the localized values from the arb files
  Future<bool> load() async {
    try {
      String jsonStringValues = await rootBundle.loadString(
        'assets/language/app_${locale.languageCode}.arb',
      );
      Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
      _localizedValues = mappedJson.map((key, value) => MapEntry(key, value));
      return true;
    } catch (e) {
      // استخدام القيم الافتراضية إذا فشل تحميل الملف
      debugPrint('⚠️ Failed to load localization file: $e');
      _localizedValues = {};
      return true;
    }
  }

  // Getter methods for our localized strings
  String get appTitle => _localizedValues['appTitle'] ?? 'تطبيق العمال والحرفيين';
  String get splashScreenTitle => _localizedValues['splashScreenTitle'] ?? 'تطبيق العمال والحرفيين';
  String get splashScreenDescription =>
      _localizedValues['splashScreenDescription'] ?? 'ابحث عن أفضل الحرفيين والعمال في منطقتك';
  String get homePageTitle => _localizedValues['homePageTitle'] ?? 'الرئيسية';
  String get messagesPageTitle => _localizedValues['messagesPageTitle'] ?? 'الرسائل';
  String get favoritesPageTitle => _localizedValues['favoritesPageTitle'] ?? 'المفضلة';
  String get accountPageTitle => _localizedValues['accountPageTitle'] ?? 'الحساب';
  String get searchHint => _localizedValues['searchHint'] ?? 'ابحث عن حرفيين أو عمال...';
  String get featuredWorkersTitle => _localizedValues['featuredWorkersTitle'] ?? 'العمال المميزون';
  String get categoriesTitle => _localizedValues['categoriesTitle'] ?? 'التصنيفات';
  String get allWorkersTitle => _localizedValues['allWorkersTitle'] ?? 'جميع العمال';
  String get emptyResultsMessage =>
      _localizedValues['emptyResultsMessage'] ?? 'لم يتم العثور على نتائج';
  String get settingsPageTitle => _localizedValues['settingsPageTitle'] ?? 'الإعدادات';
  String get profilePageTitle => _localizedValues['profilePageTitle'] ?? 'الملف الشخصي';
  String get editProfile => _localizedValues['editProfile'] ?? 'تعديل الملف الشخصي';
  String get saveChanges => _localizedValues['saveChanges'] ?? 'حفظ التغييرات';
  String get cancel => _localizedValues['cancel'] ?? 'إلغاء';
  String get logout => _localizedValues['logout'] ?? 'تسجيل الخروج';
  String get logoutConfirmation =>
      _localizedValues['logoutConfirmation'] ?? 'هل أنت متأكد أنك تريد تسجيل الخروج؟';
  String get confirm => _localizedValues['confirm'] ?? 'تأكيد';
  String get helpAndSupport => _localizedValues['helpAndSupport'] ?? 'المساعدة والدعم';
  String get homeConfig => _localizedValues['homeConfig'] ?? 'إعدادات الصفحة الرئيسية';
  String get name => _localizedValues['name'] ?? 'الاسم';
  String get phone => _localizedValues['phone'] ?? 'رقم الهاتف';
  String get role => _localizedValues['role'] ?? 'الدور';
  String get worker => _localizedValues['worker'] ?? 'عامل';
  String get client => _localizedValues['client'] ?? 'عميل';
  String get services => _localizedValues['services'] ?? 'الخدمات';
  String get experience => _localizedValues['experience'] ?? 'الخبرة';
  String get rating => _localizedValues['rating'] ?? 'التقييم';
  String get reviews => _localizedValues['reviews'] ?? 'المراجعات';
  String get projects => _localizedValues['projects'] ?? 'المشاريع';
  String get addProject => _localizedValues['addProject'] ?? 'إضافة مشروع';
  String get projectTitle => _localizedValues['projectTitle'] ?? 'عنوان المشروع';
  String get projectDescription => _localizedValues['projectDescription'] ?? 'وصف المشروع';
  String get projectPrice => _localizedValues['projectPrice'] ?? 'سعر المشروع';
  String get like => _localizedValues['like'] ?? 'إعجاب';
  String get liked => _localizedValues['liked'] ?? 'معجب';
  String get share => _localizedValues['share'] ?? 'مشاركة';
  String get delete => _localizedValues['delete'] ?? 'حذف';
  String get edit => _localizedValues['edit'] ?? 'تعديل';
  String get noProjectsFound => _localizedValues['noProjectsFound'] ?? 'لم يتم العثور على مشاريع';
  String get noReviewsFound => _localizedValues['noReviewsFound'] ?? 'لم يتم العثور على مراجعات';
  String get writeReview => _localizedValues['writeReview'] ?? 'كتابة مراجعة';
  String get reviewTitle => _localizedValues['reviewTitle'] ?? 'عنوان المراجعة';
  String get reviewDescription => _localizedValues['reviewDescription'] ?? 'وصف المراجعة';
  String get submitReview => _localizedValues['submitReview'] ?? 'إرسال المراجعة';
  String get selectImage => _localizedValues['selectImage'] ?? 'اختر صورة';
  String get camera => _localizedValues['camera'] ?? 'الكاميرا';
  String get gallery => _localizedValues['gallery'] ?? 'المعرض';
  String get removeImage => _localizedValues['removeImage'] ?? 'إزالة الصورة';
  String get followers => _localizedValues['followers'] ?? 'المتابعون';
  String get yearsOfExperience => _localizedValues['yearsOfExperience'] ?? 'سنة خبرة';
  String get following => _localizedValues['following'] ?? 'متابع';
  String get follow => _localizedValues['follow'] ?? 'متابعة';
  String get message => _localizedValues['message'] ?? 'رسالة';
  String get aboutWorker => _localizedValues['aboutWorker'] ?? 'نبذة عن العامل';
  String get additionalInfo => _localizedValues['additionalInfo'] ?? 'معلومات إضافية';
  String get portfolio => _localizedValues['portfolio'] ?? 'معرض الأعمال';
  String get noWorksFound => _localizedValues['noWorksFound'] ?? 'لا توجد أعمال';
  // String get noReviewsFound => _localizedValues['noReviewsFound'] ?? 'لا توجد تقييمات بعد';
  String get beFirstToReview => _localizedValues['beFirstToReview'] ?? 'كن أول من يقيم هذا العامل';
  String get notLoggedIn => _localizedValues['notLoggedIn'] ?? 'لم تقم بتسجيل الدخول';
  String get createAccountToStart =>
      _localizedValues['createAccountToStart'] ?? 'قم بإنشاء حساب جديد للبدء';
  String get createNewAccount => _localizedValues['createNewAccount'] ?? 'إنشاء حساب جديد';
  String get editProfileDescription =>
      _localizedValues['editProfileDescription'] ?? 'عدّل معلومات ملفك الشخصي';
  String get homeConfigDescription =>
      _localizedValues['homeConfigDescription'] ?? 'تخصيص مظهر الصفحة الرئيسية';
  String get helpAndSupportDescription =>
      _localizedValues['helpAndSupportDescription'] ?? 'احصل على الدعم الفني';
  String get helpComingSoon => _localizedValues['helpComingSoon'] ?? 'صفحة المساعدة قريباً';
  String get logoutDescription => _localizedValues['logoutDescription'] ?? 'تسجيل الخروج من حسابك';
  String get addNewPost => _localizedValues['addNewPost'] ?? 'إضافة منشور جديد';
  String get completeProfileInfo =>
      _localizedValues['completeProfileInfo'] ?? 'أكمل بيانات ملفك الشخصي';
  String get error => _localizedValues['error'] ?? 'خطأ';
  String get selectProfileImage =>
      _localizedValues['selectProfileImage'] ?? 'الرجاء اختيار صورة للملف الشخصي';
  String get setupWorkerAccount => _localizedValues['setupWorkerAccount'] ?? 'إعداد حساب العامل';
  String get aboutYou => _localizedValues['aboutYou'] ?? 'نبذة عنك';
  String get writeBriefBio => _localizedValues['writeBriefBio'] ?? 'اكتب نبذة مختصرة عن خبراتك';
  String get servicesSeparatedByCommas =>
      _localizedValues['servicesSeparatedByCommas'] ?? 'الخدمات (فصلها بفواصل)';
  String get servicesExample =>
      _localizedValues['servicesExample'] ?? 'مثال: دهان, كهرباء, تمديدات';
  String get addInitialProject =>
      _localizedValues['addInitialProject'] ?? 'أضف مشروعًا أولياً (اختياري)';
  String get priceOptional => _localizedValues['priceOptional'] ?? 'السعر (اختياري)';
  String get saveAndComplete => _localizedValues['saveAndComplete'] ?? 'حفظ وإكمال';
  String get success => _localizedValues['success'] ?? 'نجاح';
  String get workerProfileCreatedSuccessfully =>
      _localizedValues['workerProfileCreatedSuccessfully'] ?? 'تم إنشاء ملف العامل بنجاح';
  String get failedToSaveWorkerProfile =>
      _localizedValues['failedToSaveWorkerProfile'] ?? 'فشل حفظ ملف العامل';
  String get posts => _localizedValues['posts'] ?? 'المنشورات';
  String get noPostsFound => _localizedValues['noPostsFound'] ?? 'لا توجد منشورات حالياً';
  String get deletePost => _localizedValues['deletePost'] ?? 'حذف المنشور';
  String get failedToChangeLikeStatus =>
      _localizedValues['failedToChangeLikeStatus'] ?? 'فشل تغيير حالة اللايك';
  String get confirmDelete => _localizedValues['confirmDelete'] ?? 'تأكيد الحذف';
  String get confirmDeletePost =>
      _localizedValues['confirmDeletePost'] ?? 'هل أنت متأكد من رغبتك في حذف هذا المنشور؟';
  String get info => _localizedValues['info'] ?? 'معلومة';
  String get commentFeatureComingSoon =>
      _localizedValues['commentFeatureComingSoon'] ?? 'ميزة التعليق قريباً';
  String get postDeletedSuccessfully =>
      _localizedValues['postDeletedSuccessfully'] ?? 'تم حذف المنشور بنجاح';
  String get failedToDeletePost => _localizedValues['failedToDeletePost'] ?? 'فشل في حذف المنشور';
  String get errorOccurredWhileDeletingPost =>
      _localizedValues['errorOccurredWhileDeletingPost'] ?? 'حدث خطأ أثناء حذف المنشور';
  String get days => _localizedValues['days'] ?? 'يوم';
  String get hours => _localizedValues['hours'] ?? 'ساعة';
  String get minutes => _localizedValues['minutes'] ?? 'دقيقة';
  String get now => _localizedValues['now'] ?? 'الآن';
  String get sar => _localizedValues['sar'] ?? 'ر.س';
  String get enterProjectTitle => _localizedValues['enterProjectTitle'] ?? 'أدخل عنوان المشروع';
  String get enterProjectDescription =>
      _localizedValues['enterProjectDescription'] ?? 'أدخل وصف المشروع';

  // New getters for missing translations
  String get postsPageTitle => _localizedValues['postsPageTitle'] ?? 'المنشورات';
  String get invalidProjectData =>
      _localizedValues['invalidProjectData'] ?? 'بيانات المشروع غير صالحة';
  String get warning => _localizedValues['warning'] ?? 'تحذير';
  String get accountCreatedButWorkerProfileNotSaved =>
      _localizedValues['accountCreatedButWorkerProfileNotSaved'] ??
      'تم إنشاء الحساب لكن لم يتم حفظ ملف العامل مؤقتاً';
  String get accountCreatedSuccessfully =>
      _localizedValues['accountCreatedSuccessfully'] ?? 'تم إنشاء الحساب بنجاح';
  String get failedToAddPost => _localizedValues['failedToAddPost'] ?? 'فشل إضافة المنشور';
  String get dataUpdatedSuccessfully =>
      _localizedValues['dataUpdatedSuccessfully'] ?? 'تم تحديث البيانات بنجاح';
  String get loggedOutSuccessfully =>
      _localizedValues['loggedOutSuccessfully'] ?? 'تم تسجيل الخروج';
  String get all => _localizedValues['all'] ?? 'الكل';
  String get carpenter => _localizedValues['carpenter'] ?? 'نجار';
  String get blacksmith => _localizedValues['blacksmith'] ?? 'حداد';
  String get plumber => _localizedValues['plumber'] ?? 'سباك';
  String get painter => _localizedValues['painter'] ?? 'دهان';
  String get airConditioning => _localizedValues['airConditioning'] ?? 'تكييف';
  String get mechanic => _localizedValues['mechanic'] ?? 'ميكانيكي';
  String get electrician => _localizedValues['electrician'] ?? 'كهربائي';
  String get construction => _localizedValues['construction'] ?? 'بناء';
  String get postAddedSuccessfully =>
      _localizedValues['postAddedSuccessfully'] ?? 'تم إضافة المنشور';

  // Additional missing translations
  String get user => _localizedValues['user'] ?? 'مستخدم';
  String get publish => _localizedValues['publish'] ?? 'نشر';
  String get tapToSelectImage => _localizedValues['tapToSelectImage'] ?? 'اضغط لاختيار صورة';
  String get tapToChangeImage => _localizedValues['tapToChangeImage'] ?? 'اضغط لتغيير الصورة';
  String get enterYourFullName => _localizedValues['enterYourFullName'] ?? 'أدخل اسمك الكامل';
  String get accountType => _localizedValues['accountType'] ?? 'نوع الحساب';
  String get phoneNumberPlaceholder => _localizedValues['phoneNumberPlaceholder'] ?? '05xxxxxxxx';
  String get createAccount => _localizedValues['createAccount'] ?? 'إنشاء حساب';
  String get importantInformation => _localizedValues['importantInformation'] ?? 'معلومات مهمة';
  String get mustEnterValidName => _localizedValues['mustEnterValidName'] ?? 'يجب إدخال اسم صحيح';
  String get phoneNumberMustBeValid =>
      _localizedValues['phoneNumberMustBeValid'] ?? 'رقم الهاتف يجب أن يكون صحيحاً';
  String get imageMustBeClear => _localizedValues['imageMustBeClear'] ?? 'الصورة يجب أن تكون واضحة';
  String get pleaseFillAllFields =>
      _localizedValues['pleaseFillAllFields'] ?? 'يرجى ملء جميع الحقول';
  String get changesSavedSuccessfully =>
      _localizedValues['changesSavedSuccessfully'] ?? 'تم حفظ التغييرات';

  // Home config labels
  String get headerTitleLabel => _localizedValues['headerTitleLabel'] ?? 'عنوان الرأسية';
  String get headerSubtitleLabel =>
      _localizedValues['headerSubtitleLabel'] ?? 'العنوان الفرعي للرأسية';
  String get searchHintLabel => _localizedValues['searchHintLabel'] ?? 'نص البحث';
  String get featuredWorkersTitleLabel =>
      _localizedValues['featuredWorkersTitleLabel'] ?? 'عنوان العمال المميزين';
  String get categoriesTitleLabel => _localizedValues['categoriesTitleLabel'] ?? 'عنوان التصنيفات';
  String get allWorkersTitleLabel =>
      _localizedValues['allWorkersTitleLabel'] ?? 'عنوان جميع العمال';
  String get emptyResultsMessageLabel =>
      _localizedValues['emptyResultsMessageLabel'] ?? 'رسالة عدم وجود نتائج';
  String get categoriesLabel => _localizedValues['categoriesLabel'] ?? 'التصنيفات:';
  String get categoryLabel => _localizedValues['categoryLabel'] ?? 'التصنيف';
  String get pleaseEnterCategoryName =>
      _localizedValues['pleaseEnterCategoryName'] ?? 'يرجى إدخال اسم التصنيف';
  String get addCategory => _localizedValues['addCategory'] ?? 'إضافة تصنيف';
  String get themeColorsLabel => _localizedValues['themeColorsLabel'] ?? 'ألوان الثيم:';
  String get pleaseFillThisField => _localizedValues['pleaseFillThisField'] ?? 'يرجى ملء هذا الحقل';

  // Validation messages
  String get nameRequired => _localizedValues['validation']?['nameRequired'] ?? 'الاسم مطلوب';
  String get nameTooShort => _localizedValues['validation']?['nameTooShort'] ?? 'الاسم قصير جداً';
  String get phoneRequired =>
      _localizedValues['validation']?['phoneRequired'] ?? 'رقم الهاتف مطلوب';
  String get invalidPhone =>
      _localizedValues['validation']?['invalidPhone'] ?? 'رقم الهاتف غير صحيح';
  String get roleRequired => _localizedValues['validation']?['roleRequired'] ?? 'الدور مطلوب';
  String get invalidRole => _localizedValues['validation']?['invalidRole'] ?? 'الدور غير صحيح';
  String get titleRequired => _localizedValues['validation']?['titleRequired'] ?? 'العنوان مطلوب';
  String get descriptionRequired =>
      _localizedValues['validation']?['descriptionRequired'] ?? 'الوصف مطلوب';
  String get priceRequired => _localizedValues['validation']?['priceRequired'] ?? 'السعر مطلوب';
  String get invalidPrice => _localizedValues['validation']?['invalidPrice'] ?? 'السعر غير صحيح';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}

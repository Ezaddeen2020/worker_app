import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:workers/features/settings/controllers/theme_controller.dart';
import 'package:workers/features/settings/controllers/language_controller.dart';
import 'package:workers/core/localization/app_translations.dart';
import 'bindings/initial_binding.dart';
import 'routes/rout.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // تسجيل الـ Controllers قبل تشغيل التطبيق
  Get.put<LanguageController>(LanguageController(), permanent: true);
  Get.put<ThemeController>(ThemeController(), permanent: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    final LanguageController languageController = Get.find<LanguageController>();

    return Obx(
      () => GetMaterialApp(
        title: 'appTitle'.tr,
        debugShowCheckedModeBanner: false,
        initialBinding: InitialBinding(),
        initialRoute: AppRoutes.splash,
        getPages: AppRoutes.pages,
        // استخدام نظام GetX للترجمات
        translations: AppTranslations(),
        locale: languageController.locale.value,
        fallbackLocale: const Locale('ar'),
        // دعم اللغة العربية والإنجليزية
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar'), Locale('en')],
        theme: ThemeController.lightTheme,
        darkTheme: ThemeController.darkTheme,
        themeMode: themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) {
          return Directionality(
            textDirection: languageController.isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

import 'package:get/get.dart';
import 'package:workers/features/auth/screens/splash_screen.dart';
import 'package:workers/features/home/screens/home_page.dart';
import 'package:workers/features/auth/screens/register_page.dart';
import 'package:workers/features/home/screens/favorites_page.dart';
import 'package:workers/features/posts/screens/posts_page.dart';
import 'package:workers/features/account/screens/account_page.dart';
import 'package:workers/features/settings/screens/setting_page.dart';
import 'package:workers/features/workers/screens/worker_onboarding.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String register = '/register';
  static const String home = '/home';
  static const String favorites = '/favorites';
  static const String posts = '/posts';
  static const String account = '/account';
  static const String settings = '/settings';
  static const String workerOnboarding = '/worker-onboarding';

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<dynamic>(name: splash, page: () => SplashScreen()),
    GetPage<dynamic>(name: register, page: () => const RegisterPage()),
    GetPage<dynamic>(name: home, page: () => HomePage()),
    GetPage<dynamic>(name: favorites, page: () => const FavoritesPage()),
    GetPage<dynamic>(name: posts, page: () => const PostsPage()),
    GetPage<dynamic>(name: account, page: () => const AccountPage()),
    GetPage<dynamic>(name: settings, page: () => const SettingsPage()),
    GetPage<dynamic>(name: workerOnboarding, page: () => const WorkerOnboardingPage()),
  ];
}

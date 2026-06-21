import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'theme.dart';
import 'views/splash_view.dart';
import 'views/home_view.dart';
import 'controllers/auth_controller.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage for persistence
  await GetStorage.init();
  // Initialize auth controller early so other controllers can depend on it
  Get.put(AuthController());

  runApp(const PennyPilotApp());
}
class PennyPilotApp extends StatelessWidget {
  const PennyPilotApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PennyPilot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashView(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomeView(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 600),
        ),
      ],
    );
  }
}

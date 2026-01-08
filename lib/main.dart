import 'package:flutter/material.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await AppConfig.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Joyful Nest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
        ).copyWith(surface: AppColors.background),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      // NOTE: Khôi phục flow chuẩn: Splash -> Login.
      home: const SplashScreen(),
    );
  }
}

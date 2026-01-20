import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/config/app_config.dart';
import 'core/utils/bad_cert_http_override.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await AppConfig.init();

  // DEV ONLY: Accept self-signed certs (SignalR / HTTPS)
  if (kDebugMode) {
    HttpOverrides.global = DevHttpOverrides();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Joyful Nest',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('vi', 'VN'),
      ],
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

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'features/notification/presentation/bloc/notification_bloc.dart';
import 'features/notification/presentation/bloc/notification_event.dart';
import 'core/constants/app_colors.dart';
import 'core/config/app_config.dart';
import 'core/utils/bad_cert_http_override.dart';
import 'core/routing/app_router.dart';
import 'core/routing/app_routes.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await AppConfig.init();

  // DEV ONLY: Accept self-signed certs (SignalR / HTTPS)
  if (kDebugMode && !kIsWeb) {
    HttpOverrides.global = DevHttpOverrides();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NotificationBloc>(
          create: (_) => InjectionContainer.notificationBloc
            ..add(const NotificationLoadRequested()),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => InjectionContainer.authBloc,
        ),
      ],
      child: MaterialApp(
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
        // Use AppRouter for centralized route management
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}

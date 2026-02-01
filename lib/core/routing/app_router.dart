import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/reset_otp_verification_screen.dart';
import '../../features/auth/presentation/screens/new_password_screen.dart';
import '../../features/role_selection/presentation/screens/role_selection_screen.dart';
import '../../features/profile/presentation/screens/account_details_screen.dart';
import '../../features/family_profile/presentation/screens/family_profile_screen.dart';
import '../../features/notification/presentation/screens/notification_screen.dart';
import '../../features/booking/presentation/screens/booking_history_screen.dart';
import '../../features/booking/presentation/screens/payment_screen.dart';
import '../../features/booking/presentation/screens/invoice_screen.dart';
import '../../features/contract/presentation/screens/contract_screen.dart';
import '../../features/package/presentation/screens/package_screen.dart';
import '../../features/package/presentation/bloc/package_event.dart';
import '../../features/supportAndPolicy/presentation/screens/support_and_policy_screen.dart';
import '../../features/supportAndPolicy/presentation/screens/help_screen.dart';
import '../../features/supportAndPolicy/presentation/screens/contact_screen.dart';
import '../../features/supportAndPolicy/presentation/screens/about_screen.dart';
import '../../features/supportAndPolicy/presentation/screens/terms_screen.dart';
import '../../features/supportAndPolicy/presentation/screens/privacy_screen.dart';
import '../../features/employee/presentation/screens/employee_portal_screen.dart';
import '../../features/chat/presentation/screens/conversation_list_screen.dart';
import '../../features/chat/presentation/screens/conversation_detail_screen.dart';
import '../../features/chat/presentation/screens/chat_shell_screen.dart';
import '../../features/family/presentation/screens/family_portal_screen.dart';
import '../../features/services/presentation/screens/my_menu_screen.dart';
import '../../features/services/presentation/screens/family_schedule_screen.dart';
import '../../features/services/presentation/screens/feedback_screen.dart';
import '../../features/services/presentation/bloc/menu_event.dart';
import '../../features/services/presentation/bloc/family_schedule_event.dart';
import '../../core/widgets/app_scaffold.dart';
import '../../core/di/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/booking/domain/entities/booking_entity.dart';
import '../../features/booking/presentation/bloc/booking_event.dart';
import '../../features/chat/presentation/bloc/chat_bloc.dart';
import '../../features/chat/presentation/bloc/chat_event.dart';
import 'app_routes.dart';

/// App Router - Centralized navigation management
/// Following clean architecture principles for code reusability
class AppRouter {
  AppRouter._(); // Private constructor to prevent instantiation

  /// Generate route based on route name
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // Auth Routes
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case AppRoutes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      
      case AppRoutes.resetPassword:
        return MaterialPageRoute(builder: (_) => const ResetPasswordScreen());
      
      case AppRoutes.otpVerification:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(
              email: args['email'] as String,
            ),
          );
        }
        return null;
      
      case AppRoutes.resetOtpVerification:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ResetOtpVerificationScreen(
              email: args['email'] as String,
            ),
          );
        }
        return null;
      
      case AppRoutes.newPassword:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => NewPasswordScreen(
              email: args['email'] as String,
              resetToken: args['resetToken'] as String,
            ),
          );
        }
        return null;
      
      case AppRoutes.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());

      // Main App Routes
      case AppRoutes.home:
      case AppRoutes.appointment:
      case AppRoutes.services:
      case AppRoutes.chat:
      case AppRoutes.profile:
        // These are handled by AppScaffold, not individual routes
        // Return AppScaffold as fallback
        return MaterialPageRoute(
          builder: (_) => const AppScaffold(),
        );

      // Profile Routes
      case AppRoutes.accountDetails:
        if (args is Map<String, dynamic>) {
          final authBloc = args['authBloc'] as AuthBloc?;
          return MaterialPageRoute(
            builder: (_) => authBloc != null
                ? BlocProvider.value(
                    value: authBloc,
                    child: AccountDetailsScreen(
                      userId: args['userId'] as String,
                    ),
                  )
                : AccountDetailsScreen(
                    userId: args['userId'] as String,
                  ),
          );
        }
        return null;
      
      case AppRoutes.familyProfile:
        if (args is Map<String, dynamic>) {
          final authBloc = args['authBloc'] as AuthBloc?;
          return MaterialPageRoute(
            builder: (_) => authBloc != null
                ? MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: authBloc),
                      BlocProvider(
                        create: (_) => InjectionContainer.familyProfileBloc,
                      ),
                    ],
                    child: const FamilyProfileScreen(),
                  )
                : BlocProvider(
                    create: (_) => InjectionContainer.familyProfileBloc,
                    child: const FamilyProfileScreen(),
                  ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => InjectionContainer.familyProfileBloc,
            child: const FamilyProfileScreen(),
          ),
        );
      
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());

      // Booking Routes
      case AppRoutes.bookingHistory:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (context) =>
                InjectionContainer.bookingBloc..add(const BookingLoadAll()),
            child: const BookingHistoryScreen(),
          ),
        );
      
      case AppRoutes.payment:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: args['bookingBloc'] as dynamic,
              child: PaymentScreen(
                booking: args['booking'] as BookingEntity,
                paymentType: args['paymentType'] as String? ?? 'Deposit',
              ),
            ),
          );
        }
        return null;
      
      case AppRoutes.invoice:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: args['bookingBloc'] as dynamic,
              child: InvoiceScreen(
                bookingId: args['bookingId'] as int,
              ),
            ),
          );
        }
        return null;

      // Contract Routes
      case AppRoutes.contract:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ContractScreen(
              bookingId: args['bookingId'] as int,
            ),
          );
        }
        return null;

      // Package Routes
      case AppRoutes.package:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => InjectionContainer.packageBloc
              ..add(const PackageLoadRequested()),
            child: const PackageScreen(),
          ),
        );

      // Support & Policy Routes
      case AppRoutes.supportAndPolicy:
        return MaterialPageRoute(
          builder: (_) => const SupportAndPolicyScreen(),
        );
      
      case AppRoutes.help:
        return MaterialPageRoute(builder: (_) => const HelpScreen());
      
      case AppRoutes.contact:
        return MaterialPageRoute(builder: (_) => const ContactScreen());
      
      case AppRoutes.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      
      case AppRoutes.terms:
        return MaterialPageRoute(builder: (_) => const TermsScreen());
      
      case AppRoutes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());

      // Employee Routes
      case AppRoutes.employeePortal:
        return MaterialPageRoute(
          builder: (_) => const EmployeePortalScreen(),
        );

      // Chat Routes
      case AppRoutes.conversationList:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => InjectionContainer.chatBloc
              ..add(const ChatStarted(autoSelectFirstConversation: false)),
            child: const ConversationListScreen(),
          ),
        );
      
      case AppRoutes.conversationDetail:
        if (args is Map<String, dynamic>) {
          final chatBloc = args['chatBloc'] as ChatBloc?;
          if (chatBloc != null) {
            return MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: chatBloc,
                child: const ConversationDetailScreen(),
              ),
            );
          }
        }
        return null;
      
      case AppRoutes.chatShell:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => InjectionContainer.chatBloc..add(const ChatStarted()),
            child: const ChatShellScreen(),
          ),
        );

      // Family Routes
      case AppRoutes.familyPortal:
        return MaterialPageRoute(
          builder: (_) => const FamilyPortalScreen(),
        );

      // Menu Routes
      case AppRoutes.myMenu:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => InjectionContainer.menuBloc
              ..add(const MenuLoadRequested()),
            child: const MyMenuScreen(),
          ),
        );

      // Family Schedule Routes
      case AppRoutes.familySchedule:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => InjectionContainer.familyScheduleBloc
              ..add(const FamilyScheduleLoadRequested()),
            child: const FamilyScheduleScreen(),
          ),
        );

      // Feedback Routes
      case AppRoutes.feedback:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => InjectionContainer.feedbackBloc,
            child: const FeedbackScreen(),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Navigation helper methods

  /// Push a new route
  static Future<T?> push<T>(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    final route = generateRoute(
      RouteSettings(name: routeName, arguments: arguments),
    );
    if (route != null) {
      return Navigator.of(context).push<T>(route as Route<T>);
    }
    throw Exception('Route not found: $routeName');
  }

  /// Push and replace current route
  static Future<T?> pushReplacement<T>(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    final route = generateRoute(
      RouteSettings(name: routeName, arguments: arguments),
    );
    if (route != null) {
      return Navigator.of(context).pushReplacement<T, T>(route as Route<T>);
    }
    throw Exception('Route not found: $routeName');
  }

  /// Push and remove all previous routes
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    final route = generateRoute(
      RouteSettings(name: routeName, arguments: arguments),
    );
    if (route != null) {
      return Navigator.of(context).pushAndRemoveUntil<T>(
        route as Route<T>,
        predicate ?? (route) => false,
      );
    }
    throw Exception('Route not found: $routeName');
  }

  /// Pop current route
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.of(context).pop<T>(result);
  }

  /// Pop until predicate
  static void popUntil(
    BuildContext context,
    bool Function(Route<dynamic>) predicate,
  ) {
    Navigator.of(context).popUntil(predicate);
  }
}

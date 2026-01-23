/// App Routes - Centralized route constants
/// Following clean architecture principles for code reusability
class AppRoutes {
  AppRoutes._(); // Private constructor to prevent instantiation

  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String resetPassword = '/reset-password';
  static const String otpVerification = '/otp-verification';
  static const String resetOtpVerification = '/reset-otp-verification';
  static const String newPassword = '/new-password';
  static const String roleSelection = '/role-selection';

  // Main App Routes
  static const String home = '/home';
  static const String appointment = '/appointment';
  static const String services = '/services';
  static const String chat = '/chat';
  static const String profile = '/profile';

  // Profile Routes
  static const String accountDetails = '/account-details';
  static const String familyProfile = '/family-profile';
  static const String notifications = '/notifications';

  // Booking Routes
  static const String bookingHistory = '/booking-history';
  static const String payment = '/payment';
  static const String invoice = '/invoice';

  // Contract Routes
  static const String contract = '/contract';

  // Package Routes
  static const String package = '/package';

  // Support & Policy Routes
  static const String supportAndPolicy = '/support-and-policy';
  static const String help = '/help';
  static const String contact = '/contact';
  static const String about = '/about';
  static const String terms = '/terms';
  static const String privacy = '/privacy';

  // Employee Routes
  static const String employeePortal = '/employee-portal';

  // Family Routes
  static const String familyPortal = '/family-portal';
}

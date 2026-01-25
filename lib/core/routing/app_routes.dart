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
  static const String familyServicesBooking = '/family-services-booking';
  static const String familyMealPlan = '/family-meal-plan';
  static const String familyMealSelection = '/family-meal-selection';
  static const String familyDailyMeal = '/family-daily-meal';
  static const String familyChat = '/family-chat';
  static const String familyBabyDailyReport = '/family-baby-daily-report';
  static const String familyFeedback = '/family-feedback';

  // Chat Routes
  static const String conversationList = '/conversation-list';
  static const String conversationDetail = '/conversation-detail';
  static const String chatShell = '/chat-shell';

  // Employee Routes (additional)
  static const String employeeSchedule = '/employee-schedule';
  static const String employeeTasks = '/employee-tasks';
  static const String employeeRequests = '/employee-requests';
  static const String employeeServiceBooking = '/employee-service-booking';
  static const String employeeMealPlan = '/employee-meal-plan';
  static const String employeeCheckInOut = '/employee-check-in-out';
  static const String serviceBooking = '/service-booking';

  // Menu Routes
  static const String myMenu = '/my-menu';
}

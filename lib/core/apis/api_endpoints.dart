/// API Endpoints
/// Centralized location for all API routes
class ApiEndpoints {
  ApiEndpoints._();

  // Auth endpoints
  static const String login = '/Auth/login';
  static const String register = '/Auth/register';
  static const String verifyEmail = '/Auth/verify-email';
  static const String logout = '/Auth/logout';
  static const String refreshToken = '/Auth/refresh-token';
  static const String forgotPassword = '/Auth/forgot-password';
  static const String verifyResetOtp = '/Auth/verify-reset-otp';
  static const String resetPassword = '/Auth/reset-password';
  static const String resendOtp = '/Auth/resend-otp';


  // Account endpoints
  static const String getCurrentAccount = '/Account/GetCurrentAccount';

  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';

  // Home endpoints
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Services endpoints
  static const String services = '/services';
  static String serviceById(String id) => '/services/$id';
  static const String serviceCategories = '/services/categories';

  // Schedule endpoints
  static const String schedules = '/schedules';
  static String scheduleById(String id) => '/schedules/$id';
  static const String mySchedules = '/schedules/my';
  static const String createSchedule = '/schedules';
  static String updateSchedule(String id) => '/schedules/$id';
  static String deleteSchedule(String id) => '/schedules/$id';

  // Profile endpoints
  static const String userProfile = '/profile';
  static const String updateUserProfile = '/profile';
}


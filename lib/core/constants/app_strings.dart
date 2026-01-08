/// App Strings - Centralized string constants for the application
/// Following clean architecture principles for code reusability
class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // App Name
  static const String appName = 'The Joyful Nest';

  // Login Screen
  static const String signInTitle = 'Sign In to The Joyful Nest';
  static const String signIn = 'Sign in';
  static const String signUp = 'Sign up';
  static const String google = 'Google';
  static const String or = 'or';

  // Form Labels
  static const String email = 'Email';
  static const String password = 'Password';
  static const String username = 'Username';
  static const String phone = 'Phone';

  // Placeholders
  static const String emailPlaceholder = 'your@email.com';
  static const String passwordPlaceholder = 'password';
  static const String usernamePlaceholder = 'Enter your username';
  static const String phonePlaceholder = 'Enter your phone number';

  // Reset Password Screen
  static const String resetYourPassword = 'Reset Your Password';
  static const String resetPasswordDescription =
      "Enter your email address and we'll send you a password reset link.";
  static const String resetPassword = 'Reset Password';
  static const String rememberYourPassword = 'Remember your password?';

  // Sign Up Screen
  static const String signUpTitle = 'Create your account';
  static const String signUpDescription =
      'Enter your details below to create a new account.';
  static const String fullName = 'Full name';
  static const String confirmPassword = 'Confirm password';
  static const String fullNamePlaceholder = 'Your name';
  static const String confirmPasswordPlaceholder = 'Re-enter your password';
  static const String alreadyHaveAccount = 'Already have an account?';

  // Splash Screen
  static const String tagline = 'Tổ ấm hạnh phúc của bạn.';
  static const String loading = 'Loading...';
  static const String processing = 'Đang xử lý...';

  // Links
  static const String needAnAccount = 'Need an account?';
  static const String forgotPassword = 'Forgot your password?';
  static const String resetIt = 'Reset it';

  // Home Screen
  static const String goodMorning = 'Chào buổi sáng';
  static const String quickActions = 'Lối tắt';
  static const String upcomingSchedule = 'Lịch trình sắp tới';
  static const String promotions = 'Ưu đãi & Gói dịch vụ';
  static const String viewAll = 'Xem tất cả';

  // Quick Actions
  static const String spaAndCare = 'Spa & Chăm sóc';
  static const String babyActivities = 'Hoạt động cho bé';
  static const String nutritionMenu = 'Thực đơn & Dinh dưỡng';
  static const String resortMap = 'Bản đồ Resort';

  //Error Input
  static const String errorInputEmail = 'Please enter your email or username';
  static const String errorInputPassword = 'Please enter your password';
  static const String errorInputUsername = 'Please enter your username';
  static const String errorInputPhone = 'Please enter your phone number';
  static const String errorInputEmailRequired = 'Please enter your email';
  static const String errorInputEmailInvalid = 'Please enter a valid email';
  static const String errorInputPasswordRequired = 'Please enter your password';
  static const String errorInputPasswordMinLength = 'Password must be at least 6 characters';
  static const String errorInputConfirmPassword = 'Please confirm your password';
  static const String errorInputPasswordsNotMatch = 'Passwords do not match';
  static const String errorFillAllFields = 'Please fill in all fields';
  static const String errorOtpInvalid = 'Please enter a valid 6-digit OTP';

  //Toast Message
  static const String successLogin = 'Đăng nhập thành công';
  static const String errorLogin = 'Đăng nhập thất bại';
  static const String successRegister = 'Đăng ký thành công';
  static const String errorRegister = 'Đăng ký thất bại';
  static const String successLogout = 'Đăng xuất thành công';
  static const String errorLogout = 'Đăng xuất thất bại';
  static const String successUpdateProfile = 'Cập nhật thông tin thành công';
  static const String errorUpdateProfile = 'Cập nhật thông tin thất bại';
  static const String successVerifyEmail = 'Xác thực email thành công';
  static const String errorVerifyEmail = 'Xác thực email thất bại';
  static const String successResetPassword = 'Reset link sent!';

  // OTP Verification Screen
  static const String otpVerificationTitle = 'Xác thực Email';
  static const String otpVerificationDescription = 'Nhập mã OTP đã được gửi đến';
  static const String otpVerificationButton = 'Xác thực';
  static const String resendOtp = 'Gửi lại OTP';
  static const String resendOtpCountdown = 'Gửi lại OTP sau {seconds}s';

  // Profile Screen
  static const String profileTitle = 'Profile';
  static const String profileScreen = 'Profile Screen';
  static const String logoutTitle = 'Đăng xuất';
  static const String logoutConfirmation = 'Bạn có chắc chắn muốn đăng xuất?';
  static const String cancel = 'Hủy';
  static const String logout = 'Đăng xuất';

  // Other Screens
  static const String servicesScreen = 'Services Screen';
  static const String scheduleScreen = 'Schedule Screen';

  // Bottom Navigation Bar
  static const String bottomNavHome = 'Home';
  static const String bottomNavServices = 'Services';
  static const String bottomNavSchedule = 'Schedule';
  static const String bottomNavProfile = 'Profile';

  // Error Messages
  static const String errorLoginFailed = 'Login failed';
}


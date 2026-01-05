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

  // Placeholders
  static const String emailPlaceholder = 'your@email.com';
  static const String passwordPlaceholder = 'correct horse battery staple';

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

  // Links
  static const String needAnAccount = 'Need an account?';
  static const String forgotPassword = 'Forgot your password?';
  static const String resetIt = 'Reset it';
}


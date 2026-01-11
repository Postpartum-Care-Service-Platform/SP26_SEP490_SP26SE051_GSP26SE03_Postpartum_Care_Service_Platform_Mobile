import 'package:equatable/equatable.dart';

/// Auth Events - Events that can be triggered in the auth flow
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to sign in with email and password
class AuthLoginWithEmailPassword extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginWithEmailPassword({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign in with Google
class AuthLoginWithGoogle extends AuthEvent {
  final String idToken;

  const AuthLoginWithGoogle({
    required this.idToken,
  });

  @override
  List<Object?> get props => [idToken];
}

/// Event to register with email, password, and other details
class AuthRegister extends AuthEvent {
  final String email;
  final String password;
  final String confirmPassword;
  final String phone;
  final String username;

  const AuthRegister({
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.username,
  });

  @override
  List<Object?> get props => [email, password, confirmPassword, phone, username];
}

/// Event to verify email with OTP
class AuthVerifyEmail extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyEmail({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

/// Event to request forgot password (send OTP to email)
class AuthForgotPassword extends AuthEvent {
  final String email;

  const AuthForgotPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to verify reset OTP (for forgot password flow)
class AuthVerifyResetOtp extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyResetOtp({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

/// Event to reset password with resetToken
class AuthResetPassword extends AuthEvent {
  final String resetToken;
  final String newPassword;
  final String confirmNewPassword;

  const AuthResetPassword({
    required this.resetToken,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object?> get props => [resetToken, newPassword, confirmNewPassword];
}

/// Event to toggle password visibility
class AuthTogglePasswordVisibility extends AuthEvent {
  const AuthTogglePasswordVisibility();
}

/// Event to resend OTP
class AuthResendOtp extends AuthEvent {
  final String email;

  const AuthResendOtp({required this.email});

  @override
  List<Object?> get props => [email];
}

/// Event to reset auth state
class AuthResetState extends AuthEvent {
  const AuthResetState();
}

/// Event to get account by ID
class AuthGetAccountById extends AuthEvent {
  final String id;

  const AuthGetAccountById({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to change password
class AuthChangePassword extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;

  const AuthChangePassword({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword, confirmNewPassword];
}



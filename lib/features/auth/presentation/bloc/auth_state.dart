import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../data/models/current_account_model.dart';


/// Auth States - States that represent the auth flow
abstract class AuthState extends Equatable {
  final bool isPasswordObscured;

  const AuthState({this.isPasswordObscured = true});

  @override
  List<Object?> get props => [isPasswordObscured];
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial({super.isPasswordObscured});
}

/// Loading state - when auth is in progress
class AuthLoading extends AuthState {
  const AuthLoading({super.isPasswordObscured});
}

/// Success state - when auth is successful
class AuthSuccess extends AuthState {
  final UserEntity? user;

  const AuthSuccess({
    super.isPasswordObscured,
    this.user,
  });

  @override
  List<Object?> get props => [isPasswordObscured, user];
}

/// Error state - when auth fails
class AuthError extends AuthState {
  final String message;

  const AuthError({
    required this.message,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [message, isPasswordObscured];
}

/// Register success state - when registration is successful
class AuthRegisterSuccess extends AuthState {
  final String message;
  final String email;

  const AuthRegisterSuccess({
    required this.message,
    required this.email,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [message, email, isPasswordObscured];
}

/// Verify email success state - when email verification is successful
class AuthVerifyEmailSuccess extends AuthState {
  final String message;

  const AuthVerifyEmailSuccess({
    required this.message,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [message, isPasswordObscured];
}

/// Forgot password success - when OTP has been sent to email
class AuthForgotPasswordSuccess extends AuthState {
  final String message;
  final String email;

  const AuthForgotPasswordSuccess({
    required this.message,
    required this.email,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [message, email, isPasswordObscured];
}

/// Verify reset OTP success - returns resetToken for next step
class AuthVerifyResetOtpSuccess extends AuthState {
  final String message;
  final String resetToken;
  final String email;

  const AuthVerifyResetOtpSuccess({
    required this.message,
    required this.resetToken,
    required this.email,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [message, resetToken, email, isPasswordObscured];
}

/// Reset password success state
class AuthResetPasswordSuccess extends AuthState {
  final String message;

  const AuthResetPasswordSuccess({
    required this.message,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [message, isPasswordObscured];
}

/// Get account by ID success state
class AuthGetAccountByIdSuccess extends AuthState {
  final CurrentAccountModel account;

  const AuthGetAccountByIdSuccess({
    required this.account,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [account, isPasswordObscured];
}

/// Change password success state
class AuthChangePasswordSuccess extends AuthState {
  final String message;

  const AuthChangePasswordSuccess({
    required this.message,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [message, isPasswordObscured];
}

/// Current account loaded state
class AuthCurrentAccountLoaded extends AuthState {
  final CurrentAccountModel account;

  const AuthCurrentAccountLoaded({
    required this.account,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [account, isPasswordObscured];
}



import 'package:equatable/equatable.dart';

/// Login States - States that represent the login flow
abstract class LoginState extends Equatable {
  final bool isPasswordObscured;

  const LoginState({this.isPasswordObscured = true});

  @override
  List<Object?> get props => [isPasswordObscured];
}

/// Initial state
class LoginInitial extends LoginState {
  const LoginInitial({super.isPasswordObscured});
}

/// Loading state - when login is in progress
class LoginLoading extends LoginState {
  const LoginLoading({super.isPasswordObscured});
}

/// Success state - when login is successful
class LoginSuccess extends LoginState {
  const LoginSuccess({super.isPasswordObscured});
}

/// Error state - when login fails
class LoginError extends LoginState {
  final String message;

  const LoginError({
    required this.message,
    super.isPasswordObscured,
  });

  @override
  List<Object?> get props => [message, isPasswordObscured];
}


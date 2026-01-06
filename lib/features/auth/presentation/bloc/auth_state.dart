import 'package:equatable/equatable.dart';

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
  const AuthSuccess({super.isPasswordObscured});
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



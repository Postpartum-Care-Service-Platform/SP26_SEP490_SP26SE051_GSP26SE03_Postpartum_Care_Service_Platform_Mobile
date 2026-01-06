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
  const AuthLoginWithGoogle();
}

/// Event to toggle password visibility
class AuthTogglePasswordVisibility extends AuthEvent {
  const AuthTogglePasswordVisibility();
}

/// Event to reset auth state
class AuthResetState extends AuthEvent {
  const AuthResetState();
}



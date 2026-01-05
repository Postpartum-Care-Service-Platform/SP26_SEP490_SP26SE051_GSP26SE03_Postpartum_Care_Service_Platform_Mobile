import 'package:equatable/equatable.dart';

/// Login Events - Events that can be triggered in the login flow
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Event to sign in with email and password
class LoginWithEmailPassword extends LoginEvent {
  final String email;
  final String password;

  const LoginWithEmailPassword({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Event to sign in with Google
class LoginWithGoogle extends LoginEvent {
  const LoginWithGoogle();
}

/// Event to toggle password visibility
class TogglePasswordVisibility extends LoginEvent {
  const TogglePasswordVisibility();
}

/// Event to reset login state
class ResetLoginState extends LoginEvent {
  const ResetLoginState();
}


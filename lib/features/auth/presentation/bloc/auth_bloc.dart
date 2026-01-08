import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_role.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BloC - Business Logic Component for authentication functionality
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial(isPasswordObscured: true)) {
    on<AuthLoginWithEmailPassword>(_onLoginWithEmailPassword);
    on<AuthLoginWithGoogle>(_onLoginWithGoogle);
    on<AuthTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<AuthResetState>(_onResetState);
  }

  Future<void> _onLoginWithEmailPassword(
    AuthLoginWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    // TODO: Implement actual login logic with repository
    // For now, simulate a login process
    await Future.delayed(const Duration(seconds: 1));

    // Validate email and password
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(AuthError(
        message: 'Please fill in all fields',
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    // Simple email validation
    if (!event.email.contains('@')) {
      emit(AuthError(
        message: 'Please enter a valid email',
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    // Simulate successful login
    emit(AuthSuccess(isPasswordObscured: state.isPasswordObscured));
  }

  Future<void> _onLoginWithGoogle(
    AuthLoginWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    // TODO: Implement Google sign-in logic
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful login
    emit(AuthSuccess(isPasswordObscured: state.isPasswordObscured));
  }

  void _onTogglePasswordVisibility(
    AuthTogglePasswordVisibility event,
    Emitter<AuthState> emit,
  ) {
    final newObscured = !state.isPasswordObscured;

    // Preserve the current state type while updating password visibility
    if (state is AuthInitial) {
      emit(AuthInitial(isPasswordObscured: newObscured));
    } else if (state is AuthLoading) {
      emit(AuthLoading(isPasswordObscured: newObscured));
    } else if (state is AuthSuccess) {
      emit(AuthSuccess(isPasswordObscured: newObscured));
    } else if (state is AuthError) {
      emit(AuthError(
        message: (state as AuthError).message,
        isPasswordObscured: newObscured,
      ));
    } else {
      emit(AuthInitial(isPasswordObscured: newObscured));
    }
  }

  void _onResetState(
    AuthResetState event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial(isPasswordObscured: state.isPasswordObscured));
  }
}



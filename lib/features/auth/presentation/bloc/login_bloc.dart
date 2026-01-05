import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

/// Login BloC - Business Logic Component for login functionality
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial(isPasswordObscured: true)) {
    on<LoginWithEmailPassword>(_onLoginWithEmailPassword);
    on<LoginWithGoogle>(_onLoginWithGoogle);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<ResetLoginState>(_onResetLoginState);
  }

  Future<void> _onLoginWithEmailPassword(
    LoginWithEmailPassword event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading(isPasswordObscured: state.isPasswordObscured));

    // TODO: Implement actual login logic with repository
    // For now, simulate a login process
    await Future.delayed(const Duration(seconds: 1));

    // Validate email and password
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(LoginError(
        message: 'Please fill in all fields',
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    // Simple email validation
    if (!event.email.contains('@')) {
      emit(LoginError(
        message: 'Please enter a valid email',
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    // Simulate successful login
    emit(LoginSuccess(isPasswordObscured: state.isPasswordObscured));
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogle event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading(isPasswordObscured: state.isPasswordObscured));

    // TODO: Implement Google sign-in logic
    await Future.delayed(const Duration(seconds: 1));

    // Simulate successful login
    emit(LoginSuccess(isPasswordObscured: state.isPasswordObscured));
  }

  void _onTogglePasswordVisibility(
    TogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    final newObscured = !state.isPasswordObscured;
    
    // Preserve the current state type while updating password visibility
    if (state is LoginInitial) {
      emit(LoginInitial(isPasswordObscured: newObscured));
    } else if (state is LoginLoading) {
      emit(LoginLoading(isPasswordObscured: newObscured));
    } else if (state is LoginSuccess) {
      emit(LoginSuccess(isPasswordObscured: newObscured));
    } else if (state is LoginError) {
      emit(LoginError(
        message: (state as LoginError).message,
        isPasswordObscured: newObscured,
      ));
    } else {
      emit(LoginInitial(isPasswordObscured: newObscured));
    }
  }

  void _onResetLoginState(
    ResetLoginState event,
    Emitter<LoginState> emit,
  ) {
    emit(LoginInitial(isPasswordObscured: state.isPasswordObscured));
  }
}


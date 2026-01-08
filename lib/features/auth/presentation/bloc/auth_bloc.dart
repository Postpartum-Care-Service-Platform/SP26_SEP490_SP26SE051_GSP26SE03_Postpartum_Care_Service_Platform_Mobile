import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/verify_reset_otp_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/resend_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Auth BloC - Business Logic Component for authentication functionality
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final VerifyEmailUsecase verifyEmailUsecase;
  final ForgotPasswordUsecase forgotPasswordUsecase;
  final VerifyResetOtpUsecase verifyResetOtpUsecase;
  final ResetPasswordUsecase resetPasswordUsecase;
  final ResendOtpUsecase resendOtpUsecase;

  AuthBloc({
    required this.loginUsecase,
    required this.registerUsecase,
    required this.verifyEmailUsecase,
    required this.forgotPasswordUsecase,
    required this.verifyResetOtpUsecase,
    required this.resetPasswordUsecase,
    required this.resendOtpUsecase,
  }) : super(const AuthInitial(isPasswordObscured: true)) {
    on<AuthLoginWithEmailPassword>(_onLoginWithEmailPassword);
    on<AuthLoginWithGoogle>(_onLoginWithGoogle);
    on<AuthRegister>(_onRegister);
    on<AuthVerifyEmail>(_onVerifyEmail);
    on<AuthForgotPassword>(_onForgotPassword);
    on<AuthVerifyResetOtp>(_onVerifyResetOtp);
    on<AuthResetPassword>(_onResetPassword);
    on<AuthResendOtp>(_onResendOtp);
    on<AuthTogglePasswordVisibility>(_onTogglePasswordVisibility);
    on<AuthResetState>(_onResetState);
  }

  Future<void> _onLoginWithEmailPassword(
    AuthLoginWithEmailPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    // Validate email/username and password
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(AuthError(
        message: AppStrings.errorFillAllFields,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    try {
      final user = await loginUsecase(
        emailOrUsername: event.email,
        password: event.password,
      );

      emit(AuthSuccess(
        isPasswordObscured: state.isPasswordObscured,
        user: user,
      ));
    } catch (e) {
      emit(AuthError(
        message: e.toString().replaceAll('Exception: ', ''),
        isPasswordObscured: state.isPasswordObscured,
      ));
    }
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

  Future<void> _onRegister(
    AuthRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    // Validate all fields
    if (event.email.isEmpty ||
        event.password.isEmpty ||
        event.confirmPassword.isEmpty ||
        event.phone.isEmpty ||
        event.username.isEmpty) {
      emit(AuthError(
        message: AppStrings.errorFillAllFields,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    // Validate password match
    if (event.password != event.confirmPassword) {
      emit(AuthError(
        message: AppStrings.errorInputPasswordsNotMatch,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    try {
      final message = await registerUsecase(
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
        phone: event.phone,
        username: event.username,
      );

      emit(AuthRegisterSuccess(
        isPasswordObscured: state.isPasswordObscured,
        message: message,
        email: event.email,
      ));
    } catch (e) {
      emit(AuthError(
        message: e.toString().replaceAll('Exception: ', ''),
        isPasswordObscured: state.isPasswordObscured,
      ));
    }
  }

  Future<void> _onVerifyEmail(
    AuthVerifyEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    // Validate OTP
    if (event.otp.isEmpty || event.otp.length != 6) {
      emit(AuthError(
        message: AppStrings.errorOtpInvalid,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    try {
      final message = await verifyEmailUsecase(
        email: event.email,
        otp: event.otp,
      );

      emit(AuthVerifyEmailSuccess(
        isPasswordObscured: state.isPasswordObscured,
        message: message,
      ));
    } catch (e) {
      emit(AuthError(
        message: e.toString().replaceAll('Exception: ', ''),
        isPasswordObscured: state.isPasswordObscured,
      ));
    }
  }

  Future<void> _onForgotPassword(
    AuthForgotPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    if (event.email.isEmpty) {
      emit(AuthError(
        message: AppStrings.errorInputEmailRequired,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    try {
      final message = await forgotPasswordUsecase(email: event.email);

      emit(AuthForgotPasswordSuccess(
        isPasswordObscured: state.isPasswordObscured,
        message: message,
        email: event.email,
      ));
    } catch (e) {
      emit(AuthError(
        message: e.toString().replaceAll('Exception: ', ''),
        isPasswordObscured: state.isPasswordObscured,
      ));
    }
  }

  Future<void> _onVerifyResetOtp(
    AuthVerifyResetOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    if (event.otp.isEmpty || event.otp.length != 6) {
      emit(AuthError(
        message: AppStrings.errorOtpInvalid,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    try {
      final resetToken = await verifyResetOtpUsecase(
        email: event.email,
        otp: event.otp,
      );

      emit(AuthVerifyResetOtpSuccess(
        isPasswordObscured: state.isPasswordObscured,
        message: AppStrings.successVerifyEmail,
        resetToken: resetToken,
        email: event.email,
      ));
    } catch (e) {
      emit(AuthError(
        message: e.toString().replaceAll('Exception: ', ''),
        isPasswordObscured: state.isPasswordObscured,
      ));
    }
  }

  Future<void> _onResetPassword(
    AuthResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    if (event.newPassword.isEmpty || event.confirmNewPassword.isEmpty) {
      emit(AuthError(
        message: AppStrings.errorInputPasswordRequired,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    if (event.newPassword.length < 6) {
      emit(AuthError(
        message: AppStrings.errorInputPasswordMinLength,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    if (event.newPassword != event.confirmNewPassword) {
      emit(AuthError(
        message: AppStrings.errorInputPasswordsNotMatch,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    try {
      final message = await resetPasswordUsecase(
        resetToken: event.resetToken,
        newPassword: event.newPassword,
        confirmNewPassword: event.confirmNewPassword,
      );

      emit(AuthResetPasswordSuccess(
        isPasswordObscured: state.isPasswordObscured,
        message: message,
      ));
    } catch (e) {
      emit(AuthError(
        message: e.toString().replaceAll('Exception: ', ''),
        isPasswordObscured: state.isPasswordObscured,
      ));
    }
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

  Future<void> _onResendOtp(
    AuthResendOtp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading(isPasswordObscured: state.isPasswordObscured));

    // Validate email
    if (event.email.isEmpty) {
      emit(AuthError(
        message: AppStrings.errorInputEmailRequired,
        isPasswordObscured: state.isPasswordObscured,
      ));
      return;
    }

    try {
      final message = await resendOtpUsecase(email: event.email);

      emit(AuthForgotPasswordSuccess(
        isPasswordObscured: state.isPasswordObscured,
        message: message,
        email: event.email,
      ));
    } catch (e) {
      emit(AuthError(
        message: e.toString().replaceAll('Exception: ', ''),
        isPasswordObscured: state.isPasswordObscured,
      ));
    }
  }

  void _onResetState(
    AuthResetState event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial(isPasswordObscured: state.isPasswordObscured));
  }
}



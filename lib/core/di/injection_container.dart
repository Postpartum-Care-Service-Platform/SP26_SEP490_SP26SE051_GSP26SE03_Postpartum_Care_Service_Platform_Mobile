import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/verify_email_usecase.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/resend_otp_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../apis/api_client.dart';

/// Centralized dependency injection container
/// Contains all dependency injections for the entire app
class InjectionContainer {
  InjectionContainer._();

  // ==================== Data Sources ====================
  
  static AuthRemoteDataSource get _authRemoteDataSource =>
      AuthRemoteDataSourceImpl(dio: ApiClient.dio);

  // ==================== Repositories ====================
  
  static AuthRepository get authRepository =>
      AuthRepositoryImpl(remoteDataSource: _authRemoteDataSource);
  
  static AuthRepository get _authRepository => authRepository;

  // ==================== Use Cases ====================
  
  static LoginUsecase get _loginUsecase => LoginUsecase(_authRepository);
  static RegisterUsecase get _registerUsecase => RegisterUsecase(_authRepository);
  static VerifyEmailUsecase get _verifyEmailUsecase => VerifyEmailUsecase(_authRepository);
  static ForgotPasswordUsecase get _forgotPasswordUsecase =>
      ForgotPasswordUsecase(_authRepository);
  static VerifyResetOtpUsecase get _verifyResetOtpUsecase =>
      VerifyResetOtpUsecase(_authRepository);
  static ResetPasswordUsecase get _resetPasswordUsecase =>
      ResetPasswordUsecase(_authRepository);
  static ResendOtpUsecase get _resendOtpUsecase =>
      ResendOtpUsecase(_authRepository);

  // ==================== Blocs ====================
  
  static AuthBloc get authBloc => AuthBloc(
    loginUsecase: _loginUsecase,
    registerUsecase: _registerUsecase,
    verifyEmailUsecase: _verifyEmailUsecase,
    forgotPasswordUsecase: _forgotPasswordUsecase,
    verifyResetOtpUsecase: _verifyResetOtpUsecase,
    resetPasswordUsecase: _resetPasswordUsecase,
    resendOtpUsecase: _resendOtpUsecase,
  );

  // ==================== Reset ====================
  
  /// Reset all dependencies (useful for testing or logout)
  static void reset() {
    ApiClient.reset();
  }
}


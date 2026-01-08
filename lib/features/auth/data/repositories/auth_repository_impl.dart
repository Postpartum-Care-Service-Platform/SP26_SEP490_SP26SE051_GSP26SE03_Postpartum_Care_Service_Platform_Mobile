import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/verify_email_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/verify_reset_otp_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../../../../core/storage/secure_storage_service.dart';

/// Authentication repository implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final request = LoginRequestModel(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      final response = await remoteDataSource.login(request);

      // Save tokens to secure storage
      await SecureStorageService.saveAccessToken(response.accessToken);
      await SecureStorageService.saveRefreshToken(response.refreshToken);
      await SecureStorageService.saveExpiresAt(response.expiresAt);

      return response.user.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String username,
  }) async {
    try {
      final request = RegisterRequestModel(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phone: phone,
        username: username,
      );

      final response = await remoteDataSource.register(request);

      return response.message;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> verifyEmail({
    required String email,
    required String otp,
  }) async {
    try {
      final request = VerifyEmailRequestModel(
        email: email,
        otp: otp,
      );

      final response = await remoteDataSource.verifyEmail(request);

      return response.message;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> forgotPassword({
    required String email,
  }) async {
    try {
      final request = ForgotPasswordRequestModel(email: email);
      final response = await remoteDataSource.forgotPassword(request);
      return response.message;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final request = VerifyResetOtpRequestModel(email: email, otp: otp);
      final response = await remoteDataSource.verifyResetOtp(request);
      // Return resetToken, to be used in next step
      return response.resetToken;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final request = ResetPasswordRequestModel(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      final response = await remoteDataSource.resetPassword(request);
      return response.message;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> resendOtp({
    required String email,
  }) async {
    try {
      final request = ForgotPasswordRequestModel(email: email);
      final response = await remoteDataSource.resendOtp(request);
      return response.message;
    } catch (e) {
      rethrow;
    }
  }
}


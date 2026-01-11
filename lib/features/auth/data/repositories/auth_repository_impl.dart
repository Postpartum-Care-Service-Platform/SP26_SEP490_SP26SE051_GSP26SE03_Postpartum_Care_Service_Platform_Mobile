import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/register_request_model.dart';
import '../models/verify_email_request_model.dart';
import '../models/forgot_password_request_model.dart';
import '../models/verify_reset_otp_request_model.dart';
import '../models/reset_password_request_model.dart';
import '../models/refresh_token_request_model.dart';
import '../models/google_sign_in_request_model.dart';
import '../models/change_password_request_model.dart';
import '../models/current_account_model.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/services/current_account_cache_service.dart';

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

  @override
  Future<void> refreshToken() async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw Exception('No refresh token available');
      }

      final request = RefreshTokenRequestModel(refreshToken: refreshToken);
      final response = await remoteDataSource.refreshToken(request);

      // Save new tokens to secure storage
      await SecureStorageService.saveAccessToken(response.accessToken);
      await SecureStorageService.saveRefreshToken(response.refreshToken);
      await SecureStorageService.saveExpiresAt(response.expiresAt);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> googleSignIn({
    required String idToken,
  }) async {
    try {
      final request = GoogleSignInRequestModel(idToken: idToken);
      final response = await remoteDataSource.googleSignIn(request);

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
  Future<CurrentAccountModel> getCurrentAccount() async {
    try {
      // Try to get from cache first
      final cachedAccount = await CurrentAccountCacheService.getCurrentAccount();
      if (cachedAccount != null) {
        // Return cached account immediately for better UX
        // Then refresh in background
        _refreshCurrentAccountInBackground();
        return cachedAccount;
      }

      // No cache, fetch from API
      final account = await remoteDataSource.getCurrentAccount();
      
      // Save to cache
      await CurrentAccountCacheService.saveCurrentAccount(account);
      
      return account;
    } catch (e) {
      // If API fails, try to return cached data as fallback
      final cachedAccount = await CurrentAccountCacheService.getCurrentAccount();
      if (cachedAccount != null) {
        return cachedAccount;
      }
      rethrow;
    }
  }

  /// Refresh current account in background without blocking
  Future<void> _refreshCurrentAccountInBackground() async {
    try {
      final account = await remoteDataSource.getCurrentAccount();
      await CurrentAccountCacheService.saveCurrentAccount(account);
    } catch (e) {
      // Silently fail - background refresh is optional
    }
  }

  @override
  Future<CurrentAccountModel> getAccountById(String id) async {
    try {
      return await remoteDataSource.getAccountById(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final request = ChangePasswordRequestModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );
      final response = await remoteDataSource.changePassword(request);
      return response.message;
    } catch (e) {
      rethrow;
    }
  }
}


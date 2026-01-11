import '../entities/user_entity.dart';
import '../../data/models/current_account_model.dart';

/// Authentication repository interface
abstract class AuthRepository {
  Future<UserEntity> login({
    required String emailOrUsername,
    required String password,
  });

  Future<String> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String username,
  });

  Future<String> verifyEmail({
    required String email,
    required String otp,
  });

  Future<String> forgotPassword({
    required String email,
  });

  Future<String> verifyResetOtp({
    required String email,
    required String otp,
  });

  Future<String> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  });

  Future<String> resendOtp({
    required String email,
  });

  Future<void> refreshToken();

  Future<UserEntity> googleSignIn({
    required String idToken,
  });

  Future<CurrentAccountModel> getCurrentAccount();

  Future<CurrentAccountModel> getAccountById(String id);

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
}


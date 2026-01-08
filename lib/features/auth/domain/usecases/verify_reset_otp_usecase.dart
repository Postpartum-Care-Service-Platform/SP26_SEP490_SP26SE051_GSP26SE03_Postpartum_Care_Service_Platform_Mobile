import '../repositories/auth_repository.dart';

/// Verify reset OTP use case
class VerifyResetOtpUsecase {
  final AuthRepository repository;

  VerifyResetOtpUsecase(this.repository);

  /// Returns resetToken on success
  Future<String> call({
    required String email,
    required String otp,
  }) async {
    return await repository.verifyResetOtp(
      email: email,
      otp: otp,
    );
  }
}



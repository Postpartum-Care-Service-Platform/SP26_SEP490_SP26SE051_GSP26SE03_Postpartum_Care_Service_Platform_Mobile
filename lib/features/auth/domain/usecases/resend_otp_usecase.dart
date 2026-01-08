import '../repositories/auth_repository.dart';

/// Resend OTP use case
class ResendOtpUsecase {
  final AuthRepository repository;

  ResendOtpUsecase(this.repository);

  Future<String> call({
    required String email,
  }) async {
    return await repository.resendOtp(email: email);
  }
}


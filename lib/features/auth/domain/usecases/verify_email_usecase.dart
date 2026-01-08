import '../repositories/auth_repository.dart';

/// Verify email use case
class VerifyEmailUsecase {
  final AuthRepository repository;

  VerifyEmailUsecase(this.repository);

  Future<String> call({
    required String email,
    required String otp,
  }) async {
    return await repository.verifyEmail(
      email: email,
      otp: otp,
    );
  }
}


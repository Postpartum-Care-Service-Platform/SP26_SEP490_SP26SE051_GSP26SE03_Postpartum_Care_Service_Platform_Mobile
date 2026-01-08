import '../repositories/auth_repository.dart';

/// Forgot password use case
class ForgotPasswordUsecase {
  final AuthRepository repository;

  ForgotPasswordUsecase(this.repository);

  Future<String> call({
    required String email,
  }) async {
    return await repository.forgotPassword(email: email);
  }
}



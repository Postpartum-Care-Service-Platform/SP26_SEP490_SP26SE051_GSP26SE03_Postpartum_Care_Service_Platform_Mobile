import '../repositories/auth_repository.dart';

/// Reset password use case
class ResetPasswordUsecase {
  final AuthRepository repository;

  ResetPasswordUsecase(this.repository);

  Future<String> call({
    required String resetToken,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    return await repository.resetPassword(
      resetToken: resetToken,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}



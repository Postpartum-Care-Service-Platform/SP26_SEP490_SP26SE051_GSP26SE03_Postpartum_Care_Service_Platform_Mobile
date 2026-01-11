import '../repositories/auth_repository.dart';

/// Change password use case
class ChangePasswordUsecase {
  final AuthRepository repository;

  ChangePasswordUsecase(this.repository);

  Future<String> call({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    return await repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );
  }
}

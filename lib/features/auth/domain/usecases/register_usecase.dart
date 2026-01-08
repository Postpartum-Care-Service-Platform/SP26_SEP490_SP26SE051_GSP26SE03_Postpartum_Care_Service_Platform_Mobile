import '../repositories/auth_repository.dart';

/// Register use case
class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<String> call({
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
    required String username,
  }) async {
    return await repository.register(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      phone: phone,
      username: username,
    );
  }
}


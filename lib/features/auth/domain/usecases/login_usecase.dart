import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Login use case
class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<UserEntity> call({
    required String emailOrUsername,
    required String password,
  }) async {
    return await repository.login(
      emailOrUsername: emailOrUsername,
      password: password,
    );
  }
}


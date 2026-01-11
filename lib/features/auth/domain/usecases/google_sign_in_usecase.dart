import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Google sign-in use case
class GoogleSignInUsecase {
  final AuthRepository repository;

  GoogleSignInUsecase(this.repository);

  Future<UserEntity> call({
    required String idToken,
  }) async {
    return await repository.googleSignIn(idToken: idToken);
  }
}

import '../../data/models/current_account_model.dart';
import '../repositories/auth_repository.dart';

/// Get current account use case
class GetCurrentAccountUsecase {
  final AuthRepository repository;

  GetCurrentAccountUsecase(this.repository);

  Future<CurrentAccountModel> call() async {
    return await repository.getCurrentAccount();
  }
}

import '../../data/models/current_account_model.dart';
import '../repositories/auth_repository.dart';

/// Get account by ID use case
class GetAccountByIdUsecase {
  final AuthRepository repository;

  GetAccountByIdUsecase(this.repository);

  Future<CurrentAccountModel> call({
    required String id,
  }) async {
    return await repository.getAccountById(id);
  }
}

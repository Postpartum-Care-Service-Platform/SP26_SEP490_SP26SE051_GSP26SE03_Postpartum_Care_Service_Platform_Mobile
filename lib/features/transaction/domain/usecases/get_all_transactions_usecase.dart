import '../entities/transaction_with_customer_entity.dart';
import '../repositories/transaction_repository.dart';

class GetAllTransactionsUsecase {
  final TransactionRepository repository;

  GetAllTransactionsUsecase(this.repository);

  Future<List<TransactionWithCustomerEntity>> call() {
    return repository.getAllTransactions();
  }
}


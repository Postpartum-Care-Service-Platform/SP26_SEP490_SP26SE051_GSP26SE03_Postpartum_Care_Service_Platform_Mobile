import '../entities/transaction_with_customer_entity.dart';

abstract class TransactionRepository {
  Future<List<TransactionWithCustomerEntity>> getAllTransactions();
}


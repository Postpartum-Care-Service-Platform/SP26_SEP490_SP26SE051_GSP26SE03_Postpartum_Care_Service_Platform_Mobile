import '../../domain/entities/transaction_with_customer_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TransactionWithCustomerEntity>> getAllTransactions() async {
    final models = await remoteDataSource.getAllTransactions();
    return models.map((m) => m.toEntity()).toList();
  }
}


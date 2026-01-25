import '../../domain/entities/contract_entity.dart';
import '../../domain/repositories/contract_repository.dart';
import '../datasources/contract_remote_datasource.dart';

/// Contract Repository Implementation
class ContractRepositoryImpl implements ContractRepository {
  final ContractRemoteDataSource remoteDataSource;

  ContractRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ContractEntity> getContractByBookingId(int bookingId) async {
    final model = await remoteDataSource.getContractByBookingId(bookingId);
    return model.toEntity();
  }

  @override
  Future<List<int>> exportContractPdf(int contractId) async {
    return await remoteDataSource.exportContractPdf(contractId);
  }
}

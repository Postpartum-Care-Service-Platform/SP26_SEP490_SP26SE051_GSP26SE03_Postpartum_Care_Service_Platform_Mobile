import '../entities/contract_entity.dart';
import '../repositories/contract_repository.dart';

/// Use case to get contract by booking ID
class GetContractByBookingIdUsecase {
  final ContractRepository repository;

  GetContractByBookingIdUsecase(this.repository);

  Future<ContractEntity> call(int bookingId) async {
    return await repository.getContractByBookingId(bookingId);
  }
}

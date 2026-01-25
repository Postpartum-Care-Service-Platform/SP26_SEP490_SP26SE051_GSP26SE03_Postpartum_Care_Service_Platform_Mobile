import '../entities/contract_entity.dart';

/// Contract Repository Interface
abstract class ContractRepository {
  /// Get contract by booking ID
  Future<ContractEntity> getContractByBookingId(int bookingId);

  /// Export contract as PDF
  Future<List<int>> exportContractPdf(int contractId);
}

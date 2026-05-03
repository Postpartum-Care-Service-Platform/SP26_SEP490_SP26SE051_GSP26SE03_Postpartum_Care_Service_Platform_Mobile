import '../entities/refund_request_entity.dart';
import '../repositories/refund_request_repository.dart';

/// Usecase to create a refund request for home staff (withdraw)
class CreateHomeStaffWithdrawRequestUseCase {
  final RefundRequestRepository repository;

  CreateHomeStaffWithdrawRequestUseCase({required this.repository});

  Future<List<RefundRequestEntity>> execute({
    required int requestedAmount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  }) {
    return repository.createHomeStaffWithdrawRequest(
      requestedAmount: requestedAmount,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolder: accountHolder,
      reason: reason,
    );
  }
}

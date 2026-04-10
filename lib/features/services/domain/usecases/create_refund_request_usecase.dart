import '../entities/refund_request_entity.dart';
import '../repositories/refund_request_repository.dart';

/// Use case to create a refund request
class CreateRefundRequestUsecase {
  final RefundRequestRepository repository;

  CreateRefundRequestUsecase(this.repository);

  Future<List<RefundRequestEntity>> call({
    required int bookingId,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  }) async {
    return await repository.createRefundRequest(
      bookingId: bookingId,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolder: accountHolder,
      reason: reason,
    );
  }
}

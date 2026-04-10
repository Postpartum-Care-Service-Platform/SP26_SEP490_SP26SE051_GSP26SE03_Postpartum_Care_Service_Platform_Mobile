import '../entities/refund_request_entity.dart';

/// Refund Request repository interface - domain layer
abstract class RefundRequestRepository {
  /// Create a refund request
  Future<List<RefundRequestEntity>> createRefundRequest({
    required int bookingId,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  });

  /// Get my refund requests
  Future<List<RefundRequestEntity>> getMyRefundRequests();
}

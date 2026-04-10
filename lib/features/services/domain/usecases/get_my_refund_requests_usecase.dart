import '../entities/refund_request_entity.dart';
import '../repositories/refund_request_repository.dart';

/// Use case to get my refund requests
class GetMyRefundRequestsUsecase {
  final RefundRequestRepository repository;

  GetMyRefundRequestsUsecase(this.repository);

  Future<List<RefundRequestEntity>> call() async {
    return await repository.getMyRefundRequests();
  }
}

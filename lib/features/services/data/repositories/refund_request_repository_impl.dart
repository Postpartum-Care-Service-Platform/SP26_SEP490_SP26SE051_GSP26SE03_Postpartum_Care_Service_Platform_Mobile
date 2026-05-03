import '../../domain/entities/refund_request_entity.dart';
import '../../domain/repositories/refund_request_repository.dart';
import '../datasources/refund_request_remote_datasource.dart';

/// Implementation of RefundRequestRepository
class RefundRequestRepositoryImpl implements RefundRequestRepository {
  final RefundRequestRemoteDataSource remoteDataSource;

  RefundRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RefundRequestEntity>> createRefundRequest({
    required int bookingId,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  }) async {
    final models = await remoteDataSource.createRefundRequest(
      bookingId: bookingId,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolder: accountHolder,
      reason: reason,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<RefundRequestEntity>> createHomeStaffWithdrawRequest({
    required int requestedAmount,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    required String reason,
  }) async {
    final models = await remoteDataSource.createHomeStaffWithdrawRequest(
      requestedAmount: requestedAmount,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolder: accountHolder,
      reason: reason,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<RefundRequestEntity>> getMyRefundRequests() async {
    final models = await remoteDataSource.getMyRefundRequests();
    return models.map((m) => m.toEntity()).toList();
  }
}

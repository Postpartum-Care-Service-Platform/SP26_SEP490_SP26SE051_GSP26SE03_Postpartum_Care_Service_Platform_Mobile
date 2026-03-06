import '../repositories/home_service_repository.dart';
import '../../../booking/domain/entities/payment_status_entity.dart';

/// Check Payment Status Use Case
class CheckPaymentStatusUsecase {
  final HomeServiceRepository repository;

  CheckPaymentStatusUsecase(this.repository);

  Future<PaymentStatusEntity> call(String orderCode) async {
    return await repository.checkPaymentStatus(orderCode);
  }
}

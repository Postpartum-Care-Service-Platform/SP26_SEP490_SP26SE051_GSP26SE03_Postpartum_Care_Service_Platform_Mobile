import '../entities/payment_status_entity.dart';
import '../repositories/booking_repository.dart';

/// Check Payment Status Use Case
class CheckPaymentStatusUsecase {
  final BookingRepository repository;

  CheckPaymentStatusUsecase(this.repository);

  Future<PaymentStatusEntity> call(String orderCode) async {
    return await repository.checkPaymentStatus(orderCode);
  }
}

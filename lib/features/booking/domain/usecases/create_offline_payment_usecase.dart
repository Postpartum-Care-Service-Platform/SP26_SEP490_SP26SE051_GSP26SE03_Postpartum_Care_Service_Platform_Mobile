import '../entities/payment_status_entity.dart';
import '../repositories/booking_repository.dart';

/// Usecase: Staff ghi nhận thanh toán offline cho booking.
class CreateOfflinePaymentUsecase {
  final BookingRepository repository;

  CreateOfflinePaymentUsecase(this.repository);

  Future<PaymentStatusEntity> call({
    required int bookingId,
    required String customerId,
    required double amount,
    required String paymentMethod,
    String? note,
  }) {
    return repository.createOfflinePayment(
      bookingId: bookingId,
      customerId: customerId,
      amount: amount,
      paymentMethod: paymentMethod,
      note: note,
    );
  }
}


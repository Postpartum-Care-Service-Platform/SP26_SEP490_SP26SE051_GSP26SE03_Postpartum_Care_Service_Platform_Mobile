import '../entities/payment_link_entity.dart';
import '../repositories/booking_repository.dart';

/// Create Payment Link Use Case
class CreatePaymentLinkUsecase {
  final BookingRepository repository;

  CreatePaymentLinkUsecase(this.repository);

  Future<PaymentLinkEntity> call({
    required int bookingId,
    required String type, // Deposit or Remaining
  }) async {
    return await repository.createPaymentLink(
      bookingId: bookingId,
      type: type,
    );
  }
}

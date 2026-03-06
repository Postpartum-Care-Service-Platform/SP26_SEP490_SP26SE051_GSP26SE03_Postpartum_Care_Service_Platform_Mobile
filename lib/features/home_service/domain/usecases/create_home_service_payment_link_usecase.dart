import '../repositories/home_service_repository.dart';
import '../../../booking/domain/entities/payment_link_entity.dart';

/// Create Home Service Payment Link Use Case
class CreateHomeServicePaymentLinkUsecase {
  final HomeServiceRepository repository;

  CreateHomeServicePaymentLinkUsecase(this.repository);

  Future<PaymentLinkEntity> call({
    required int bookingId,
    required String type,
    required String staffId,
  }) async {
    return await repository.createHomeServicePaymentLink(
      bookingId: bookingId,
      type: type,
      staffId: staffId,
    );
  }
}

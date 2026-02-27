import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class CreateBookingForCustomerUsecase {
  final BookingRepository repository;

  CreateBookingForCustomerUsecase(this.repository);

  Future<BookingEntity> call({
    required String customerId,
    required int packageId,
    required int roomId,
    required DateTime startDate,
    double? discountAmount,
  }) async {
    return await repository.createBookingForCustomer(
      customerId: customerId,
      packageId: packageId,
      roomId: roomId,
      startDate: startDate,
      discountAmount: discountAmount,
    );
  }
}


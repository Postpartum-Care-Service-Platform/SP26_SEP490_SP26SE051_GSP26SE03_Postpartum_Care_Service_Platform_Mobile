import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

/// Create Booking Use Case
class CreateBookingUsecase {
  final BookingRepository repository;

  CreateBookingUsecase(this.repository);

  Future<BookingEntity> call({
    required int packageId,
    required int roomId,
    required DateTime startDate,
  }) async {
    return await repository.createBooking(
      packageId: packageId,
      roomId: roomId,
      startDate: startDate,
    );
  }
}

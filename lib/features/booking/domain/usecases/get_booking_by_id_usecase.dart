import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

/// Get Booking By ID Use Case
class GetBookingByIdUsecase {
  final BookingRepository repository;

  GetBookingByIdUsecase(this.repository);

  Future<BookingEntity> call(int id) async {
    return await repository.getBookingById(id);
  }
}

import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

/// Get Bookings Use Case
class GetBookingsUsecase {
  final BookingRepository repository;

  GetBookingsUsecase(this.repository);

  Future<List<BookingEntity>> call() async {
    return await repository.getBookings();
  }
}

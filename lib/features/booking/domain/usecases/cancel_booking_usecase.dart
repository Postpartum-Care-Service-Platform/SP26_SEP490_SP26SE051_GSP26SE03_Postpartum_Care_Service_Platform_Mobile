import '../repositories/booking_repository.dart';

/// Cancel booking use case
class CancelBookingUsecase {
  final BookingRepository repository;

  CancelBookingUsecase(this.repository);

  Future<String> call(int id) async {
    return await repository.cancelBooking(id);
  }
}


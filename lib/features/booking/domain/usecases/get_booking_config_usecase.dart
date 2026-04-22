import '../entities/booking_config_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingConfigUsecase {
  final BookingRepository repository;

  GetBookingConfigUsecase(this.repository);

  Future<BookingConfigEntity> call() async {
    return await repository.getBookingConfig();
  }
}

import '../entities/staff_availability_entity.dart';
import '../repositories/booking_repository.dart';

class CheckStaffAvailabilityUsecase {
  final BookingRepository repository;

  CheckStaffAvailabilityUsecase({required this.repository});

  Future<StaffAvailabilityEntity> call({
    required DateTime from,
    required DateTime to,
  }) async {
    return await repository.checkStaffAvailability(from: from, to: to);
  }
}

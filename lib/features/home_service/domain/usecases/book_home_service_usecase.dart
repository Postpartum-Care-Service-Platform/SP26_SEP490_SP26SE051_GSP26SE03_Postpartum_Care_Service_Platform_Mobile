import '../entities/home_service_booking_entity.dart';
import '../entities/home_service_selection_entity.dart';
import '../repositories/home_service_repository.dart';

/// Book Home Service Use Case
class BookHomeServiceUsecase {
  final HomeServiceRepository repository;

  BookHomeServiceUsecase(this.repository);

  Future<HomeServiceBookingEntity> call({
    required String staffId,
    required List<HomeServiceSelectionEntity> selections,
  }) async {
    return await repository.bookHomeService(
      staffId: staffId,
      selections: selections,
    );
  }
}

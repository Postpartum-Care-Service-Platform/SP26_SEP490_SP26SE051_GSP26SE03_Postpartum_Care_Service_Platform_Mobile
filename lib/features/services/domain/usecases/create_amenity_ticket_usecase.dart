import '../entities/amenity_ticket_entity.dart';
import '../repositories/amenity_repository.dart';

/// Create Amenity Ticket Use Case
class CreateAmenityTicketUsecase {
  final AmenityRepository repository;

  CreateAmenityTicketUsecase(this.repository);

  Future<AmenityTicketEntity> call({
    required int amenityServiceId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    return await repository.createTicket(
      amenityServiceId: amenityServiceId,
      startTime: startTime,
      endTime: endTime,
    );
  }
}

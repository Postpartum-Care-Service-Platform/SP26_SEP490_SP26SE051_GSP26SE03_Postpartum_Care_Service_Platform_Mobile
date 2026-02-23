import '../entities/amenity_ticket_entity.dart';
import '../repositories/amenity_repository.dart';

/// Get My Amenity Tickets Use Case
class GetMyAmenityTicketsUsecase {
  final AmenityRepository repository;

  GetMyAmenityTicketsUsecase(this.repository);

  Future<List<AmenityTicketEntity>> call() async {
    return await repository.getMyTickets();
  }
}

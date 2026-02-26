import '../entities/amenity_service_entity.dart';
import '../entities/amenity_ticket_entity.dart';

/// Amenity Repository Interface - Domain layer
abstract class AmenityRepository {
  /// Get all amenity services
  Future<List<AmenityServiceEntity>> getAmenityServices();

  /// Get my amenity tickets
  Future<List<AmenityTicketEntity>> getMyTickets();

  /// Create amenity ticket
  Future<AmenityTicketEntity> createTicket({
    required int amenityServiceId,
    required DateTime startTime,
    required DateTime endTime,
  });
}

import '../entities/amenity_service_entity.dart';

/// AmenityService Repository Interface
/// Defines contract for amenity service data operations
abstract class AmenityServiceRepository {
  /// Get all amenity services
  /// Returns list of all services
  Future<List<AmenityServiceEntity>> getAllAmenityServices();

  /// Get amenity service by ID
  /// [serviceId] - The ID of the service to retrieve
  /// Returns amenity service entity
  Future<AmenityServiceEntity> getAmenityServiceById(int serviceId);

  /// Get active amenity services
  /// Returns list of active services (isActive = true)
  Future<List<AmenityServiceEntity>> getActiveAmenityServices();
}

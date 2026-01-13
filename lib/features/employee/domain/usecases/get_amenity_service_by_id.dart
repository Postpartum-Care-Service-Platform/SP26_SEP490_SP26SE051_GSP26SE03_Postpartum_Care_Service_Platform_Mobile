import '../entities/amenity_service_entity.dart';
import '../repositories/amenity_service_repository.dart';

/// Use case to get amenity service by ID
class GetAmenityServiceById {
  final AmenityServiceRepository repository;

  GetAmenityServiceById(this.repository);

  /// Execute the use case
  /// [serviceId] - The ID of the service to retrieve
  /// Returns amenity service entity
  Future<AmenityServiceEntity> call(int serviceId) async {
    return await repository.getAmenityServiceById(serviceId);
  }
}

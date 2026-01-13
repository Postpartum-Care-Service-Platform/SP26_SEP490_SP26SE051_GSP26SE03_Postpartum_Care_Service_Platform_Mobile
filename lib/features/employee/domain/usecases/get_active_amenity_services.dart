import '../entities/amenity_service_entity.dart';
import '../repositories/amenity_service_repository.dart';

/// Use case to get active amenity services
class GetActiveAmenityServices {
  final AmenityServiceRepository repository;

  GetActiveAmenityServices(this.repository);

  /// Execute the use case
  /// Returns list of active amenity services
  Future<List<AmenityServiceEntity>> call() async {
    return await repository.getActiveAmenityServices();
  }
}

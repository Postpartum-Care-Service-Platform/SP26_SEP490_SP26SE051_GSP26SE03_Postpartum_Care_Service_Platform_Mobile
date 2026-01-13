import '../entities/amenity_service_entity.dart';
import '../repositories/amenity_service_repository.dart';

/// Use case to get all amenity services
class GetAllAmenityServices {
  final AmenityServiceRepository repository;

  GetAllAmenityServices(this.repository);

  /// Execute the use case
  /// Returns list of all amenity services
  Future<List<AmenityServiceEntity>> call() async {
    return await repository.getAllAmenityServices();
  }
}

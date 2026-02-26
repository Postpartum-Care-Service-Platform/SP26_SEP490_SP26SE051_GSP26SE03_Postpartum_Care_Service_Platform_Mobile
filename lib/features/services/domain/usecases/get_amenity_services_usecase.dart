import '../entities/amenity_service_entity.dart';
import '../repositories/amenity_repository.dart';

/// Get Amenity Services Use Case
class GetAmenityServicesUsecase {
  final AmenityRepository repository;

  GetAmenityServicesUsecase(this.repository);

  Future<List<AmenityServiceEntity>> call() async {
    return await repository.getAmenityServices();
  }
}

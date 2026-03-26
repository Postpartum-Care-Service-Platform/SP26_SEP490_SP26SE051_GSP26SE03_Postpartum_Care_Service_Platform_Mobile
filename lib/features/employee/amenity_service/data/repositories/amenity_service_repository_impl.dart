import '../../domain/entities/amenity_service_entity.dart';
import '../../domain/repositories/amenity_service_repository.dart';
import '../datasources/amenity_service_remote_datasource.dart';

/// Implementation of AmenityServiceRepository
class AmenityServiceRepositoryImpl implements AmenityServiceRepository {
  final AmenityServiceRemoteDataSource remoteDataSource;

  AmenityServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AmenityServiceEntity>> getAllAmenityServices() async {
    try {
      final models = await remoteDataSource.getAllAmenityServices();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AmenityServiceEntity> getAmenityServiceById(int serviceId) async {
    try {
      final model = await remoteDataSource.getAmenityServiceById(serviceId);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityServiceEntity>> getActiveAmenityServices() async {
    try {
      final allServices = await getAllAmenityServices();
      // Filter only active services
      return allServices
          .where((service) => service.isActive)
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

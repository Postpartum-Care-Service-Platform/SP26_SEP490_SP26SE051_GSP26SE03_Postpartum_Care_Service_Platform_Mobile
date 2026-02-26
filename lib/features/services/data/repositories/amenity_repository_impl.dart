import '../../domain/entities/amenity_service_entity.dart';
import '../../domain/entities/amenity_ticket_entity.dart';
import '../../domain/repositories/amenity_repository.dart';
import '../datasources/amenity_remote_datasource.dart';

/// Amenity Repository Implementation - Data layer
class AmenityRepositoryImpl implements AmenityRepository {
  final AmenityRemoteDataSource dataSource;

  AmenityRepositoryImpl({required this.dataSource});

  @override
  Future<List<AmenityServiceEntity>> getAmenityServices() async {
    final models = await dataSource.getAmenityServices();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<AmenityTicketEntity>> getMyTickets() async {
    final models = await dataSource.getMyTickets();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AmenityTicketEntity> createTicket({
    required int amenityServiceId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final model = await dataSource.createTicket(
      amenityServiceId: amenityServiceId,
      startTime: startTime,
      endTime: endTime,
    );
    return model.toEntity();
  }
}

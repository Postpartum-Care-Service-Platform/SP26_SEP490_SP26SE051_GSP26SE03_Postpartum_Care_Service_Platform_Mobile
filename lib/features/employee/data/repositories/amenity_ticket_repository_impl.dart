import '../../domain/entities/amenity_ticket_entity.dart';
import '../../domain/repositories/amenity_ticket_repository.dart';
import '../datasources/amenity_ticket_remote_datasource.dart';
import '../models/create_service_booking_request_model.dart';

/// Implementation of AmenityTicketRepository
class AmenityTicketRepositoryImpl implements AmenityTicketRepository {
  final AmenityTicketRemoteDataSource remoteDataSource;

  AmenityTicketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AmenityTicketEntity>> createBooking({
    required String customerId,
    required List<int> serviceIds,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final request = CreateServiceBookingRequestModel(
        customerId: customerId,
        serviceIds: serviceIds,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      
      final models = await remoteDataSource.createBooking(request);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getTicketsByCustomer(String customerId) async {
    try {
      final models = await remoteDataSource.getTicketsByCustomer(customerId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getMyAssignedTickets() async {
    try {
      final models = await remoteDataSource.getMyAssignedTickets();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getAllTickets() async {
    try {
      final models = await remoteDataSource.getAllTickets();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> cancelTicket(int ticketId) async {
    try {
      return await remoteDataSource.cancelTicket(ticketId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> confirmTicket(int ticketId) async {
    try {
      return await remoteDataSource.confirmTicket(ticketId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> completeTicket(int ticketId) async {
    try {
      return await remoteDataSource.completeTicket(ticketId);
    } catch (e) {
      rethrow;
    }
  }
}

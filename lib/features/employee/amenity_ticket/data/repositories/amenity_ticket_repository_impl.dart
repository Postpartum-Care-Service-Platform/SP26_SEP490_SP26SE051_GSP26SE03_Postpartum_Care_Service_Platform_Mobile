import '../../domain/entities/amenity_ticket_entity.dart';
import '../../domain/repositories/amenity_ticket_repository.dart';
import '../datasources/amenity_ticket_remote_datasource.dart';
import '../models/staff_create_amenity_ticket_request_model.dart';

class AmenityTicketRepositoryImpl implements AmenityTicketRepository {
  final AmenityTicketRemoteDataSource remoteDataSource;

  AmenityTicketRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AmenityTicketEntity> createBooking({
    required String customerId,
    required int amenityServiceId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final request = StaffCreateAmenityTicketRequestModel(
        amenityServiceId: amenityServiceId,
        customerId: customerId,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      
      final model = await remoteDataSource.staffCreateAmenityTicket(request);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getTicketsByCustomer(String customerId) async {
    try {
      final models = await remoteDataSource.getAmenityTicketsByUserId(customerId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getMyAssignedTickets() async {
    try {
      throw UnimplementedError('getMyAssignedTickets chưa có API ở BE');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getAllTickets() async {
    try {
      // Có thể cần filter từ getAmenityTicketsByUserId
      throw UnimplementedError('getAllTickets chỉ dành cho Admin/Manager');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> cancelTicket(int ticketId) async {
    try {
      await remoteDataSource.cancelAmenityTicket(ticketId);
      return 'Hủy ticket thành công';
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> confirmTicket(int ticketId) async {
    try {
      throw UnimplementedError('confirmTicket không có API cho Staff');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> completeTicket(int ticketId) async {
    try {
      throw UnimplementedError('completeTicket chỉ dành cho Manager');
    } catch (e) {
      rethrow;
    }
  }

  /// Update amenity ticket (thêm method mới)
  @override
  Future<AmenityTicketEntity> updateTicket({
    required int ticketId,
    required int amenityServiceId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final request = UpdateAmenityTicketRequestModel(
        amenityServiceId: amenityServiceId,
        startTime: startTime,
        endTime: endTime,
      );
      
      final model = await remoteDataSource.updateAmenityTicket(ticketId, request);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  /// Get ticket by ID (thêm method mới)
  @override
  Future<AmenityTicketEntity> getTicketById(int id) async {
    try {
      final model = await remoteDataSource.getAmenityTicketById(id);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}

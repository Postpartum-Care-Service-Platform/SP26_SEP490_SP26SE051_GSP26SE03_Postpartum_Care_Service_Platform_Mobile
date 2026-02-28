import '../../domain/entities/amenity_ticket_entity.dart';
import '../../domain/repositories/amenity_ticket_repository.dart';
import '../datasources/amenity_ticket_remote_datasource.dart';
import '../models/staff_create_amenity_ticket_request_model.dart';

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
      // BE chỉ nhận 1 service mỗi lần, nên tạo từng ticket riêng
      final List<AmenityTicketEntity> tickets = [];
      
      for (final serviceId in serviceIds) {
        final request = StaffCreateAmenityTicketRequestModel(
          amenityServiceId: serviceId,
          customerId: customerId,
          startTime: startTime,
          endTime: endTime,
        );
        
        final model = await remoteDataSource.staffCreateAmenityTicket(request);
        tickets.add(model.toEntity());
      }
      
      return tickets;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getTicketsByCustomer(String customerId) async {
    try {
      // Dùng API getAmenityTicketsByUserId thay vì getTicketsByCustomer
      final models = await remoteDataSource.getAmenityTicketsByUserId(customerId);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getMyAssignedTickets() async {
    try {
      // TODO: BE chưa có API này, có thể dùng getAmenityTicketsByUserId với staffId
      // Hoặc dùng filter từ getAllTickets
      throw UnimplementedError('getMyAssignedTickets chưa có API ở BE');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AmenityTicketEntity>> getAllTickets() async {
    try {
      // TODO: BE chỉ có API cho Admin/Manager, không có cho Staff
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
      // TODO: BE không có API confirm cho Staff, chỉ có accept/complete cho Manager
      throw UnimplementedError('confirmTicket không có API cho Staff');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> completeTicket(int ticketId) async {
    try {
      // TODO: BE chỉ có API complete cho Manager
      throw UnimplementedError('completeTicket chỉ dành cho Manager');
    } catch (e) {
      rethrow;
    }
  }

  /// Update amenity ticket (thêm method mới)
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
  Future<AmenityTicketEntity> getTicketById(int id) async {
    try {
      final model = await remoteDataSource.getAmenityTicketById(id);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}

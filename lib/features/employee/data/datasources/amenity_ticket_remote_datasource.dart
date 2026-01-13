import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/amenity_ticket_model.dart';
import '../models/create_service_booking_request_model.dart';

/// AmenityTicket Remote Data Source
/// Handles API calls for amenity ticket/booking operations
/// 
/// NOTE: API endpoints chưa có ở Backend, structure này chuẩn bị sẵn
/// Khi BE có API, chỉ cần update endpoints và uncomment code
class AmenityTicketRemoteDataSource {
  final Dio _dio;

  AmenityTicketRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// Create service booking
  /// TODO: Update endpoint khi BE có API
  Future<List<AmenityTicketModel>> createBooking(
    CreateServiceBookingRequestModel request,
  ) async {
    try {
      // TODO: Uncomment khi BE có API
      // Uncomment code below khi BE đã implement API:
      /*
      final response = await _dio.post(
        ApiEndpoints.createServiceBooking,
        data: request.toJson(),
      );
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AmenityTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
      */
      
      // Temporary: Throw error để indicate API chưa có
      throw Exception('Service Booking API chưa có ở Backend. Vui lòng liên hệ BE team để implement endpoint: POST /ServiceBooking');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get tickets by customer
  Future<List<AmenityTicketModel>> getTicketsByCustomer(String customerId) async {
    try {
      // TODO: Uncomment khi BE có API
      /*
      final response = await _dio.get(
        ApiEndpoints.getTicketsByCustomer(customerId),
      );
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AmenityTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
      */
      
      throw Exception('Service Booking API chưa có ở Backend. Vui lòng liên hệ BE team.');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get my assigned tickets
  Future<List<AmenityTicketModel>> getMyAssignedTickets() async {
    try {
      // TODO: Uncomment khi BE có API
      /*
      final response = await _dio.get(ApiEndpoints.myAssignedTickets);
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AmenityTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
      */
      
      throw Exception('Service Booking API chưa có ở Backend. Vui lòng liên hệ BE team.');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all tickets
  Future<List<AmenityTicketModel>> getAllTickets() async {
    try {
      // TODO: Uncomment khi BE có API
      /*
      final response = await _dio.get(ApiEndpoints.allTickets);
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AmenityTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
      */
      
      throw Exception('Service Booking API chưa có ở Backend. Vui lòng liên hệ BE team.');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel ticket
  Future<String> cancelTicket(int ticketId) async {
    try {
      // TODO: Uncomment khi BE có API
      /*
      final response = await _dio.put(
        ApiEndpoints.cancelTicket(ticketId),
      );
      
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Hủy đặt dịch vụ thành công';
      */
      
      throw Exception('Service Booking API chưa có ở Backend. Vui lòng liên hệ BE team.');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Confirm ticket
  Future<String> confirmTicket(int ticketId) async {
    try {
      // TODO: Uncomment khi BE có API
      /*
      final response = await _dio.put(
        ApiEndpoints.confirmTicket(ticketId),
      );
      
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Xác nhận đặt dịch vụ thành công';
      */
      
      throw Exception('Service Booking API chưa có ở Backend. Vui lòng liên hệ BE team.');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete ticket
  Future<String> completeTicket(int ticketId) async {
    try {
      // TODO: Uncomment khi BE có API
      /*
      final response = await _dio.put(
        ApiEndpoints.completeTicket(ticketId),
      );
      
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Hoàn thành dịch vụ thành công';
      */
      
      throw Exception('Service Booking API chưa có ở Backend. Vui lòng liên hệ BE team.');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors
  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'Có lỗi xảy ra';
      
      if (data is Map<String, dynamic>) {
        message = data['error'] as String? ?? 
                  data['message'] as String? ?? 
                  message;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return 'Dữ liệu không hợp lệ: $message';
        case 401:
          return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
        case 403:
          return 'Bạn không có quyền thực hiện thao tác này.';
        case 404:
          return 'Không tìm thấy đặt dịch vụ.';
        case 500:
          return 'Lỗi server: $message';
        default:
          return message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối timeout. Vui lòng thử lại.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    }

    return 'Có lỗi xảy ra: ${error.message}';
  }
}

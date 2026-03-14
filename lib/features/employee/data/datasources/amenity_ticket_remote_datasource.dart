import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/amenity_ticket_model.dart';
import '../models/staff_create_amenity_ticket_request_model.dart';

/// AmenityTicket Remote Data Source
/// Handles API calls for amenity ticket/booking operations
class AmenityTicketRemoteDataSource {
  final Dio _dio;

  AmenityTicketRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// Staff tạo ticket tiện ích cho khách hàng
  /// Lưu ý: BE chỉ nhận 1 service mỗi lần, nếu cần tạo nhiều ticket thì gọi nhiều lần
  Future<AmenityTicketModel> staffCreateAmenityTicket(
    StaffCreateAmenityTicketRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.staffCreateAmenityTicket,
        data: request.toJson(),
      );
      
      final data = response.data as Map<String, dynamic>;
      return AmenityTicketModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Staff/Customer cập nhật ticket tiện ích
  Future<AmenityTicketModel> updateAmenityTicket(
    int ticketId,
    UpdateAmenityTicketRequestModel request,
  ) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.updateAmenityTicket(ticketId),
        data: request.toJson(),
      );
      
      final data = response.data as Map<String, dynamic>;
      return AmenityTicketModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Staff/Customer hủy ticket tiện ích
  Future<AmenityTicketModel> cancelAmenityTicket(int ticketId) async {
    try {
      final response = await _dio.patch(
        ApiEndpoints.cancelAmenityTicket(ticketId),
      );
      
      final data = response.data as Map<String, dynamic>;
      return AmenityTicketModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy ticket tiện ích theo ID
  Future<AmenityTicketModel> getAmenityTicketById(int id) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getAmenityTicketById(id),
      );
      
      final data = response.data as Map<String, dynamic>;
      return AmenityTicketModel.fromJson(data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Lấy tất cả ticket tiện ích của user theo UserId (Admin/Manager)
  Future<List<AmenityTicketModel>> getAmenityTicketsByUserId(String userId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.getAmenityTicketsByUserId(userId),
      );
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AmenityTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
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

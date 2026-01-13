import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/appointment_model.dart';
import '../models/create_appointment_request_model.dart';

/// Appointment Remote Data Source for Employee
/// Handles API calls for appointment operations
class AppointmentEmployeeRemoteDataSource {
  final Dio _dio;

  AppointmentEmployeeRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// Get appointments assigned to current staff
  Future<List<AppointmentModel>> getMyAssignedAppointments() async {
    try {
      final response = await _dio.get(ApiEndpoints.myAssignedAppointments);
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all appointments (for staff/admin)
  Future<List<AppointmentModel>> getAllAppointments() async {
    try {
      final response = await _dio.get(ApiEndpoints.allAppointments);
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get appointment by ID
  Future<AppointmentModel> getAppointmentById(int appointmentId) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.appointmentById(appointmentId),
      );
      
      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Confirm appointment (staff confirms)
  Future<String> confirmAppointment(int appointmentId) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.confirmAppointment(appointmentId),
      );
      
      // API returns { "message": "..." }
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Xác nhận lịch hẹn thành công';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete appointment (mark as completed)
  Future<String> completeAppointment(int appointmentId) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.completeAppointment(appointmentId),
      );
      
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Hoàn thành lịch hẹn thành công';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel appointment
  Future<String> cancelAppointment(int appointmentId) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.cancelAppointment(appointmentId),
      );
      
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Hủy lịch hẹn thành công';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create appointment for customer (staff creates)
  Future<AppointmentModel> createAppointmentForCustomer(
    CreateAppointmentForCustomerRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.createAppointmentForCustomer,
        data: request.toJson(),
      );
      
      return AppointmentModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to readable messages
  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // Try to extract error message from response
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
          return 'Không tìm thấy lịch hẹn.';
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

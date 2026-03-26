import 'package:dio/dio.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/apis/api_endpoints.dart';
import '../../../../../features/auth/data/models/current_account_model.dart';
import '../../../../../features/services/data/models/menu_record_model.dart';

class EmployeeCustomerProfileRemoteDataSource {
  final Dio _dio;

  EmployeeCustomerProfileRemoteDataSource({Dio? dio})
      : _dio = dio ?? ApiClient.dio;

  Future<List<MenuRecordModel>> getMenuRecordsByCustomer(String customerId) async {
    try {
      final response = await _dio.get(ApiEndpoints.menuRecordsByCustomer(customerId));
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu menu record không hợp lệ');
      }

      return data
          .map((item) => MenuRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<MenuRecordModel>> getMenuRecordsByCustomerDate({
    required String customerId,
    required DateTime date,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.menuRecordsByCustomerDate(customerId),
        queryParameters: {'date': _formatDate(date)},
      );
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu menu record theo ngày không hợp lệ');
      }

      return data
          .map((item) => MenuRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<MenuRecordModel>> getMenuRecordsByCustomerDateRange({
    required String customerId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.menuRecordsByCustomerDateRange(customerId),
        queryParameters: {
          'from': _formatDate(from),
          'to': _formatDate(to),
        },
      );
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu menu record theo khoảng ngày không hợp lệ');
      }

      return data
          .map((item) => MenuRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<MenuRecordModel>> createMenuRecordsByStaff({
    required String customerId,
    required List<Map<String, dynamic>> requests,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.menuRecordsByStaff,
        queryParameters: {'customerId': customerId},
        data: requests,
      );
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu tạo menu record không hợp lệ');
      }

      return data
          .map((item) => MenuRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<MenuRecordModel>> updateMenuRecordsByStaff({
    required String customerId,
    required List<Map<String, dynamic>> requests,
  }) async {
    try {
      final response = await _dio.put(
        ApiEndpoints.menuRecordsByStaff,
        queryParameters: {'customerId': customerId},
        data: requests,
      );
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu cập nhật menu record không hợp lệ');
      }

      return data
          .map((item) => MenuRecordModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<MenuRecordModel> deleteMenuRecordByStaff({
    required int menuRecordId,
    required String customerId,
  }) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.menuRecordByStaffId(menuRecordId),
        queryParameters: {'customerId': customerId},
      );
      return MenuRecordModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getBookingsByCustomer(
    String customerId,
  ) async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllBookings);
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu booking không hợp lệ');
      }

      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => _extractCustomerId(item) == customerId)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAppointmentsByCustomer(
    String customerId,
  ) async {
    try {
      final response = await _dio.get(ApiEndpoints.allAppointments);
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu appointment không hợp lệ');
      }

      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => _extractCustomerId(item) == customerId)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionsByCustomer(
    String customerId,
  ) async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllTransactions);
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu giao dịch không hợp lệ');
      }

      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => _extractCustomerId(item) == customerId)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMedicalRecordsByCustomer(
    String customerId,
  ) async {
    try {
      final response = await _dio.get(ApiEndpoints.medicalRecordsByCustomer(customerId));
      final data = response.data;

      if (data is! List) {
        throw Exception('Dữ liệu hồ sơ y tế không hợp lệ');
      }

      return data
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<CurrentAccountModel> getAccountById(String customerId) async {
    try {
      final response = await _dio.get(ApiEndpoints.getAccountById(customerId));
      return CurrentAccountModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _formatDate(DateTime value) => value.toIso8601String().split('T').first;

  String? _extractCustomerId(Map<String, dynamic> item) {
    final direct = item['customerId'];
    if (direct is String && direct.isNotEmpty) {
      return direct;
    }

    final customer = item['customer'];
    if (customer is Map) {
      final nested = customer['id'];
      if (nested is String && nested.isNotEmpty) {
        return nested;
      }
    }

    return null;
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'Có lỗi xảy ra';
      if (data is Map<String, dynamic>) {
        message = data['error'] as String? ?? data['message'] as String? ?? message;
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
          return 'Không tìm thấy dữ liệu.';
        case 500:
          return 'Lỗi server: $message';
        default:
          return message;
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối timeout. Vui lòng thử lại.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    }

    return 'Có lỗi xảy ra: ${error.message}';
  }
}

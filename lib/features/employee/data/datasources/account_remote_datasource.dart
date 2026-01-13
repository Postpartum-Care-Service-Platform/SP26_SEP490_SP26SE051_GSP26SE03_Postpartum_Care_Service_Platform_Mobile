import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/account_model.dart';

/// Account Remote Data Source for customer selection
class AccountRemoteDataSource {
  final Dio _dio;

  AccountRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// Get all accounts (for customer selection)
  Future<List<AccountModel>> getAllAccounts() async {
    try {
      final response = await _dio.get(ApiEndpoints.getAllAccounts);
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AccountModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get customers only (filter by role)
  Future<List<AccountModel>> getCustomers() async {
    try {
      final allAccounts = await getAllAccounts();
      // Filter only customers
      return allAccounts.where((account) => account.isCustomer).toList();
    } catch (e) {
      rethrow;
    }
  }

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
          return 'Không tìm thấy tài khoản.';
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

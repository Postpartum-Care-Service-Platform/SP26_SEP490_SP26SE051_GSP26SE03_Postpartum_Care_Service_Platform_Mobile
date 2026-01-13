import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/amenity_service_model.dart';

/// AmenityService Remote Data Source
/// Handles API calls for amenity service operations
class AmenityServiceRemoteDataSource {
  final Dio _dio;

  AmenityServiceRemoteDataSource({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  /// Get all amenity services
  Future<List<AmenityServiceModel>> getAllAmenityServices() async {
    try {
      final response = await _dio.get(ApiEndpoints.amenityServices);
      
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AmenityServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get amenity service by ID
  Future<AmenityServiceModel> getAmenityServiceById(int serviceId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.amenityServices}/$serviceId');
      
      return AmenityServiceModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Handle Dio errors and convert to readable messages
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
          return 'Không tìm thấy dịch vụ.';
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

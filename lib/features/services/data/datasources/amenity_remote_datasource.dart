import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/amenity_service_model.dart';
import '../models/amenity_ticket_model.dart';

/// Amenity Remote Data Source Interface
abstract class AmenityRemoteDataSource {
  Future<List<AmenityServiceModel>> getAmenityServices();
  Future<List<AmenityTicketModel>> getMyTickets();
  Future<AmenityTicketModel> createTicket({
    required int amenityServiceId,
    required DateTime startTime,
    required DateTime endTime,
  });
}

/// Amenity Remote Data Source Implementation
class AmenityRemoteDataSourceImpl implements AmenityRemoteDataSource {
  final Dio dio;

  AmenityRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<AmenityServiceModel>> getAmenityServices() async {
    try {
      final response = await dio.get(ApiEndpoints.amenityServices);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AmenityServiceModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<AmenityTicketModel>> getMyTickets() async {
    try {
      final response = await dio.get(ApiEndpoints.myAmenityTickets);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => AmenityTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
Future<AmenityTicketModel> createTicket({
  required int amenityServiceId,
  required DateTime startTime,
  required DateTime endTime,
}) async {
  try {
    // Định dạng dữ liệu theo yêu cầu API mới
    final String dateStr = "${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}";
    final String startStr = "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00";
    final String endStr = "${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00";

    final response = await dio.post(
      ApiEndpoints.createAmenityTicket,
      data: {
        'amenityServiceId': amenityServiceId,
        'date': dateStr,
        'startTime': startStr,
        'endTime': endStr,
      },
    );
    return AmenityTicketModel.fromJson(response.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw _handleError(e);
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
          return 'Không tìm thấy dữ liệu.';
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

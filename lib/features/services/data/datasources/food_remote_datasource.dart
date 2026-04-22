import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/food_model.dart';

/// Food Remote Data Source Interface
abstract class FoodRemoteDataSource {
  Future<List<FoodModel>> getFoods();
}

/// Food Remote Data Source Implementation
class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  final Dio dio;

  FoodRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<FoodModel>> getFoods() async {
    try {
      final response = await dio.get(ApiEndpoints.foods);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => FoodModel.fromJson(json as Map<String, dynamic>))
          .toList();
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

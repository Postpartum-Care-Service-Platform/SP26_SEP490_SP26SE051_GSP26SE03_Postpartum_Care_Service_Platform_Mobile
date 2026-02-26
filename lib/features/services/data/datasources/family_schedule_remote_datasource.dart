import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/family_schedule_model.dart';

/// Family Schedule Remote Data Source Interface
abstract class FamilyScheduleRemoteDataSource {
  Future<List<FamilyScheduleModel>> getMySchedules();
  Future<List<FamilyScheduleModel>> getMySchedulesByDate(String date);
}

/// Family Schedule Remote Data Source Implementation
class FamilyScheduleRemoteDataSourceImpl
    implements FamilyScheduleRemoteDataSource {
  final Dio dio;

  FamilyScheduleRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<FamilyScheduleModel>> getMySchedules() async {
    try {
      final response = await dio.get(ApiEndpoints.familyScheduleMySchedules);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              FamilyScheduleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<FamilyScheduleModel>> getMySchedulesByDate(String date) async {
    try {
      // Format date as YYYY-MM-DD
      final formattedDate = date;
      final response = await dio.get(
        ApiEndpoints.familyScheduleByDate(formattedDate),
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              FamilyScheduleModel.fromJson(json as Map<String, dynamic>))
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

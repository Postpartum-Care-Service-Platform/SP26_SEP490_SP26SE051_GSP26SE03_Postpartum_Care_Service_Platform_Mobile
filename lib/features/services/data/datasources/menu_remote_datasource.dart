import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/menu_model.dart';
import '../models/menu_type_model.dart';
import '../models/menu_record_model.dart';

/// Menu Remote Data Source Interface
abstract class MenuRemoteDataSource {
  Future<List<MenuModel>> getMenus();
  Future<List<MenuTypeModel>> getMenuTypes();
  Future<List<MenuRecordModel>> getMyMenuRecords();
  Future<List<MenuRecordModel>> getMyMenuRecordsByDate(DateTime date);
  Future<List<MenuRecordModel>> createMenuRecords(
    List<Map<String, dynamic>> requests,
  );

  Future<List<MenuRecordModel>> updateMenuRecords(
    List<Map<String, dynamic>> requests,
  );

  Future<MenuRecordModel> deleteMenuRecord(int id);
}

/// Menu Remote Data Source Implementation
class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;

  MenuRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<MenuModel>> getMenus() async {
    try {
      final response = await dio.get(ApiEndpoints.menus);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => MenuModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<MenuTypeModel>> getMenuTypes() async {
    try {
      final response = await dio.get(ApiEndpoints.menuTypes);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => MenuTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<MenuRecordModel>> getMyMenuRecords() async {
    try {
      final response = await dio.get(ApiEndpoints.myMenuRecords);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              MenuRecordModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<MenuRecordModel>> getMyMenuRecordsByDate(DateTime date) async {
    try {
      final dateStr = date.toIso8601String().split('T')[0];
      final response = await dio.get(
        ApiEndpoints.myMenuRecordsByDate,
        queryParameters: {'date': dateStr},
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              MenuRecordModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<MenuRecordModel>> createMenuRecords(
    List<Map<String, dynamic>> requests,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createMenuRecord,
        data: requests,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              MenuRecordModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<MenuRecordModel>> updateMenuRecords(
    List<Map<String, dynamic>> requests,
  ) async {
    try {
      final response = await dio.put(
        ApiEndpoints.updateMenuRecord,
        data: requests,
      );
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              MenuRecordModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<MenuRecordModel> deleteMenuRecord(int id) async {
    try {
      final response = await dio.delete(ApiEndpoints.deleteMenuRecord(id));
      return MenuRecordModel.fromJson(response.data as Map<String, dynamic>);
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

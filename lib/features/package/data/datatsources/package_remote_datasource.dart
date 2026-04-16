import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../../../features/auth/data/models/current_account_model.dart';
import '../models/package_model.dart';

/// Package remote data source interface
abstract class PackageRemoteDataSource {
  Future<List<PackageModel>> getPackages();
  Future<PackageModel> getPackageById(int id);
  Future<NowPackageModel> getNowPackage();
}

/// Package remote data source implementation
class PackageRemoteDataSourceImpl implements PackageRemoteDataSource {
  final Dio dio;

  // Fast-fix cache trong phiên app để giảm phụ thuộc API khi mạng/server chậm.
  static List<PackageModel>? _memoryPackagesCache;

  PackageRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<PackageModel>> getPackages() async {
    Future<Response<dynamic>> requestOnce() {
      return dio.get(
        ApiEndpoints.packages,
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 90),
        ),
      );
    }

    try {
      final response = await requestOnce();

      final List<dynamic> data = response.data as List<dynamic>;
      final packages = data
          .map((json) => PackageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _memoryPackagesCache = packages;
      return packages;
    } on DioException catch (e) {
      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;

      if (isTimeout) {
        try {
          final retryResponse = await requestOnce();
          final List<dynamic> retryData = retryResponse.data as List<dynamic>;
          final retryPackages = retryData
              .map((json) => PackageModel.fromJson(json as Map<String, dynamic>))
              .toList();

          _memoryPackagesCache = retryPackages;
          return retryPackages;
        } on DioException catch (retryError) {
          if (_memoryPackagesCache != null) {
            return _memoryPackagesCache!;
          }

          if (retryError.response != null) {
            throw Exception(
              'Tải danh sách gói dịch vụ thất bại: ${retryError.response?.statusCode}',
            );
          }
          throw Exception('Kết nối tới máy chủ chậm. Vui lòng thử lại sau ít phút.');
        }
      }

      if (_memoryPackagesCache != null) {
        return _memoryPackagesCache!;
      }

      if (e.response != null) {
        throw Exception('Tải danh sách gói dịch vụ thất bại: ${e.response?.statusCode}');
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không mong muốn: $e');
    }
  }

  @override
  Future<PackageModel> getPackageById(int id) async {
    try {
      final response = await dio.get(ApiEndpoints.packageById(id));
      return PackageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Tải chi tiết gói dịch vụ thất bại: ${e.response?.statusCode}');
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không mong muốn: $e');
    }
  }

  @override
  Future<NowPackageModel> getNowPackage() async {
    try {
      final response = await dio.get(ApiEndpoints.nowPackage);
      return NowPackageModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Tải gói dịch vụ hiện tại thất bại: ${e.response?.statusCode}');
      }
      throw Exception('Lỗi kết nối mạng: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không mong muốn: $e');
    }
  }
}

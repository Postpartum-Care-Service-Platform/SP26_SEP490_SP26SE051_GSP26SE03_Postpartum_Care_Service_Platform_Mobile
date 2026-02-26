import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/package_type_model.dart';

/// Package Type remote data source interface
abstract class PackageTypeRemoteDataSource {
  Future<List<PackageTypeModel>> getPackageTypes();
}

/// Package Type remote data source implementation
class PackageTypeRemoteDataSourceImpl implements PackageTypeRemoteDataSource {
  final Dio dio;

  PackageTypeRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<PackageTypeModel>> getPackageTypes() async {
    try {
      final response = await dio.get(
        ApiEndpoints.packageTypes,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => PackageTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load package types: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

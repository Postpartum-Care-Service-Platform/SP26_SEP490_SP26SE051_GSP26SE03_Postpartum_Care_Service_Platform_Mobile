import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/package_model.dart';

/// Package remote data source interface
abstract class PackageRemoteDataSource {
  Future<List<PackageModel>> getPackages();
}

/// Package remote data source implementation
class PackageRemoteDataSourceImpl implements PackageRemoteDataSource {
  final Dio dio;

  PackageRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<PackageModel>> getPackages() async {
    try {
      final response = await dio.get(
        ApiEndpoints.packages,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => PackageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load packages: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

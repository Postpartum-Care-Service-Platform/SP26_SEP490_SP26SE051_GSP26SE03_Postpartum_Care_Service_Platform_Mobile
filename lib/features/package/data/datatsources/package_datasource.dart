import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/package_model.dart';

/// Package data source interface
abstract class PackageDataSource {
  Future<List<PackageModel>> getPackages();
}

/// Package data source implementation
class PackageDataSourceImpl implements PackageDataSource {
  final Dio dio;

  PackageDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

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

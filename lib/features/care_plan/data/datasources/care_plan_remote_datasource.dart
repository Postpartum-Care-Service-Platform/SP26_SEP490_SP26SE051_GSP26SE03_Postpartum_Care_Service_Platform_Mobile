import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/care_plan_model.dart';

/// Care Plan Remote Data Source interface
abstract class CarePlanRemoteDataSource {
  Future<List<CarePlanModel>> getCarePlanDetailsByPackage(int packageId);
  Future<CarePlanModel> getCarePlanActivityById(int id);
}

/// Care Plan Remote Data Source implementation
class CarePlanRemoteDataSourceImpl implements CarePlanRemoteDataSource {
  final Dio dio;

  CarePlanRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<CarePlanModel>> getCarePlanDetailsByPackage(int packageId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getCarePlanDetailsByPackage(packageId),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => CarePlanModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load care plan details: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<CarePlanModel> getCarePlanActivityById(int id) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getCarePlanActivityById(id),
      );

      return CarePlanModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to load activity detail: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

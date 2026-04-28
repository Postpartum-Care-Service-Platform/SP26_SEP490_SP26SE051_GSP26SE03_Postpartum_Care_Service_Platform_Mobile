import 'package:dio/dio.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../domain/entities/health_record_entity.dart';
import '../../domain/repositories/health_record_repository.dart';
import '../models/create_health_record_request.dart';
import '../models/health_record_model.dart';

class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final Dio dio;

  HealthRecordRepositoryImpl({required this.dio});

  dynamic _extractData(Response response) {
    if (response.data is Map<String, dynamic> && response.data.containsKey('data')) {
      return response.data['data'];
    }
    return response.data;
  }

  @override
  Future<List<HealthRecordEntity>> getHealthRecordsByFamilyProfile(int familyProfileId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getHealthRecordsByFamilyProfile(familyProfileId),
      );
      final List<dynamic> data = _extractData(response) as List<dynamic>;
      final models = data.map((json) => HealthRecordModel.fromJson(json as Map<String, dynamic>)).toList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load health records: $e');
    }
  }

  @override
  Future<List<HealthConditionEntity>> getHealthConditions() async {
    try {
      final response = await dio.get(ApiEndpoints.getHealthConditions);
      final List<dynamic> data = _extractData(response) as List<dynamic>;
      final models = data.map((json) => HealthConditionModel.fromJson(json as Map<String, dynamic>)).toList();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to load health conditions: $e');
    }
  }

  @override
  Future<HealthRecordEntity> createHealthRecord(int familyProfileId, CreateHealthRecordRequest request) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createHealthRecord(familyProfileId),
        data: request.toJson(),
      );
      final model = HealthRecordModel.fromJson(_extractData(response) as Map<String, dynamic>);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to create health record: $e');
    }
  }

  @override
  Future<HealthRecordEntity> getLatestHealthRecord(int familyProfileId) async {
    try {
      final response = await dio.get(ApiEndpoints.getLatestHealthRecord(familyProfileId));
      final model = HealthRecordModel.fromJson(_extractData(response) as Map<String, dynamic>);
      return model.toEntity();
    } on DioException catch (e) {
      if (e.response?.statusCode == 500) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          final errorMsg = data['error'].toString();
          if (errorMsg.contains('Chưa có health record nào')) {
            throw Exception('NO_HEALTH_RECORD');
          }
        }
      }
      throw Exception('Failed to load latest health record: $e');
    } catch (e) {
      throw Exception('Failed to load latest health record: $e');
    }
  }

  @override
  Future<HealthRecordEntity> getHealthRecordById(int id) async {
    try {
      final response = await dio.get(ApiEndpoints.getHealthRecordById(id));
      final model = HealthRecordModel.fromJson(_extractData(response) as Map<String, dynamic>);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to load health record: $e');
    }
  }

  @override
  Future<HealthRecordEntity> updateHealthRecord(int id, CreateHealthRecordRequest request) async {
    try {
      final response = await dio.put(
        ApiEndpoints.updateHealthRecord(id),
        data: request.toJson(),
      );
      final model = HealthRecordModel.fromJson(_extractData(response) as Map<String, dynamic>);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to update health record: $e');
    }
  }
}

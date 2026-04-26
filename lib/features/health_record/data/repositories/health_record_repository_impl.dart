import 'package:dio/dio.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../domain/entities/health_record_entity.dart';
import '../../domain/repositories/health_record_repository.dart';
import '../models/create_health_record_request.dart';
import '../models/health_record_model.dart';

class HealthRecordRepositoryImpl implements HealthRecordRepository {
  final Dio dio;

  HealthRecordRepositoryImpl({required this.dio});

  @override
  Future<List<HealthRecordEntity>> getHealthRecordsByFamilyProfile(int familyProfileId) async {
    try {
      final response = await dio.get(
        ApiEndpoints.getHealthRecordsByFamilyProfile(familyProfileId),
      );
      final List<dynamic> data = response.data as List<dynamic>;
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
      final List<dynamic> data = response.data as List<dynamic>;
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
      final model = HealthRecordModel.fromJson(response.data as Map<String, dynamic>);
      return model.toEntity();
    } catch (e) {
      throw Exception('Failed to create health record: $e');
    }
  }
}

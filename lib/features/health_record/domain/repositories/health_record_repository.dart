import '../entities/health_record_entity.dart';
import '../../data/models/create_health_record_request.dart';

abstract class HealthRecordRepository {
  Future<List<HealthRecordEntity>> getHealthRecordsByFamilyProfile(
    int familyProfileId, {
    DateTime? fromDate,
    DateTime? toDate,
  });
  Future<List<HealthConditionEntity>> getHealthConditions({int? categoryId, int? memberTypeId});
  Future<HealthRecordEntity> createHealthRecord(int familyProfileId, CreateHealthRecordRequest request);
  Future<HealthRecordEntity> getLatestHealthRecord(int familyProfileId);
  Future<HealthRecordEntity> getHealthRecordById(int id);
  Future<HealthRecordEntity> updateHealthRecord(int id, CreateHealthRecordRequest request);
}

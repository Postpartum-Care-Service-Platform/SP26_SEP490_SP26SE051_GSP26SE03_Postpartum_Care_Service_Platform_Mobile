import '../entities/family_schedule_entity.dart';

/// Family Schedule Repository Interface - Domain layer
abstract class FamilyScheduleRepository {
  /// Get my family schedules
  Future<List<FamilyScheduleEntity>> getMySchedules();
  
  /// Get my family schedules by date (format: YYYY-MM-DD)
  Future<List<FamilyScheduleEntity>> getMySchedulesByDate(String date);
}

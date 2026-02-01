import '../entities/family_schedule_entity.dart';

/// Family Schedule Repository Interface - Domain layer
abstract class FamilyScheduleRepository {
  /// Get my family schedules
  Future<List<FamilyScheduleEntity>> getMySchedules();
}

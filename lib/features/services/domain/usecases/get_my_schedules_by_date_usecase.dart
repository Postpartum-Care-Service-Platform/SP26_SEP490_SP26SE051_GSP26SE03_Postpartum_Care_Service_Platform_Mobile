import '../entities/family_schedule_entity.dart';
import '../repositories/family_schedule_repository.dart';

/// Get My Schedules By Date Use Case
class GetMySchedulesByDateUsecase {
  final FamilyScheduleRepository repository;

  GetMySchedulesByDateUsecase(this.repository);

  /// Get schedules for a specific date
  /// Date format: YYYY-MM-DD (e.g., "2026-02-21")
  Future<List<FamilyScheduleEntity>> call(String date) async {
    return await repository.getMySchedulesByDate(date);
  }
}

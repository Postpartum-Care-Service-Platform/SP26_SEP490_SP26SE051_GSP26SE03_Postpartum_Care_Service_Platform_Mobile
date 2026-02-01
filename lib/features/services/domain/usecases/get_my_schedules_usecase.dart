import '../entities/family_schedule_entity.dart';
import '../repositories/family_schedule_repository.dart';

/// Get My Schedules Use Case
class GetMySchedulesUsecase {
  final FamilyScheduleRepository repository;

  GetMySchedulesUsecase(this.repository);

  Future<List<FamilyScheduleEntity>> call() async {
    return await repository.getMySchedules();
  }
}

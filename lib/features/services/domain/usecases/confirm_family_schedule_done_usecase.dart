import '../entities/family_schedule_entity.dart';
import '../repositories/family_schedule_repository.dart';

/// Confirm Family Schedule Done Use Case
class ConfirmFamilyScheduleDoneUsecase {
  final FamilyScheduleRepository repository;

  ConfirmFamilyScheduleDoneUsecase(this.repository);

  Future<FamilyScheduleEntity> call(int scheduleId) async {
    return await repository.confirmScheduleDone(scheduleId);
  }
}

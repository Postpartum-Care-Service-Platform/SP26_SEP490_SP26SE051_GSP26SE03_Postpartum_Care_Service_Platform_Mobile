import '../entities/staff_schedule_entity.dart';
import '../repositories/staff_schedule_repository.dart';

/// Get Staff Schedules By Date Range Usecase
class GetMyStaffSchedulesByDateRangeUsecase {
  final StaffScheduleRepository repository;

  GetMyStaffSchedulesByDateRangeUsecase(this.repository);

  Future<List<StaffScheduleEntity>> call({
    required String from,
    required String to,
  }) async {
    return repository.getMySchedulesByDateRange(from: from, to: to);
  }
}

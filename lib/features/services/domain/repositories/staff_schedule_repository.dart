import '../entities/staff_schedule_entity.dart';

/// Staff Schedule Repository Interface
abstract class StaffScheduleRepository {
  Future<List<StaffScheduleEntity>> getMySchedulesByDateRange({
    required String from,
    required String to,
  });
}

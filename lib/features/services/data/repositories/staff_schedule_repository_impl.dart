import '../../domain/entities/staff_schedule_entity.dart';
import '../../domain/repositories/staff_schedule_repository.dart';
import '../datasources/staff_schedule_remote_datasource.dart';

/// Staff Schedule Repository Implementation
class StaffScheduleRepositoryImpl implements StaffScheduleRepository {
  final StaffScheduleRemoteDataSource remoteDataSource;

  StaffScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StaffScheduleEntity>> getMySchedulesByDateRange({
    required String from,
    required String to,
  }) async {
    final models = await remoteDataSource.getMySchedulesByDateRange(
      from: from,
      to: to,
    );
    return models.map((model) => model.toEntity()).toList();
  }
}

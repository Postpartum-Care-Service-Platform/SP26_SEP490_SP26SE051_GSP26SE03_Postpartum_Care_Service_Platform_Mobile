import '../../domain/entities/family_schedule_entity.dart';
import '../../domain/repositories/family_schedule_repository.dart';
import '../datasources/family_schedule_remote_datasource.dart';

/// Family Schedule Repository Implementation
class FamilyScheduleRepositoryImpl implements FamilyScheduleRepository {
  final FamilyScheduleRemoteDataSource remoteDataSource;

  FamilyScheduleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FamilyScheduleEntity>> getMySchedules() async {
    final models = await remoteDataSource.getMySchedules();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<FamilyScheduleEntity>> getMySchedulesByDate(String date) async {
    final models = await remoteDataSource.getMySchedulesByDate(date);
    return models.map((model) => model.toEntity()).toList();
  }
}

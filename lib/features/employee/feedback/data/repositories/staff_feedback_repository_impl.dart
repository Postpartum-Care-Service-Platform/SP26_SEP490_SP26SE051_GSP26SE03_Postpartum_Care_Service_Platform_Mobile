import '../../domain/entities/staff_feedback_entity.dart';
import '../../domain/repositories/staff_feedback_repository.dart';
import '../datasources/staff_feedback_remote_datasource.dart';

class StaffFeedbackRepositoryImpl implements StaffFeedbackRepository {
  final StaffFeedbackRemoteDataSource remoteDataSource;

  StaffFeedbackRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<StaffFeedbackEntity>> getMyFeedbacksForStaff() async {
    return await remoteDataSource.getMyFeedbacksForStaff();
  }
}

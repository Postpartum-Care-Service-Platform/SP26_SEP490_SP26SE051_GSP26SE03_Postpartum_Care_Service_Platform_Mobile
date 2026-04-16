import '../entities/staff_feedback_entity.dart';
import '../repositories/staff_feedback_repository.dart';

class GetMyFeedbacksForStaffUseCase {
  final StaffFeedbackRepository repository;

  GetMyFeedbacksForStaffUseCase(this.repository);

  Future<List<StaffFeedbackEntity>> call() async {
    return await repository.getMyFeedbacksForStaff();
  }
}

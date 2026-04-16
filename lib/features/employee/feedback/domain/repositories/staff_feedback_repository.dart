import '../entities/staff_feedback_entity.dart';

abstract class StaffFeedbackRepository {
  Future<List<StaffFeedbackEntity>> getMyFeedbacksForStaff();
}

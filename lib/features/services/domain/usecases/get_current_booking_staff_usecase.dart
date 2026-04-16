import '../../../auth/domain/entities/staff_entity.dart';
import '../repositories/feedback_repository.dart';

/// Get current booking staff members usecase
class GetCurrentBookingStaffUsecase {
  final FeedbackRepository repository;

  GetCurrentBookingStaffUsecase(this.repository);

  Future<List<StaffEntity>> call() async {
    return await repository.getCurrentBookingStaff();
  }
}

import '../entities/feedback_entity.dart';
import '../repositories/feedback_repository.dart';
import '../../presentation/bloc/feedback_event.dart';

/// Get My Feedbacks Use Case
class GetMyFeedbacksUsecase {
  final FeedbackRepository repository;

  GetMyFeedbacksUsecase(this.repository);

  Future<List<FeedbackEntity>> call({
    FeedbackLoadScope scope = FeedbackLoadScope.service,
  }) async {
    if (scope == FeedbackLoadScope.profile) {
      return await repository.getFullFeedbacks();
    }
    return await repository.getMyFeedbacks();
  }
}

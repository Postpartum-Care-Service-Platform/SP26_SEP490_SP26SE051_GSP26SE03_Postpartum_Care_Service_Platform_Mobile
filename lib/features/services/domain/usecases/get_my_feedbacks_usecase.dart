import '../entities/feedback_entity.dart';
import '../repositories/feedback_repository.dart';

/// Get My Feedbacks Use Case
class GetMyFeedbacksUsecase {
  final FeedbackRepository repository;

  GetMyFeedbacksUsecase(this.repository);

  Future<List<FeedbackEntity>> call() async {
    return await repository.getMyFeedbacks();
  }
}

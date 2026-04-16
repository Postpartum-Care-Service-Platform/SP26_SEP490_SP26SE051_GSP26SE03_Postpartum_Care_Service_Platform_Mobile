import '../entities/feedback_entity.dart';
import '../repositories/feedback_repository.dart';

/// Get Full Feedbacks Use Case
class GetFullFeedbacksUsecase {
  final FeedbackRepository repository;

  GetFullFeedbacksUsecase(this.repository);

  Future<List<FeedbackEntity>> call() async {
    return await repository.getFullFeedbacks();
  }
}

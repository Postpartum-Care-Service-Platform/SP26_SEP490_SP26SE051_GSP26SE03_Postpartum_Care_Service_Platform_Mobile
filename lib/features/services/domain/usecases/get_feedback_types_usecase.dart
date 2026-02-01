import '../entities/feedback_type_entity.dart';
import '../repositories/feedback_repository.dart';

/// Get Feedback Types Use Case
class GetFeedbackTypesUsecase {
  final FeedbackRepository repository;

  GetFeedbackTypesUsecase(this.repository);

  Future<List<FeedbackTypeEntity>> call() async {
    return await repository.getFeedbackTypes();
  }
}

import '../entities/feedback_entity.dart';
import '../repositories/feedback_repository.dart';

/// Create Feedback Use Case
class CreateFeedbackUsecase {
  final FeedbackRepository repository;

  CreateFeedbackUsecase(this.repository);

  Future<FeedbackEntity> call({
    required int feedbackTypeId,
    required String title,
    required String content,
    required int rating,
    required List<String> imagePaths,
  }) async {
    return await repository.createFeedback(
      feedbackTypeId: feedbackTypeId,
      title: title,
      content: content,
      rating: rating,
      imagePaths: imagePaths,
    );
  }
}

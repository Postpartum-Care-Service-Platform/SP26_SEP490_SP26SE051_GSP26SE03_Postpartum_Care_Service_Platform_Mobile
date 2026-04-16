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
    int? familyScheduleId,
    String? staffId,
    int? amenityTicketId,
  }) async {
    return await repository.createFeedback(
      feedbackTypeId: feedbackTypeId,
      title: title,
      content: content,
      rating: rating,
      imagePaths: imagePaths,
      familyScheduleId: familyScheduleId,
      staffId: staffId,
      amenityTicketId: amenityTicketId,
    );
  }
}

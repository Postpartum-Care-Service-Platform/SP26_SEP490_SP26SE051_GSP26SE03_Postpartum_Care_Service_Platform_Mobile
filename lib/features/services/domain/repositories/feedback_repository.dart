import '../entities/feedback_entity.dart';
import '../entities/feedback_type_entity.dart';

/// Feedback Repository Interface - Domain layer
abstract class FeedbackRepository {
  /// Get all feedback types
  Future<List<FeedbackTypeEntity>> getFeedbackTypes();

  /// Get my feedbacks
  Future<List<FeedbackEntity>> getMyFeedbacks();

  /// Create feedback
  Future<FeedbackEntity> createFeedback({
    required int feedbackTypeId,
    required String title,
    required String content,
    required int rating,
    required List<String> imagePaths,
  });
}

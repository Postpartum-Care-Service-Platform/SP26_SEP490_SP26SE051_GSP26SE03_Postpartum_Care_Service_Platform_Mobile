import '../entities/feedback_entity.dart';
import '../entities/feedback_type_entity.dart';
import '../../../auth/domain/entities/staff_entity.dart';

/// Feedback Repository Interface - Domain layer
abstract class FeedbackRepository {
  /// Get all feedback types
  Future<List<FeedbackTypeEntity>> getFeedbackTypes();

  /// Get my feedbacks for the service flow
  Future<List<FeedbackEntity>> getMyFeedbacks();

  /// Get full feedback history for profile flow
  Future<List<FeedbackEntity>> getFullFeedbacks();

  /// Create feedback
  Future<FeedbackEntity> createFeedback({
    required int feedbackTypeId,
    required String title,
    required String content,
    required int rating,
    required List<String> imagePaths,
    int? familyScheduleId,
    String? staffId,
    int? amenityTicketId,
  });

  /// Get current booking staff
  Future<List<StaffEntity>> getCurrentBookingStaff();
}

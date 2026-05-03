import 'package:equatable/equatable.dart';

/// Feedback Event - BLoC events
abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object?> get props => [];
}

/// Load feedback types
class FeedbackTypesLoadRequested extends FeedbackEvent {
  const FeedbackTypesLoadRequested();
}

/// Load current booking staff
class FeedbackCurrentBookingStaffLoadRequested extends FeedbackEvent {
  const FeedbackCurrentBookingStaffLoadRequested();
}

enum FeedbackLoadScope {
  service,
  profile,
}

/// Load my feedbacks
class MyFeedbacksLoadRequested extends FeedbackEvent {
  final FeedbackLoadScope scope;

  const MyFeedbacksLoadRequested({this.scope = FeedbackLoadScope.service});

  @override
  List<Object?> get props => [scope];
}

/// Refresh my feedbacks
class MyFeedbacksRefreshRequested extends FeedbackEvent {
  final FeedbackLoadScope scope;

  const MyFeedbacksRefreshRequested({this.scope = FeedbackLoadScope.service});

  @override
  List<Object?> get props => [scope];
}

/// Create feedback
class FeedbackCreateRequested extends FeedbackEvent {
  final int feedbackTypeId;
  final String title;
  final String content;
  final int rating;
  final List<String> imagePaths;
  final int? familyScheduleId;
  final String? staffId;
  final int? amenityTicketId;

  const FeedbackCreateRequested({
    required this.feedbackTypeId,
    required this.title,
    required this.content,
    required this.rating,
    required this.imagePaths,
    this.familyScheduleId,
    this.staffId,
    this.amenityTicketId,
  });

  @override
  List<Object?> get props => [
        feedbackTypeId,
        title,
        content,
        rating,
        imagePaths,
        familyScheduleId,
        staffId,
        amenityTicketId,
      ];
}

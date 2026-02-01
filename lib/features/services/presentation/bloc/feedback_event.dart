import 'package:equatable/equatable.dart';

/// Feedback Event - BLoC events
abstract class FeedbackEvent extends Equatable {
  const FeedbackEvent();

  @override
  List<Object> get props => [];
}

/// Load feedback types
class FeedbackTypesLoadRequested extends FeedbackEvent {
  const FeedbackTypesLoadRequested();
}

/// Load my feedbacks
class MyFeedbacksLoadRequested extends FeedbackEvent {
  const MyFeedbacksLoadRequested();
}

/// Refresh my feedbacks
class MyFeedbacksRefreshRequested extends FeedbackEvent {
  const MyFeedbacksRefreshRequested();
}

/// Create feedback
class FeedbackCreateRequested extends FeedbackEvent {
  final int feedbackTypeId;
  final String title;
  final String content;
  final int rating;
  final List<String> imagePaths;

  const FeedbackCreateRequested({
    required this.feedbackTypeId,
    required this.title,
    required this.content,
    required this.rating,
    required this.imagePaths,
  });

  @override
  List<Object> get props => [feedbackTypeId, title, content, rating, imagePaths];
}

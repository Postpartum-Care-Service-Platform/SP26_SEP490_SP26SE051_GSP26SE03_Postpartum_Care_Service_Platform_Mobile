import 'package:equatable/equatable.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/entities/feedback_type_entity.dart';

/// Feedback State - BLoC states
abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object> get props => [];
}

/// Initial state
class FeedbackInitial extends FeedbackState {
  const FeedbackInitial();
}

/// Loading state
class FeedbackLoading extends FeedbackState {
  const FeedbackLoading();
}

/// Feedback types loaded
class FeedbackTypesLoaded extends FeedbackState {
  final List<FeedbackTypeEntity> types;

  const FeedbackTypesLoaded({required this.types});

  @override
  List<Object> get props => [types];
}

/// My feedbacks loaded
class MyFeedbacksLoaded extends FeedbackState {
  final List<FeedbackEntity> feedbacks;
  final List<FeedbackTypeEntity> types;

  const MyFeedbacksLoaded({
    required this.feedbacks,
    required this.types,
  });

  MyFeedbacksLoaded copyWith({
    List<FeedbackEntity>? feedbacks,
    List<FeedbackTypeEntity>? types,
  }) {
    return MyFeedbacksLoaded(
      feedbacks: feedbacks ?? this.feedbacks,
      types: types ?? this.types,
    );
  }

  @override
  List<Object> get props => [feedbacks, types];
}

/// Feedback created successfully
class FeedbackCreated extends FeedbackState {
  final FeedbackEntity feedback;

  const FeedbackCreated({required this.feedback});

  @override
  List<Object> get props => [feedback];
}

/// Error state
class FeedbackError extends FeedbackState {
  final String message;

  const FeedbackError(this.message);

  @override
  List<Object> get props => [message];
}

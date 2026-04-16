import 'package:equatable/equatable.dart';
import '../../domain/entities/staff_feedback_entity.dart';

abstract class StaffFeedbackState extends Equatable {
  const StaffFeedbackState();

  @override
  List<Object?> get props => [];
}

class StaffFeedbackInitial extends StaffFeedbackState {}

class StaffFeedbackLoading extends StaffFeedbackState {}

class StaffFeedbackLoaded extends StaffFeedbackState {
  final List<StaffFeedbackEntity> feedbacks;

  const StaffFeedbackLoaded(this.feedbacks);

  @override
  List<Object?> get props => [feedbacks];
}

class StaffFeedbackError extends StaffFeedbackState {
  final String message;

  const StaffFeedbackError(this.message);

  @override
  List<Object?> get props => [message];
}

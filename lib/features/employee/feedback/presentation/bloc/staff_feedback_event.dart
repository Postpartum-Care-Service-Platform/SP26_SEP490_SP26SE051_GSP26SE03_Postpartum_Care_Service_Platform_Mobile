import 'package:equatable/equatable.dart';

abstract class StaffFeedbackEvent extends Equatable {
  const StaffFeedbackEvent();

  @override
  List<Object?> get props => [];
}

class FetchStaffFeedbacksEvent extends StaffFeedbackEvent {}

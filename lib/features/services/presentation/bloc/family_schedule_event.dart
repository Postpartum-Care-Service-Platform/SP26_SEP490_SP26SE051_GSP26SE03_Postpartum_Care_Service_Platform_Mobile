import 'package:equatable/equatable.dart';

/// Family Schedule Events
abstract class FamilyScheduleEvent extends Equatable {
  const FamilyScheduleEvent();

  @override
  List<Object?> get props => [];
}

/// Load family schedules
class FamilyScheduleLoadRequested extends FamilyScheduleEvent {
  const FamilyScheduleLoadRequested();
}

/// Refresh family schedules
class FamilyScheduleRefreshRequested extends FamilyScheduleEvent {
  const FamilyScheduleRefreshRequested();
}

/// Load family schedules by date
class FamilyScheduleLoadByDateRequested extends FamilyScheduleEvent {
  final String date; // Format: YYYY-MM-DD

  const FamilyScheduleLoadByDateRequested(this.date);

  @override
  List<Object?> get props => [date];
}

/// Customer confirms a schedule marked as StaffDone
class FamilyScheduleConfirmDoneRequested extends FamilyScheduleEvent {
  final int scheduleId;

  const FamilyScheduleConfirmDoneRequested(this.scheduleId);

  @override
  List<Object?> get props => [scheduleId];
}

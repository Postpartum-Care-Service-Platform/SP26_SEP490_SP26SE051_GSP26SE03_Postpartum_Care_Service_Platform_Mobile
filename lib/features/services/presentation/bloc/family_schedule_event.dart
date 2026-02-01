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

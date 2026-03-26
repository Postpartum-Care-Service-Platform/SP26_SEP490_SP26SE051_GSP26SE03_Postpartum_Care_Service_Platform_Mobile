import 'package:equatable/equatable.dart';

import '../../../domain/entities/staff_schedule_entity.dart';

/// Staff Schedule States
abstract class StaffScheduleState extends Equatable {
  const StaffScheduleState();

  @override
  List<Object?> get props => [];
}

class StaffScheduleInitial extends StaffScheduleState {
  const StaffScheduleInitial();
}

class StaffScheduleLoading extends StaffScheduleState {
  const StaffScheduleLoading();
}

class StaffScheduleLoaded extends StaffScheduleState {
  final List<StaffScheduleEntity> schedules;

  const StaffScheduleLoaded({required this.schedules});

  @override
  List<Object?> get props => [schedules];
}

class StaffScheduleEmpty extends StaffScheduleState {
  const StaffScheduleEmpty();
}

class StaffScheduleError extends StaffScheduleState {
  final String message;

  const StaffScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}

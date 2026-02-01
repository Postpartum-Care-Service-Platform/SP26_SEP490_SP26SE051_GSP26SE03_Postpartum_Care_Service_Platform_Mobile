import 'package:equatable/equatable.dart';
import '../../domain/entities/family_schedule_entity.dart';

/// Family Schedule States
abstract class FamilyScheduleState extends Equatable {
  const FamilyScheduleState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FamilyScheduleInitial extends FamilyScheduleState {
  const FamilyScheduleInitial();
}

/// Loading state
class FamilyScheduleLoading extends FamilyScheduleState {
  const FamilyScheduleLoading();
}

/// Loaded state
class FamilyScheduleLoaded extends FamilyScheduleState {
  final List<FamilyScheduleEntity> schedules;

  const FamilyScheduleLoaded({required this.schedules});

  @override
  List<Object?> get props => [schedules];
}

/// Error state
class FamilyScheduleError extends FamilyScheduleState {
  final String message;

  const FamilyScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}

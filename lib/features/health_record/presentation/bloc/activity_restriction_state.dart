import 'package:equatable/equatable.dart';
import '../../domain/entities/activity_restriction_entity.dart';

abstract class ActivityRestrictionState extends Equatable {
  const ActivityRestrictionState();

  @override
  List<Object?> get props => [];
}

class ActivityRestrictionInitial extends ActivityRestrictionState {}

class ActivityRestrictionLoading extends ActivityRestrictionState {}

class ActivityRestrictionChecked extends ActivityRestrictionState {
  final ActivityRestrictionEntity restriction;

  const ActivityRestrictionChecked(this.restriction);

  @override
  List<Object?> get props => [restriction];
}

class BatchActivityRestrictionsChecked extends ActivityRestrictionState {
  final BatchActivityRestrictionEntity restriction;

  const BatchActivityRestrictionsChecked(this.restriction);

  @override
  List<Object?> get props => [restriction];
}

class ActivityRestrictionError extends ActivityRestrictionState {
  final String message;

  const ActivityRestrictionError(this.message);

  @override
  List<Object?> get props => [message];
}

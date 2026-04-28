import 'package:equatable/equatable.dart';
import '../../domain/entities/activity_restriction_entity.dart';

abstract class ActivityRestrictionEvent extends Equatable {
  const ActivityRestrictionEvent();

  @override
  List<Object?> get props => [];
}

class CheckActivityRestriction extends ActivityRestrictionEvent {
  final int familyProfileId;
  final int activityId;

  const CheckActivityRestriction({
    required this.familyProfileId,
    required this.activityId,
  });

  @override
  List<Object?> get props => [familyProfileId, activityId];
}

class BatchCheckActivityRestrictions extends ActivityRestrictionEvent {
  final int familyProfileId;
  final List<int> activityIds;

  const BatchCheckActivityRestrictions({
    required this.familyProfileId,
    required this.activityIds,
  });

  @override
  List<Object?> get props => [familyProfileId, activityIds];
}

import 'package:equatable/equatable.dart';

class ActivityRestrictionEntity extends Equatable {
  final bool isRestricted;
  final String? reason;
  final List<String> restrictedConditions;

  const ActivityRestrictionEntity({
    required this.isRestricted,
    this.reason,
    required this.restrictedConditions,
  });

  @override
  List<Object?> get props => [isRestricted, reason, restrictedConditions];
}

class BatchActivityRestrictionEntity extends Equatable {
  final Map<int, ActivityRestrictionEntity> restrictions;

  const BatchActivityRestrictionEntity({
    required this.restrictions,
  });

  @override
  List<Object?> get props => [restrictions];
}

import 'package:equatable/equatable.dart';

/// Care Plan events
abstract class CarePlanEvent extends Equatable {
  const CarePlanEvent();

  @override
  List<Object?> get props => [];
}

/// Load care plan details by package ID event
class CarePlanLoadRequested extends CarePlanEvent {
  final int packageId;

  const CarePlanLoadRequested(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

/// Refresh care plan details event
class CarePlanRefresh extends CarePlanEvent {
  final int packageId;

  const CarePlanRefresh(this.packageId);

  @override
  List<Object?> get props => [packageId];
}

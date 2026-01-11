import 'package:equatable/equatable.dart';
import '../../domain/entities/care_plan_entity.dart';

/// Care Plan states
abstract class CarePlanState extends Equatable {
  const CarePlanState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CarePlanInitial extends CarePlanState {
  const CarePlanInitial();
}

/// Loading state
class CarePlanLoading extends CarePlanState {
  const CarePlanLoading();
}

/// Loaded state
class CarePlanLoaded extends CarePlanState {
  final List<CarePlanEntity> carePlans;
  final String packageName;

  const CarePlanLoaded({
    required this.carePlans,
    required this.packageName,
  });

  @override
  List<Object?> get props => [carePlans, packageName];

  CarePlanLoaded copyWith({
    List<CarePlanEntity>? carePlans,
    String? packageName,
  }) {
    return CarePlanLoaded(
      carePlans: carePlans ?? this.carePlans,
      packageName: packageName ?? this.packageName,
    );
  }
}

/// Error state
class CarePlanError extends CarePlanState {
  final String message;

  const CarePlanError(this.message);

  @override
  List<Object?> get props => [message];
}

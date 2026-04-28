import 'package:equatable/equatable.dart';
import '../../domain/entities/health_record_entity.dart';

abstract class HealthRecordState extends Equatable {
  const HealthRecordState();

  @override
  List<Object?> get props => [];
}

class HealthRecordInitial extends HealthRecordState {}

class HealthRecordLoading extends HealthRecordState {}

class HealthRecordLoaded extends HealthRecordState {
  final List<HealthRecordEntity> records;

  const HealthRecordLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class HealthRecordLatestLoaded extends HealthRecordState {
  final HealthRecordEntity record;

  const HealthRecordLatestLoaded(this.record);

  @override
  List<Object?> get props => [record];
}

class HealthConditionsLoaded extends HealthRecordState {
  final List<HealthConditionEntity> conditions;

  const HealthConditionsLoaded(this.conditions);

  @override
  List<Object?> get props => [conditions];
}

class HealthRecordNotFound extends HealthRecordState {}

class HealthRecordError extends HealthRecordState {
  final String message;

  const HealthRecordError(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthRecordActionLoading extends HealthRecordState {}

class HealthRecordActionSuccess extends HealthRecordState {
  final HealthRecordEntity record;
  final String message;

  const HealthRecordActionSuccess(this.record, this.message);

  @override
  List<Object?> get props => [record, message];
}

class CreateHealthRecordLoading extends HealthRecordState {}

class CreateHealthRecordSuccess extends HealthRecordState {
  final HealthRecordEntity record;

  const CreateHealthRecordSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

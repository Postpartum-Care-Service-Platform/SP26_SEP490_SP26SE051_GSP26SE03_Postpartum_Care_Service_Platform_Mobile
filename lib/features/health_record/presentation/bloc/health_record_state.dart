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

class HealthRecordError extends HealthRecordState {
  final String message;

  const HealthRecordError(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateHealthRecordLoading extends HealthRecordState {}

class CreateHealthRecordSuccess extends HealthRecordState {
  final HealthRecordEntity record;

  const CreateHealthRecordSuccess(this.record);

  @override
  List<Object?> get props => [record];
}

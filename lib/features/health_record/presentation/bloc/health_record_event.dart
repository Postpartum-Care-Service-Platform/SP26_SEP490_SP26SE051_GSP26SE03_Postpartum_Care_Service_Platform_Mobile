import 'package:equatable/equatable.dart';
import '../../data/models/create_health_record_request.dart';

abstract class HealthRecordEvent extends Equatable {
  const HealthRecordEvent();

  @override
  List<Object?> get props => [];
}

class GetHealthRecords extends HealthRecordEvent {
  final int familyProfileId;

  const GetHealthRecords(this.familyProfileId);

  @override
  List<Object?> get props => [familyProfileId];
}

class GetLatestHealthRecord extends HealthRecordEvent {
  final int familyProfileId;

  const GetLatestHealthRecord(this.familyProfileId);

  @override
  List<Object?> get props => [familyProfileId];
}

class GetHealthConditions extends HealthRecordEvent {
  const GetHealthConditions();
}

class CreateHealthRecord extends HealthRecordEvent {
  final int familyProfileId;
  final CreateHealthRecordRequest request;

  const CreateHealthRecord(this.familyProfileId, this.request);

  @override
  List<Object?> get props => [familyProfileId, request];
}

class UpdateHealthRecord extends HealthRecordEvent {
  final int id;
  final int familyProfileId; // Để refresh sau khi update
  final CreateHealthRecordRequest request;

  const UpdateHealthRecord({
    required this.id,
    required this.familyProfileId,
    required this.request,
  });

  @override
  List<Object?> get props => [id, familyProfileId, request];
}

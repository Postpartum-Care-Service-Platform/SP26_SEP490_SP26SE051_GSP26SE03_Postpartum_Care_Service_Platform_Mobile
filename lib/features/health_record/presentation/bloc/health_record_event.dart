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

class CreateHealthRecord extends HealthRecordEvent {
  final int familyProfileId;
  final CreateHealthRecordRequest request;

  const CreateHealthRecord(this.familyProfileId, this.request);

  @override
  List<Object?> get props => [familyProfileId, request];
}

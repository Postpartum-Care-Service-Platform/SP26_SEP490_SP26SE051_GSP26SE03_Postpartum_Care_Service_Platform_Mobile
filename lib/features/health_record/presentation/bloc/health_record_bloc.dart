import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/health_record_repository.dart';
import 'health_record_event.dart';
import 'health_record_state.dart';

class HealthRecordBloc extends Bloc<HealthRecordEvent, HealthRecordState> {
  final HealthRecordRepository repository;

  HealthRecordBloc({required this.repository}) : super(HealthRecordInitial()) {
    on<GetHealthRecords>(_onGetHealthRecords);
    on<CreateHealthRecord>(_onCreateHealthRecord);
  }

  Future<void> _onGetHealthRecords(GetHealthRecords event, Emitter<HealthRecordState> emit) async {
    emit(HealthRecordLoading());
    try {
      final records = await repository.getHealthRecordsByFamilyProfile(event.familyProfileId);
      emit(HealthRecordLoaded(records));
    } catch (e) {
      emit(HealthRecordError(e.toString()));
    }
  }

  Future<void> _onCreateHealthRecord(CreateHealthRecord event, Emitter<HealthRecordState> emit) async {
    emit(CreateHealthRecordLoading());
    try {
      final record = await repository.createHealthRecord(event.familyProfileId, event.request);
      emit(CreateHealthRecordSuccess(record));
    } catch (e) {
      emit(HealthRecordError(e.toString()));
    }
    
    // Automatically refresh the list after creation
    add(GetHealthRecords(event.familyProfileId));
  }
}

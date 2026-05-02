import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/health_record_repository.dart';
import 'health_record_event.dart';
import 'health_record_state.dart';

class HealthRecordBloc extends Bloc<HealthRecordEvent, HealthRecordState> {
  final HealthRecordRepository repository;

  HealthRecordBloc({required this.repository}) : super(HealthRecordInitial()) {
    on<GetHealthRecords>(_onGetHealthRecords);
    on<GetLatestHealthRecord>(_onGetLatestHealthRecord);
    on<GetHealthConditions>(_onGetHealthConditions);
    on<CreateHealthRecord>(_onCreateHealthRecord);
    on<UpdateHealthRecord>(_onUpdateHealthRecord);
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

  Future<void> _onGetLatestHealthRecord(GetLatestHealthRecord event, Emitter<HealthRecordState> emit) async {
    emit(HealthRecordLoading());
    try {
      final record = await repository.getLatestHealthRecord(event.familyProfileId);
      emit(HealthRecordLatestLoaded(record));
    } catch (e) {
      if (e.toString().contains('NO_HEALTH_RECORD')) {
        emit(HealthRecordNotFound());
      } else {
        emit(HealthRecordError(e.toString()));
      }
    }
  }

  Future<void> _onGetHealthConditions(GetHealthConditions event, Emitter<HealthRecordState> emit) async {
    emit(HealthRecordLoading());
    try {
      final conditions = await repository.getHealthConditions(
        categoryId: event.categoryId,
        memberTypeId: event.memberTypeId,
      );
      emit(HealthConditionsLoaded(conditions));
    } catch (e) {
      emit(HealthRecordError(e.toString()));
    }
  }

  Future<void> _onCreateHealthRecord(CreateHealthRecord event, Emitter<HealthRecordState> emit) async {
    emit(CreateHealthRecordLoading());
    try {
      final record = await repository.createHealthRecord(event.familyProfileId, event.request);
      emit(CreateHealthRecordSuccess(record));
      // Automatically refresh the list after creation
      add(GetHealthRecords(event.familyProfileId));
    } catch (e) {
      emit(HealthRecordError(e.toString()));
    }
  }

  Future<void> _onUpdateHealthRecord(UpdateHealthRecord event, Emitter<HealthRecordState> emit) async {
    emit(HealthRecordActionLoading());
    try {
      final record = await repository.updateHealthRecord(event.id, event.request);
      emit(HealthRecordActionSuccess(record, 'Cập nhật sổ sức khỏe thành công'));
      // Automatically refresh the list after update
      add(GetHealthRecords(event.familyProfileId));
    } catch (e) {
      emit(HealthRecordError(e.toString()));
    }
  }
}

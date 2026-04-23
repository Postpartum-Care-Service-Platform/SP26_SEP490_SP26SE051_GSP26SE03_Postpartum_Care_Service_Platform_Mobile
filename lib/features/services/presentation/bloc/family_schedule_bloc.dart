import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/confirm_family_schedule_done_usecase.dart';
import '../../domain/usecases/get_my_schedules_by_date_usecase.dart';
import '../../domain/usecases/get_my_schedules_usecase.dart';
import 'family_schedule_event.dart';
import 'family_schedule_state.dart';

/// Family Schedule BLoC
class FamilyScheduleBloc
    extends Bloc<FamilyScheduleEvent, FamilyScheduleState> {
  final GetMySchedulesUsecase getMySchedulesUsecase;
  final GetMySchedulesByDateUsecase getMySchedulesByDateUsecase;
  final ConfirmFamilyScheduleDoneUsecase confirmFamilyScheduleDoneUsecase;

  FamilyScheduleBloc({
    required this.getMySchedulesUsecase,
    required this.getMySchedulesByDateUsecase,
    required this.confirmFamilyScheduleDoneUsecase,
  }) : super(const FamilyScheduleInitial()) {
    on<FamilyScheduleLoadRequested>(_onLoadRequested);
    on<FamilyScheduleRefreshRequested>(_onRefreshRequested);
    on<FamilyScheduleLoadByDateRequested>(_onLoadByDateRequested);
    on<FamilyScheduleConfirmDoneRequested>(_onConfirmDoneRequested);
  }

  Future<void> _onLoadRequested(
    FamilyScheduleLoadRequested event,
    Emitter<FamilyScheduleState> emit,
  ) async {
    emit(const FamilyScheduleLoading());

    try {
      final schedules = await getMySchedulesUsecase();
      emit(FamilyScheduleLoaded(
        schedules: schedules,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(FamilyScheduleError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onRefreshRequested(
    FamilyScheduleRefreshRequested event,
    Emitter<FamilyScheduleState> emit,
  ) async {
    if (state is! FamilyScheduleLoaded) {
      emit(const FamilyScheduleLoading());
    }

    try {
      final schedules = await getMySchedulesUsecase();
      emit(FamilyScheduleLoaded(
        schedules: schedules,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(FamilyScheduleError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onLoadByDateRequested(
    FamilyScheduleLoadByDateRequested event,
    Emitter<FamilyScheduleState> emit,
  ) async {
    emit(const FamilyScheduleLoading());

    try {
      final schedules = await getMySchedulesByDateUsecase(event.date);
      emit(FamilyScheduleLoaded(
        schedules: schedules,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(FamilyScheduleError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onConfirmDoneRequested(
    FamilyScheduleConfirmDoneRequested event,
    Emitter<FamilyScheduleState> emit,
  ) async {
    if (state is! FamilyScheduleLoaded) return;

    final current = state as FamilyScheduleLoaded;
    try {
      final updatedSchedule =
          await confirmFamilyScheduleDoneUsecase(event.scheduleId);
      final updatedSchedules = current.schedules
          .map(
            (schedule) =>
                schedule.id == updatedSchedule.id ? updatedSchedule : schedule,
          )
          .toList();
      emit(FamilyScheduleLoaded(
        schedules: updatedSchedules,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      emit(FamilyScheduleError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
      emit(FamilyScheduleLoaded(
        schedules: current.schedules,
        timestamp: DateTime.now(),
      ));
    }
  }
}

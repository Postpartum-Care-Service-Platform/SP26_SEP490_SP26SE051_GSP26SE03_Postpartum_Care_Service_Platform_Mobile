import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_schedules_usecase.dart';
import 'family_schedule_event.dart';
import 'family_schedule_state.dart';

/// Family Schedule BLoC
class FamilyScheduleBloc
    extends Bloc<FamilyScheduleEvent, FamilyScheduleState> {
  final GetMySchedulesUsecase getMySchedulesUsecase;

  FamilyScheduleBloc({required this.getMySchedulesUsecase})
      : super(const FamilyScheduleInitial()) {
    on<FamilyScheduleLoadRequested>(_onLoadRequested);
    on<FamilyScheduleRefreshRequested>(_onRefreshRequested);
  }

  Future<void> _onLoadRequested(
    FamilyScheduleLoadRequested event,
    Emitter<FamilyScheduleState> emit,
  ) async {
    emit(const FamilyScheduleLoading());

    try {
      final schedules = await getMySchedulesUsecase();
      emit(FamilyScheduleLoaded(schedules: schedules));
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
    // Keep current state if loaded, otherwise show loading
    if (state is! FamilyScheduleLoaded) {
      emit(const FamilyScheduleLoading());
    }

    try {
      final schedules = await getMySchedulesUsecase();
      emit(FamilyScheduleLoaded(schedules: schedules));
    } catch (e) {
      emit(FamilyScheduleError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_my_schedules_usecase.dart';
import '../../domain/usecases/get_my_schedules_by_date_usecase.dart';
import 'family_schedule_event.dart';
import 'family_schedule_state.dart';

/// Family Schedule BLoC
class FamilyScheduleBloc
    extends Bloc<FamilyScheduleEvent, FamilyScheduleState> {
  final GetMySchedulesUsecase getMySchedulesUsecase;
  final GetMySchedulesByDateUsecase getMySchedulesByDateUsecase;

  FamilyScheduleBloc({
    required this.getMySchedulesUsecase,
    required this.getMySchedulesByDateUsecase,
  }) : super(const FamilyScheduleInitial()) {
    on<FamilyScheduleLoadRequested>(_onLoadRequested);
    on<FamilyScheduleRefreshRequested>(_onRefreshRequested);
    on<FamilyScheduleLoadByDateRequested>(_onLoadByDateRequested);
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

  Future<void> _onLoadByDateRequested(
    FamilyScheduleLoadByDateRequested event,
    Emitter<FamilyScheduleState> emit,
  ) async {
    // Always show loading state for better UX
    emit(const FamilyScheduleLoading());

    try {
      final schedules = await getMySchedulesByDateUsecase(event.date);
      print('FamilyScheduleBloc: Loaded ${schedules.length} schedules for date ${event.date}');
      // Always emit new state to ensure BlocBuilder rebuilds
      emit(FamilyScheduleLoaded(schedules: schedules));
      print('FamilyScheduleBloc: Emitted FamilyScheduleLoaded with ${schedules.length} schedules');
    } catch (e) {
      print('FamilyScheduleBloc: Error loading schedules: $e');
      emit(FamilyScheduleError(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
}

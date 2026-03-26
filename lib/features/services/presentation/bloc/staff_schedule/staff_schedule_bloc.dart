import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_my_staff_schedules_by_date_range_usecase.dart';
import 'staff_schedule_event.dart';
import 'staff_schedule_state.dart';

/// Staff Schedule Bloc
class StaffScheduleBloc extends Bloc<StaffScheduleEvent, StaffScheduleState> {
  final GetMyStaffSchedulesByDateRangeUsecase getMyStaffSchedulesByDateRange;

  StaffScheduleBloc({required this.getMyStaffSchedulesByDateRange})
      : super(const StaffScheduleInitial()) {
    on<LoadStaffSchedulesByDateRange>(_onLoadStaffSchedulesByDateRange);
  }

  Future<void> _onLoadStaffSchedulesByDateRange(
    LoadStaffSchedulesByDateRange event,
    Emitter<StaffScheduleState> emit,
  ) async {
    try {
      emit(const StaffScheduleLoading());
      final schedules = await getMyStaffSchedulesByDateRange(
        from: event.from,
        to: event.to,
      );
      if (schedules.isEmpty) {
        emit(const StaffScheduleEmpty());
        return;
      }
      emit(StaffScheduleLoaded(schedules: schedules));
    } catch (e) {
      emit(StaffScheduleError(message: e.toString()));
    }
  }
}

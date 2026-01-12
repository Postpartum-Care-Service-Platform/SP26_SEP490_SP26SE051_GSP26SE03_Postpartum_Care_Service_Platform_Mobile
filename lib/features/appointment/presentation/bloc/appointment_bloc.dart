import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_appointments_usecase.dart';
import '../../domain/usecases/create_appointment_usecase.dart';
import '../../domain/usecases/update_appointment_usecase.dart';
import '../../domain/usecases/cancel_appointment_usecase.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

/// Appointment BloC
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final GetAppointmentsUsecase getAppointmentsUsecase;
  final CreateAppointmentUsecase createAppointmentUsecase;
  final UpdateAppointmentUsecase updateAppointmentUsecase;
  final CancelAppointmentUsecase cancelAppointmentUsecase;

  AppointmentBloc({
    required this.getAppointmentsUsecase,
    required this.createAppointmentUsecase,
    required this.updateAppointmentUsecase,
    required this.cancelAppointmentUsecase,
  }) : super(const AppointmentInitial()) {
    on<AppointmentLoadRequested>(_onLoadRequested);
    on<AppointmentRefresh>(_onRefresh);
    on<AppointmentCreateRequested>(_onCreateRequested);
    on<AppointmentUpdateRequested>(_onUpdateRequested);
    on<AppointmentCancelRequested>(_onCancelRequested);
  }

  Future<void> _onLoadRequested(
    AppointmentLoadRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());
    try {
      final appointments = await getAppointmentsUsecase();
      emit(AppointmentLoaded(appointments: appointments));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    AppointmentRefresh event,
    Emitter<AppointmentState> emit,
  ) async {
    try {
      final appointments = await getAppointmentsUsecase();
      emit(AppointmentLoaded(appointments: appointments));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onCreateRequested(
    AppointmentCreateRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentCreating());
    try {
      await createAppointmentUsecase(
        date: event.date,
        time: event.time,
        name: event.name,
      );
      final appointments = await getAppointmentsUsecase();
      emit(AppointmentLoaded(appointments: appointments));
      emit(const AppointmentSuccess('Tạo lịch hẹn thành công'));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    AppointmentUpdateRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentUpdating());
    try {
      await updateAppointmentUsecase(
        id: event.id,
        date: event.date,
        time: event.time,
        name: event.name,
      );
      final appointments = await getAppointmentsUsecase();
      emit(AppointmentLoaded(appointments: appointments));
      emit(const AppointmentSuccess('Cập nhật lịch hẹn thành công'));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  Future<void> _onCancelRequested(
    AppointmentCancelRequested event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentCancelling());
    try {
      await cancelAppointmentUsecase(event.id);
      final appointments = await getAppointmentsUsecase();
      emit(AppointmentLoaded(appointments: appointments));
      emit(const AppointmentSuccess('Hủy lịch hẹn thành công'));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }
}

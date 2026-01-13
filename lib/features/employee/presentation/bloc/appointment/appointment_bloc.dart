import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_my_assigned_appointments.dart';
import '../../../domain/usecases/get_all_appointments.dart';
import '../../../domain/usecases/get_appointment_by_id.dart';
import '../../../domain/usecases/confirm_appointment.dart';
import '../../../domain/usecases/complete_appointment.dart';
import '../../../domain/usecases/cancel_appointment.dart';
import '../../../domain/usecases/create_appointment_for_customer.dart';
import 'appointment_event.dart';
import 'appointment_state.dart';

/// BLoC for managing appointment state and actions
class AppointmentBloc extends Bloc<AppointmentEvent, AppointmentState> {
  final GetMyAssignedAppointments getMyAssignedAppointments;
  final GetAllAppointments getAllAppointments;
  final GetAppointmentById getAppointmentById;
  final ConfirmAppointment confirmAppointment;
  final CompleteAppointment completeAppointment;
  final CancelAppointment cancelAppointment;
  final CreateAppointmentForCustomer createAppointmentForCustomer;

  AppointmentBloc({
    required this.getMyAssignedAppointments,
    required this.getAllAppointments,
    required this.getAppointmentById,
    required this.confirmAppointment,
    required this.completeAppointment,
    required this.cancelAppointment,
    required this.createAppointmentForCustomer,
  }) : super(const AppointmentInitial()) {
    // Register event handlers
    on<LoadMyAssignedAppointments>(_onLoadMyAssignedAppointments);
    on<LoadAllAppointments>(_onLoadAllAppointments);
    on<LoadAppointmentById>(_onLoadAppointmentById);
    on<ConfirmAppointmentEvent>(_onConfirmAppointment);
    on<CompleteAppointmentEvent>(_onCompleteAppointment);
    on<CancelAppointmentEvent>(_onCancelAppointment);
    on<CreateAppointmentForCustomerEvent>(_onCreateAppointmentForCustomer);
    on<RefreshAppointments>(_onRefreshAppointments);
  }

  /// Handle load my assigned appointments
  Future<void> _onLoadMyAssignedAppointments(
    LoadMyAssignedAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());

    try {
      final appointments = await getMyAssignedAppointments();
      
      if (appointments.isEmpty) {
        emit(const AppointmentEmpty());
      } else {
        emit(AppointmentLoaded(appointments));
      }
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  /// Handle load all appointments
  Future<void> _onLoadAllAppointments(
    LoadAllAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());

    try {
      final appointments = await getAllAppointments();
      
      if (appointments.isEmpty) {
        emit(const AppointmentEmpty());
      } else {
        emit(AppointmentLoaded(appointments));
      }
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  /// Handle load appointment by ID
  Future<void> _onLoadAppointmentById(
    LoadAppointmentById event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());

    try {
      final appointment = await getAppointmentById(event.appointmentId);
      emit(AppointmentDetailLoaded(appointment));
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  /// Handle confirm appointment
  Future<void> _onConfirmAppointment(
    ConfirmAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    // Show loading while keeping current state data
    final currentState = state;
    emit(const AppointmentLoading());

    try {
      final message = await confirmAppointment(event.appointmentId);
      emit(AppointmentActionSuccess(message));
      
      // Reload appointments after successful action
      if (currentState is AppointmentLoaded) {
        add(const RefreshAppointments());
      }
    } catch (e) {
      emit(AppointmentError(e.toString()));
      
      // Restore previous state if available
      if (currentState is AppointmentLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handle complete appointment
  Future<void> _onCompleteAppointment(
    CompleteAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    emit(const AppointmentLoading());

    try {
      final message = await completeAppointment(event.appointmentId);
      emit(AppointmentActionSuccess(message));
      
      // Reload appointments after successful action
      if (currentState is AppointmentLoaded) {
        add(const RefreshAppointments());
      }
    } catch (e) {
      emit(AppointmentError(e.toString()));
      
      // Restore previous state if available
      if (currentState is AppointmentLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handle cancel appointment
  Future<void> _onCancelAppointment(
    CancelAppointmentEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    final currentState = state;
    emit(const AppointmentLoading());

    try {
      final message = await cancelAppointment(event.appointmentId);
      emit(AppointmentActionSuccess(message));
      
      // Reload appointments after successful action
      if (currentState is AppointmentLoaded) {
        add(const RefreshAppointments());
      }
    } catch (e) {
      emit(AppointmentError(e.toString()));
      
      // Restore previous state if available
      if (currentState is AppointmentLoaded) {
        emit(currentState);
      }
    }
  }

  /// Handle create appointment for customer
  Future<void> _onCreateAppointmentForCustomer(
    CreateAppointmentForCustomerEvent event,
    Emitter<AppointmentState> emit,
  ) async {
    emit(const AppointmentLoading());

    try {
      final appointment = await createAppointmentForCustomer(
        customerId: event.customerId,
        appointmentDate: event.appointmentDate,
        name: event.name,
      );
      
      emit(AppointmentCreated(appointment: appointment));
      
      // Reload appointments after creation
      add(const RefreshAppointments());
    } catch (e) {
      emit(AppointmentError(e.toString()));
    }
  }

  /// Handle refresh appointments
  Future<void> _onRefreshAppointments(
    RefreshAppointments event,
    Emitter<AppointmentState> emit,
  ) async {
    // Reload my assigned appointments by default
    add(const LoadMyAssignedAppointments());
  }
}

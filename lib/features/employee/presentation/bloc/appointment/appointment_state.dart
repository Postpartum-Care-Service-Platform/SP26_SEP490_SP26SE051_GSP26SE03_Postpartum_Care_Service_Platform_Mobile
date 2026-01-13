import 'package:equatable/equatable.dart';
import '../../../domain/entities/appointment_entity.dart';

/// Base class for Appointment States
abstract class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AppointmentInitial extends AppointmentState {
  const AppointmentInitial();
}

/// Loading state
class AppointmentLoading extends AppointmentState {
  const AppointmentLoading();
}

/// Loaded state with appointments list
class AppointmentLoaded extends AppointmentState {
  final List<AppointmentEntity> appointments;

  const AppointmentLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}

/// Single appointment detail loaded
class AppointmentDetailLoaded extends AppointmentState {
  final AppointmentEntity appointment;

  const AppointmentDetailLoaded(this.appointment);

  @override
  List<Object?> get props => [appointment];
}

/// Action success state (confirm/complete/cancel)
class AppointmentActionSuccess extends AppointmentState {
  final String message;

  const AppointmentActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Appointment created successfully
class AppointmentCreated extends AppointmentState {
  final AppointmentEntity appointment;
  final String message;

  const AppointmentCreated({
    required this.appointment,
    this.message = 'Tạo lịch hẹn thành công',
  });

  @override
  List<Object?> get props => [appointment, message];
}

/// Error state
class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Empty state (no appointments)
class AppointmentEmpty extends AppointmentState {
  const AppointmentEmpty();
}

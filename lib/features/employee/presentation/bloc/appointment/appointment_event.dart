import 'package:equatable/equatable.dart';

/// Base class for Appointment Events
abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load appointments assigned to current staff
class LoadMyAssignedAppointments extends AppointmentEvent {
  const LoadMyAssignedAppointments();
}

/// Event to load all appointments
class LoadAllAppointments extends AppointmentEvent {
  const LoadAllAppointments();
}

/// Event to load appointment by ID
class LoadAppointmentById extends AppointmentEvent {
  final int appointmentId;

  const LoadAppointmentById(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

/// Event to confirm appointment
class ConfirmAppointmentEvent extends AppointmentEvent {
  final int appointmentId;

  const ConfirmAppointmentEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

/// Event to complete appointment
class CompleteAppointmentEvent extends AppointmentEvent {
  final int appointmentId;

  const CompleteAppointmentEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

/// Event to cancel appointment
class CancelAppointmentEvent extends AppointmentEvent {
  final int appointmentId;

  const CancelAppointmentEvent(this.appointmentId);

  @override
  List<Object?> get props => [appointmentId];
}

/// Event to create appointment for customer
class CreateAppointmentForCustomerEvent extends AppointmentEvent {
  final String customerId;
  final DateTime appointmentDate;
  final String? name;

  const CreateAppointmentForCustomerEvent({
    required this.customerId,
    required this.appointmentDate,
    this.name,
  });

  @override
  List<Object?> get props => [customerId, appointmentDate, name];
}

/// Event to refresh appointments
class RefreshAppointments extends AppointmentEvent {
  const RefreshAppointments();
}

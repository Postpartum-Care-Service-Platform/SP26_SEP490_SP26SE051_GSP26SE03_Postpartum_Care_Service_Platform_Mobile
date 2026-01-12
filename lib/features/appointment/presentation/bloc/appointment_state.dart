import 'package:equatable/equatable.dart';
import '../../domain/entities/appointment_entity.dart';

/// Appointment states
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

/// Loaded state
class AppointmentLoaded extends AppointmentState {
  final List<AppointmentEntity> appointments;

  const AppointmentLoaded({
    required this.appointments,
  });

  @override
  List<Object?> get props => [appointments];

  AppointmentLoaded copyWith({
    List<AppointmentEntity>? appointments,
  }) {
    return AppointmentLoaded(
      appointments: appointments ?? this.appointments,
    );
  }
}

/// Creating state
class AppointmentCreating extends AppointmentState {
  const AppointmentCreating();
}

/// Updating state
class AppointmentUpdating extends AppointmentState {
  const AppointmentUpdating();
}

/// Cancelling state
class AppointmentCancelling extends AppointmentState {
  const AppointmentCancelling();
}

/// Success state (for create/update/cancel)
class AppointmentSuccess extends AppointmentState {
  final String message;

  const AppointmentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class AppointmentError extends AppointmentState {
  final String message;

  const AppointmentError(this.message);

  @override
  List<Object?> get props => [message];
}

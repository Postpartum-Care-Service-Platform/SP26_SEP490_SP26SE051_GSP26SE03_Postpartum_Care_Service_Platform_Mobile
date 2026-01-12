import 'package:equatable/equatable.dart';

/// Appointment events
abstract class AppointmentEvent extends Equatable {
  const AppointmentEvent();

  @override
  List<Object?> get props => [];
}

/// Load appointments event
class AppointmentLoadRequested extends AppointmentEvent {
  const AppointmentLoadRequested();
}

/// Refresh appointments event
class AppointmentRefresh extends AppointmentEvent {
  const AppointmentRefresh();
}

/// Create appointment event
class AppointmentCreateRequested extends AppointmentEvent {
  final String date;
  final String time;
  final String name;

  const AppointmentCreateRequested({
    required this.date,
    required this.time,
    required this.name,
  });

  @override
  List<Object?> get props => [date, time, name];
}

/// Update appointment event
class AppointmentUpdateRequested extends AppointmentEvent {
  final int id;
  final String date;
  final String time;
  final String name;

  const AppointmentUpdateRequested({
    required this.id,
    required this.date,
    required this.time,
    required this.name,
  });

  @override
  List<Object?> get props => [id, date, time, name];
}

/// Cancel appointment event
class AppointmentCancelRequested extends AppointmentEvent {
  final int id;

  const AppointmentCancelRequested(this.id);

  @override
  List<Object?> get props => [id];
}

import 'package:equatable/equatable.dart';

/// Appointment status enum
enum AppointmentStatus {
  scheduled,
  rescheduled,
  completed,
  pending,
  cancelled,
}

/// User info entity (for customer and staff)
class UserInfoEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String? phone;

  const UserInfoEntity({
    required this.id,
    required this.email,
    required this.username,
    this.phone,
  });

  @override
  List<Object?> get props => [id, email, username, phone];
}

/// Appointment entity - Domain layer
class AppointmentEntity extends Equatable {
  final int id;
  final DateTime appointmentDate;
  final String name;
  final AppointmentStatus status;
  final DateTime createdAt;
  final UserInfoEntity? customer;
  final UserInfoEntity? staff;

  const AppointmentEntity({
    required this.id,
    required this.appointmentDate,
    required this.name,
    required this.status,
    required this.createdAt,
    this.customer,
    this.staff,
  });

  @override
  List<Object?> get props => [
        id,
        appointmentDate,
        name,
        status,
        createdAt,
        customer,
        staff,
      ];
}

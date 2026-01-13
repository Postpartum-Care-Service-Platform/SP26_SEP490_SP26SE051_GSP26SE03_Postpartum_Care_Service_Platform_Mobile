import 'package:equatable/equatable.dart';

/// Appointment type entity - Domain layer
class AppointmentTypeEntity extends Equatable {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;

  const AppointmentTypeEntity({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, isActive, createdAt];
}


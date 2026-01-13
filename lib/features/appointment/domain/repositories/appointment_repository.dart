import '../entities/appointment_entity.dart';
import '../entities/appointment_type_entity.dart';

/// Appointment repository interface - Domain layer
abstract class AppointmentRepository {
  /// Get all appointments for current user
  Future<List<AppointmentEntity>> getAppointments();

  /// Create a new appointment
  Future<AppointmentEntity> createAppointment({
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  });

  /// Update an existing appointment
  Future<AppointmentEntity> updateAppointment({
    required int id,
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  });

  /// Cancel an appointment
  Future<void> cancelAppointment(int id);

  /// Get appointment types
  Future<List<AppointmentTypeEntity>> getAppointmentTypes();
}

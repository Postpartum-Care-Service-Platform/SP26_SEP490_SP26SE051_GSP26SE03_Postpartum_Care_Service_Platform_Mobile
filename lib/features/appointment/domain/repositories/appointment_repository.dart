import '../entities/appointment_entity.dart';

/// Appointment repository interface - Domain layer
abstract class AppointmentRepository {
  /// Get all appointments for current user
  Future<List<AppointmentEntity>> getAppointments();

  /// Create a new appointment
  Future<AppointmentEntity> createAppointment({
    required String date,
    required String time,
    required String name,
  });

  /// Update an existing appointment
  Future<AppointmentEntity> updateAppointment({
    required int id,
    required String date,
    required String time,
    required String name,
  });

  /// Cancel an appointment
  Future<void> cancelAppointment(int id);
}

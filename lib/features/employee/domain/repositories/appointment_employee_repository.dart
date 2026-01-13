import '../entities/appointment_entity.dart';

/// Appointment Repository Interface for Employee
/// Defines contract for appointment data operations
abstract class AppointmentEmployeeRepository {
  /// Get appointments assigned to current staff
  /// Returns list of appointments assigned to logged-in employee
  Future<List<AppointmentEntity>> getMyAssignedAppointments();

  /// Get all appointments (for staff/admin)
  /// Returns all appointments in the system
  Future<List<AppointmentEntity>> getAllAppointments();

  /// Get appointment by ID
  /// Returns appointment detail by ID
  /// [appointmentId] - The ID of the appointment to retrieve
  Future<AppointmentEntity> getAppointmentById(int appointmentId);

  /// Confirm appointment (staff confirms the appointment)
  /// [appointmentId] - The ID of the appointment to confirm
  /// Returns success message
  Future<String> confirmAppointment(int appointmentId);

  /// Complete appointment (mark as completed)
  /// [appointmentId] - The ID of the appointment to complete
  /// Returns success message
  Future<String> completeAppointment(int appointmentId);

  /// Cancel appointment
  /// [appointmentId] - The ID of the appointment to cancel
  /// Returns success message
  Future<String> cancelAppointment(int appointmentId);

  /// Create appointment for customer (staff creates for customer)
  /// [customerId] - Customer's user ID
  /// [appointmentDate] - Date and time of appointment
  /// [name] - Appointment name/title
  /// Returns created appointment entity
  Future<AppointmentEntity> createAppointmentForCustomer({
    required String customerId,
    required DateTime appointmentDate,
    String? name,
  });
}

import '../repositories/appointment_employee_repository.dart';

/// Use case to cancel appointment
class CancelAppointment {
  final AppointmentEmployeeRepository repository;

  CancelAppointment(this.repository);

  /// Execute the use case
  /// [appointmentId] - The ID of the appointment to cancel
  /// Returns success message
  Future<String> call(int appointmentId) async {
    return await repository.cancelAppointment(appointmentId);
  }
}

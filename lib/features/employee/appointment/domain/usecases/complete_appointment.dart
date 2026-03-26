import '../repositories/appointment_employee_repository.dart';

/// Use case to complete appointment (mark as completed)
class CompleteAppointment {
  final AppointmentEmployeeRepository repository;

  CompleteAppointment(this.repository);

  /// Execute the use case
  /// [appointmentId] - The ID of the appointment to complete
  /// Returns success message
  Future<String> call(int appointmentId) async {
    return await repository.completeAppointment(appointmentId);
  }
}

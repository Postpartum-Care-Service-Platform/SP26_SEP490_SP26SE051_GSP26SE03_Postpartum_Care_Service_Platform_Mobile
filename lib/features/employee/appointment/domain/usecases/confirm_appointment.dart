import '../repositories/appointment_employee_repository.dart';

/// Use case to confirm appointment (staff confirms)
class ConfirmAppointment {
  final AppointmentEmployeeRepository repository;

  ConfirmAppointment(this.repository);

  /// Execute the use case
  /// [appointmentId] - The ID of the appointment to confirm
  /// Returns success message
  Future<String> call(int appointmentId) async {
    return await repository.confirmAppointment(appointmentId);
  }
}

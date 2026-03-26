import '../entities/appointment_entity.dart';
import '../repositories/appointment_employee_repository.dart';

/// Use case to get appointment detail by ID
class GetAppointmentById {
  final AppointmentEmployeeRepository repository;

  GetAppointmentById(this.repository);

  /// Execute the use case
  /// [appointmentId] - The ID of the appointment to retrieve
  /// Returns appointment entity
  Future<AppointmentEntity> call(int appointmentId) async {
    return await repository.getAppointmentById(appointmentId);
  }
}

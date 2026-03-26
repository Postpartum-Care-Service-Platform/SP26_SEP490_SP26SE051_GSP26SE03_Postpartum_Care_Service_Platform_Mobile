import '../entities/appointment_entity.dart';
import '../repositories/appointment_employee_repository.dart';

/// Use case to get all appointments (for staff/admin)
class GetAllAppointments {
  final AppointmentEmployeeRepository repository;

  GetAllAppointments(this.repository);

  /// Execute the use case
  /// Returns all appointments in the system
  Future<List<AppointmentEntity>> call() async {
    return await repository.getAllAppointments();
  }
}

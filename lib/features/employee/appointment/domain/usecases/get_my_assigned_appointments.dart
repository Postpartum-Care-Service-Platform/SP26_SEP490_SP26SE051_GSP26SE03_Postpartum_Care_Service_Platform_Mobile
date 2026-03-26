import '../entities/appointment_entity.dart';
import '../repositories/appointment_employee_repository.dart';

/// Use case to get appointments assigned to current staff
class GetMyAssignedAppointments {
  final AppointmentEmployeeRepository repository;

  GetMyAssignedAppointments(this.repository);

  /// Execute the use case
  /// Returns list of appointments assigned to logged-in employee
  Future<List<AppointmentEntity>> call() async {
    return await repository.getMyAssignedAppointments();
  }
}

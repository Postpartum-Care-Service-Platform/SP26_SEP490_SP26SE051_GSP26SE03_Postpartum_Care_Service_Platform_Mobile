import '../entities/appointment_entity.dart';
import '../repositories/appointment_employee_repository.dart';

/// Use case to create appointment for customer (staff creates)
class CreateAppointmentForCustomer {
  final AppointmentEmployeeRepository repository;

  CreateAppointmentForCustomer(this.repository);

  /// Execute the use case
  /// [customerId] - Customer's user ID
  /// [appointmentDate] - Date and time of appointment
  /// [name] - Appointment name/title
  /// Returns created appointment entity
  Future<AppointmentEntity> call({
    required String customerId,
    required DateTime appointmentDate,
    String? name,
  }) async {
    return await repository.createAppointmentForCustomer(
      customerId: customerId,
      appointmentDate: appointmentDate,
      name: name,
    );
  }
}

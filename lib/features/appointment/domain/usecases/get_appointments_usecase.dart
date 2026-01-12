import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

/// Get appointments use case
class GetAppointmentsUsecase {
  final AppointmentRepository repository;

  GetAppointmentsUsecase(this.repository);

  Future<List<AppointmentEntity>> call() async {
    return await repository.getAppointments();
  }
}

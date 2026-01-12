import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

/// Create appointment use case
class CreateAppointmentUsecase {
  final AppointmentRepository repository;

  CreateAppointmentUsecase(this.repository);

  Future<AppointmentEntity> call({
    required String date,
    required String time,
    required String name,
  }) async {
    return await repository.createAppointment(
      date: date,
      time: time,
      name: name,
    );
  }
}

import '../entities/appointment_entity.dart';
import '../repositories/appointment_repository.dart';

/// Update appointment use case
class UpdateAppointmentUsecase {
  final AppointmentRepository repository;

  UpdateAppointmentUsecase(this.repository);

  Future<AppointmentEntity> call({
    required int id,
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  }) async {
    return await repository.updateAppointment(
      id: id,
      date: date,
      time: time,
      name: name,
      appointmentTypeId: appointmentTypeId,
    );
  }
}

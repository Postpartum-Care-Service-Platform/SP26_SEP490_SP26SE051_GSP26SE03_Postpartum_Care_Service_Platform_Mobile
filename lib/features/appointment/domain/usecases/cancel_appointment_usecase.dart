import '../repositories/appointment_repository.dart';

/// Cancel appointment use case
class CancelAppointmentUsecase {
  final AppointmentRepository repository;

  CancelAppointmentUsecase(this.repository);

  Future<void> call(int id) async {
    return await repository.cancelAppointment(id);
  }
}

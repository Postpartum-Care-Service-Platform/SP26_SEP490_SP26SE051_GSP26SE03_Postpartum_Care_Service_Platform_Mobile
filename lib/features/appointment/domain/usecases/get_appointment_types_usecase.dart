import '../entities/appointment_type_entity.dart';
import '../repositories/appointment_repository.dart';

class GetAppointmentTypesUsecase {
  final AppointmentRepository repository;

  GetAppointmentTypesUsecase(this.repository);

  Future<List<AppointmentTypeEntity>> call() async {
    return await repository.getAppointmentTypes();
  }
}


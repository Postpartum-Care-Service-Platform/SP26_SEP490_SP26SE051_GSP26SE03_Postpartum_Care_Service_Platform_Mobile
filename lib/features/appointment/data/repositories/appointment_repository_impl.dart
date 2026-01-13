import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_type_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../datasources/appointment_remote_datasource.dart';

/// Appointment repository implementation - Data layer
class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDataSource dataSource;

  AppointmentRepositoryImpl({required this.dataSource});

  @override
  Future<List<AppointmentEntity>> getAppointments() async {
    final models = await dataSource.getAppointments();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<AppointmentEntity> createAppointment({
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  }) async {
    final model = await dataSource.createAppointment(
      date: date,
      time: time,
      name: name,
      appointmentTypeId: appointmentTypeId,
    );
    return model.toEntity();
  }

  @override
  Future<AppointmentEntity> updateAppointment({
    required int id,
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  }) async {
    final model = await dataSource.updateAppointment(
      id: id,
      date: date,
      time: time,
      name: name,
      appointmentTypeId: appointmentTypeId,
    );
    return model.toEntity();
  }

  @override
  Future<void> cancelAppointment(int id) async {
    await dataSource.cancelAppointment(id);
  }

  @override
  Future<List<AppointmentTypeEntity>> getAppointmentTypes() async {
    final models = await dataSource.getAppointmentTypes();
    return models.map((m) => m.toEntity()).toList();
  }
}

import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_employee_repository.dart';
import '../datasources/appointment_employee_remote_datasource.dart';
import '../models/create_appointment_request_model.dart';

/// Implementation of AppointmentEmployeeRepository
class AppointmentEmployeeRepositoryImpl implements AppointmentEmployeeRepository {
  final AppointmentEmployeeRemoteDataSource remoteDataSource;

  AppointmentEmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AppointmentEntity>> getMyAssignedAppointments() async {
    try {
      final models = await remoteDataSource.getMyAssignedAppointments();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<AppointmentEntity>> getAllAppointments() async {
    try {
      final models = await remoteDataSource.getAllAppointments();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppointmentEntity> getAppointmentById(int appointmentId) async {
    try {
      final model = await remoteDataSource.getAppointmentById(appointmentId);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> confirmAppointment(int appointmentId) async {
    try {
      return await remoteDataSource.confirmAppointment(appointmentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> completeAppointment(int appointmentId) async {
    try {
      return await remoteDataSource.completeAppointment(appointmentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> cancelAppointment(int appointmentId) async {
    try {
      return await remoteDataSource.cancelAppointment(appointmentId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AppointmentEntity> createAppointmentForCustomer({
    required String customerId,
    required DateTime appointmentDate,
    String? name,
  }) async {
    try {
      final request = CreateAppointmentForCustomerRequestModel(
        customerId: customerId,
        appointmentDate: appointmentDate,
        name: name,
      );
      
      final model = await remoteDataSource.createAppointmentForCustomer(request);
      return model.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}

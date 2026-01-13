import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/appointment_model.dart';
import '../models/appointment_type_model.dart';

/// Appointment remote data source interface
abstract class AppointmentRemoteDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> createAppointment({
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  });
  Future<AppointmentModel> updateAppointment({
    required int id,
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  });
  Future<void> cancelAppointment(int id);
  Future<List<AppointmentTypeModel>> getAppointmentTypes();
}

/// Appointment remote data source implementation
class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final Dio dio;

  AppointmentRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      final response = await dio.get(ApiEndpoints.appointments);

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              AppointmentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Failed to load appointments: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<AppointmentModel> createAppointment({
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.appointments,
        data: {
          'date': date,
          'time': time,
          'name': name,
          if (appointmentTypeId != null) 'appointmentTypeId': appointmentTypeId,
        },
      );

      return AppointmentModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        String? errorMessage;
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] as String?;
          } else if (responseData is String) {
            errorMessage = responseData;
          }
        } catch (parseError) {
          // Ignore parse error
        }
        throw Exception(
            errorMessage ?? 'Failed to create appointment: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<AppointmentModel> updateAppointment({
    required int id,
    required String date,
    required String time,
    required String name,
    int? appointmentTypeId,
  }) async {
    try {
      final response = await dio.put(
        ApiEndpoints.appointmentById(id),
        data: {
          'date': date,
          'time': time,
          'name': name,
          if (appointmentTypeId != null) 'appointmentTypeId': appointmentTypeId,
        },
      );

      return AppointmentModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null) {
        String? errorMessage;
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] as String?;
          } else if (responseData is String) {
            errorMessage = responseData;
          }
        } catch (parseError) {
          // Ignore parse error
        }
        throw Exception(
            errorMessage ?? 'Failed to update appointment: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<void> cancelAppointment(int id) async {
    try {
      await dio.put(ApiEndpoints.cancelAppointment(id));
    } on DioException catch (e) {
      if (e.response != null) {
        String? errorMessage;
        try {
          final responseData = e.response?.data;
          if (responseData is Map<String, dynamic>) {
            errorMessage = responseData['message'] as String?;
          } else if (responseData is String) {
            errorMessage = responseData;
          }
        } catch (parseError) {
          // Ignore parse error
        }
        throw Exception(
            errorMessage ?? 'Failed to cancel appointment: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<AppointmentTypeModel>> getAppointmentTypes() async {
    try {
      final response = await dio.get(ApiEndpoints.appointmentTypes);
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) =>
              AppointmentTypeModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            'Failed to load appointment types: ${e.response?.statusCode}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

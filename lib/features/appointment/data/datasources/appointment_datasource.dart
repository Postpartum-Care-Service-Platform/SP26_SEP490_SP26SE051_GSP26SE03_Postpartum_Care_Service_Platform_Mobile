import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/appointment_model.dart';

/// Appointment data source interface
abstract class AppointmentDataSource {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> createAppointment({
    required String date,
    required String time,
    required String name,
  });
  Future<AppointmentModel> updateAppointment({
    required int id,
    required String date,
    required String time,
    required String name,
  });
  Future<void> cancelAppointment(int id);
}

/// Appointment data source implementation
class AppointmentDataSourceImpl implements AppointmentDataSource {
  final Dio dio;

  AppointmentDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

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
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.appointments,
        data: {
          'date': date,
          'time': time,
          'name': name,
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
  }) async {
    try {
      final response = await dio.put(
        ApiEndpoints.appointmentById(id),
        data: {
          'date': date,
          'time': time,
          'name': name,
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
}

import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/home_activity_model.dart';
import '../models/home_staff_model.dart';
import '../models/home_service_booking_model.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../../../booking/data/models/payment_link_model.dart';
import '../../../booking/data/models/payment_status_model.dart';

/// Home Service Remote Data Source Interface
abstract class HomeServiceRemoteDataSource {
  Future<List<HomeActivityModel>> getHomeActivities();

  Future<List<HomeStaffModel>> getFreeHomeStaffInDateList(
    List<StaffAvailabilityRequest> requests,
  );

  Future<HomeServiceBookingModel> bookHomeService({
    required String staffId,
    required List<HomeServiceSelectionEntity> selections,
  });

  Future<PaymentLinkModel> createHomeServicePaymentLink({
    required int bookingId,
    required String type,
    required String staffId,
  });

  Future<PaymentStatusModel> checkPaymentStatus(String orderCode);
}

/// Staff Availability Request
class StaffAvailabilityRequest {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  const StaffAvailabilityRequest({
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],
      'startTime': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00',
      'endTime': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00',
    };
  }
}

/// Home Service Remote Data Source Implementation
class HomeServiceRemoteDataSourceImpl implements HomeServiceRemoteDataSource {
  final Dio dio;

  HomeServiceRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<List<HomeActivityModel>> getHomeActivities() async {
    try {
      final response = await dio.get(ApiEndpoints.homeActivities);

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => HomeActivityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<HomeStaffModel>> getFreeHomeStaffInDateList(
    List<StaffAvailabilityRequest> requests,
  ) async {
    try {
      final response = await dio.post(
        ApiEndpoints.freeHomeStaffInDateList,
        data: requests.map((r) => r.toJson()).toList(),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => HomeStaffModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<HomeServiceBookingModel> bookHomeService({
    required String staffId,
    required List<HomeServiceSelectionEntity> selections,
  }) async {
    try {
      // Convert selections to API format: one start/end time per activity.
      final services = selections
          .where((selection) => selection.dateTimeSlots.isNotEmpty)
          .map((selection) {
        final entries = selection.dateTimeSlots.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        final allDates = entries
            .map((entry) => DateTime(entry.key.year, entry.key.month, entry.key.day))
            .toList();

        // Keep deterministic payload: always use time from earliest selected date.
        final firstTimeSlot = entries.first.value;

        return {
          'activityId': selection.activity.id,
          'serviceDates': allDates
              .map((date) => date.toIso8601String().split('T')[0])
              .toList(),
          'startTime': '${firstTimeSlot.startTime.hour.toString().padLeft(2, '0')}:${firstTimeSlot.startTime.minute.toString().padLeft(2, '0')}:00',
          'endTime': '${firstTimeSlot.endTime.hour.toString().padLeft(2, '0')}:${firstTimeSlot.endTime.minute.toString().padLeft(2, '0')}:00',
        };
      }).toList();

      final response = await dio.post(
        ApiEndpoints.bookHomeService,
        data: {
          'staffId': staffId,
          'services': services,
        },
      );

      return HomeServiceBookingModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'Có lỗi xảy ra';

      if (data is Map<String, dynamic>) {
        message = data['error'] as String? ??
            data['message'] as String? ??
            message;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return 'Dữ liệu không hợp lệ: $message';
        case 401:
          return 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
        case 403:
          return 'Bạn không có quyền thực hiện thao tác này.';
        case 404:
          return 'Không tìm thấy dữ liệu.';
        case 500:
          return 'Lỗi server: $message';
        default:
          return message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Kết nối timeout. Vui lòng thử lại.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
    }

    return 'Có lỗi xảy ra: ${error.message}';
  }

  @override
  Future<PaymentLinkModel> createHomeServicePaymentLink({
    required int bookingId,
    required String type,
    required String staffId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createHomeServicePaymentLink,
        data: {
          'request': {
            'bookingId': bookingId,
            'type': type,
            'staffId': staffId,
          },
        },
      );

      return PaymentLinkModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<PaymentStatusModel> checkPaymentStatus(String orderCode) async {
    try {
      final response = await dio.get(
        ApiEndpoints.checkPaymentStatus(orderCode),
      );

      return PaymentStatusModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}

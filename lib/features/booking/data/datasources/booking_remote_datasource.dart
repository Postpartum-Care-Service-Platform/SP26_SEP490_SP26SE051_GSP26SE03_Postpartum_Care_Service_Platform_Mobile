import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/booking_model.dart';
import '../models/payment_link_model.dart';
import '../models/payment_status_model.dart';

/// Booking Remote Data Source Interface
abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking({
    required int packageId,
    required int roomId,
    required DateTime startDate,
  });

  Future<BookingModel> getBookingById(int id);

  Future<List<BookingModel>> getBookings();

  Future<PaymentLinkModel> createPaymentLink({
    required int bookingId,
    required String type,
  });

  Future<PaymentStatusModel> checkPaymentStatus(String orderCode);
}

/// Booking Remote Data Source Implementation
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<BookingModel> createBooking({
    required int packageId,
    required int roomId,
    required DateTime startDate,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createBooking,
        data: {
          'packageId': packageId,
          'roomId': roomId,
          'startDate': startDate.toIso8601String().split('T')[0],
        },
      );

      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<BookingModel> getBookingById(int id) async {
    try {
      final response = await dio.get(ApiEndpoints.getBookingById(id));

      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<List<BookingModel>> getBookings() async {
    try {
      final response = await dio.get(ApiEndpoints.getBookings);

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<PaymentLinkModel> createPaymentLink({
    required int bookingId,
    required String type,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createPaymentLink,
        data: {
          'bookingId': bookingId,
          'type': type,
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
          return 'Không tìm thấy booking.';
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
}

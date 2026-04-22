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
    required List<int> familyProfileIds,
  });

  /// Staff creates booking for a specific customer
  Future<BookingModel> createBookingForCustomer({
    required String customerId,
    required int packageId,
    required int roomId,
    required DateTime startDate,
    required List<int> familyProfileIds,
    double? discountAmount,
  });

  Future<BookingModel> getBookingById(int id);

  Future<List<BookingModel>> getBookings();

  /// Staff/Admin: Get all bookings in system
  Future<List<BookingModel>> getAllBookings();

  /// Home Staff: Get bookings assigned to current home staff
  Future<List<BookingModel>> getBookingsByHomeStaff();

  /// Staff/Admin: Confirm booking
  Future<String> confirmBooking(int id);

  /// Staff/Admin: Cancel booking
  Future<String> cancelBooking(int id);

  /// Staff/Admin: Complete booking
  Future<String> completeBooking(int id);

  /// Staff/Admin: Check-in booking
  Future<String> checkInBooking(int id);

  Future<PaymentLinkModel> createPaymentLink({
    required int bookingId,
    required String type,
    bool isHomeService = false,
    String? staffId,
  });

  Future<PaymentStatusModel> checkPaymentStatus(String orderCode);

  /// Customer: Confirm checkout completion (2-step verification)
  Future<String> confirmCompletion(int id);

}

/// Booking Remote Data Source Implementation
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  // Fast-fix cache cho danh sách booking toàn hệ thống.
  static List<BookingModel>? _allBookingsCache;

  BookingRemoteDataSourceImpl({Dio? dio}) : dio = dio ?? ApiClient.dio;

  @override
  Future<BookingModel> createBooking({
    required int packageId,
    required int roomId,
    required DateTime startDate,
    required List<int> familyProfileIds,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.createBooking,
        data: {
          'packageId': packageId,
          'roomId': roomId,
          'startDate': startDate.toIso8601String().split('T')[0],
          'familyProfileIds': familyProfileIds,
        },
      );

      return BookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<BookingModel> createBookingForCustomer({
    required String customerId,
    required int packageId,
    required int roomId,
    required DateTime startDate,
    required List<int> familyProfileIds,
    double? discountAmount,
  }) async {
    try {
      final body = <String, dynamic>{
        'customerId': customerId,
        'packageId': packageId,
        'roomId': roomId,
        'startDate': startDate.toIso8601String().split('T')[0],
        'familyProfileIds': familyProfileIds,
      };
      if (discountAmount != null) {
        body['discountAmount'] = discountAmount;
      }

      final response = await dio.post(
        ApiEndpoints.createBookingForCustomer,
        data: body,
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
  Future<List<BookingModel>> getAllBookings() async {
    Future<Response<dynamic>> requestOnce() {
      return dio.get(
        ApiEndpoints.getAllBookings,
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 90),
        ),
      );
    }

    try {
      final response = await requestOnce();

      final List<dynamic> data = response.data as List<dynamic>;
      final bookings = data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _allBookingsCache = bookings;
      return bookings;
    } on DioException catch (e) {
      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;

      if (isTimeout) {
        try {
          final retryResponse = await requestOnce();
          final List<dynamic> retryData = retryResponse.data as List<dynamic>;
          final retryBookings = retryData
              .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
              .toList();

          _allBookingsCache = retryBookings;
          return retryBookings;
        } on DioException {
          if (_allBookingsCache != null) {
            return _allBookingsCache!;
          }
          throw Exception('Kết nối tới máy chủ chậm. Vui lòng thử lại sau ít phút.');
        }
      }

      if (_allBookingsCache != null) {
        return _allBookingsCache!;
      }

      throw _handleError(e);
    }
  }

  @override
  Future<List<BookingModel>> getBookingsByHomeStaff() async {
    Future<Response<dynamic>> requestOnce() {
      return dio.get(
        ApiEndpoints.getBookingsByHomeStaff,
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 90),
        ),
      );
    }

    try {
      final response = await requestOnce();
      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;

      if (isTimeout) {
        try {
          final retryResponse = await requestOnce();
          final List<dynamic> retryData = retryResponse.data as List<dynamic>;
          return retryData
              .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
              .toList();
        } on DioException {
          throw Exception('Kết nối tới máy chủ chậm. Vui lòng thử lại sau ít phút.');
        }
      }

      throw _handleError(e);
    }
  }

  @override
  Future<PaymentLinkModel> createPaymentLink({
    required int bookingId,
    required String type,
    bool isHomeService = false,
    String? staffId,
  }) async {
    try {
      final response = await dio.post(
        isHomeService
            ? ApiEndpoints.createHomeServicePaymentLink
            : ApiEndpoints.createPaymentLink,
        data: isHomeService
            ? {
                'bookingId': bookingId,
                'type': type,
                'staffId': staffId ?? '',
              }
            : {
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

  @override
  Future<String> confirmBooking(int id) async {
    try {
      final response = await dio.put(ApiEndpoints.confirmBooking(id));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Xác nhận booking thành công';
      }
      return 'Xác nhận booking thành công';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> cancelBooking(int id) async {
    try {
      final response = await dio.put(ApiEndpoints.cancelBooking(id));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Hủy booking thành công';
      }
      return 'Hủy booking thành công';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> completeBooking(int id) async {
    try {
      final response = await dio.put(ApiEndpoints.completeBooking(id));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Hoàn thành booking thành công';
      }
      return 'Hoàn thành booking thành công';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  @override
  Future<String> checkInBooking(int id) async {
    try {
      final response = await dio.put(ApiEndpoints.checkInBooking(id));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Check-in thành công';
      }
      return 'Check-in thành công';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  @override
  Future<String> confirmCompletion(int id) async {
    try {
      final response = await dio.put(ApiEndpoints.confirmCompletion(id));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['message'] as String? ?? 'Xác nhận hoàn thành thành công';
      }
      return 'Xác nhận hoàn thành thành công';
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
        message =
            data['error'] as String? ?? data['message'] as String? ?? message;
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

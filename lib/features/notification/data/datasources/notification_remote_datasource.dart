import 'package:dio/dio.dart';
import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../models/notification_model.dart';

/// Notification remote data source interface
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> getNotificationById(String notificationId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadCount();
}

/// Notification remote data source implementation backed by API
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? ApiClient.dio;

  final Dio _dio;

  /// Local cache to support read/mark interactions even if API lacks endpoints.
  List<NotificationModel> _cachedNotifications = [];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    Future<Response<dynamic>> requestOnce() {
      return _dio.get(
        ApiEndpoints.notificationsMe,
        options: Options(
          receiveTimeout: const Duration(seconds: 90),
          sendTimeout: const Duration(seconds: 90),
        ),
      );
    }

    try {
      final response = await requestOnce();
      final data = response.data;

      if (data is List) {
        final notifications = data
            .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _cachedNotifications = notifications;
        return notifications;
      }

      throw Exception('Phản hồi thông báo không hợp lệ');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // If it's a 401, it means ApiClient refresh failed or was skipped
        if (_cachedNotifications.isNotEmpty) return _cachedNotifications;
        throw Exception('Phiên làm việc đã hết hạn. Vui lòng đăng nhập lại hoặc thử lại.');
      }

      final isTimeout =
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout;

      if (isTimeout) {
        try {
          final retryResponse = await requestOnce();
          final retryData = retryResponse.data;
          if (retryData is List) {
            final retryNotifications = retryData
                .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
                .toList();
            _cachedNotifications = retryNotifications;
            return retryNotifications;
          }
        } on DioException {
          if (_cachedNotifications.isNotEmpty) {
            return _cachedNotifications;
          }
          throw Exception('Kết nối tới máy chủ chậm. Vui lòng thử lại sau ít phút.');
        }
      }

      if (_cachedNotifications.isNotEmpty) {
        return _cachedNotifications;
      }

      // Provide a cleaner message instead of raw technical Dio error
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Lỗi không xác định';
      throw Exception('Không thể tải thông báo: $errorMessage');
    }
  }

  @override
  Future<NotificationModel> getNotificationById(String notificationId) async {
    try {
      final id = int.tryParse(notificationId);
      if (id == null) {
        throw Exception('ID thông báo không hợp lệ');
      }
      final response = await _dio.get(ApiEndpoints.getNotificationById(id));
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return NotificationModel.fromJson(data);
      }
      throw Exception('Phản hồi thông báo không hợp lệ');
    } catch (e) {
      if (e is DioException) {
        throw Exception('Không thể tải chi tiết thông báo: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final id = int.tryParse(notificationId);
      if (id == null) {
        throw Exception('ID thông báo không hợp lệ');
      }
      await _dio.put(ApiEndpoints.markNotificationAsRead(id));
      // Update cache after successful API call
      _cachedNotifications = _cachedNotifications
          .map(
            (n) => n.id == notificationId ? n.copyWith(isRead: true) : n,
          )
          .toList();
    } catch (e) {
      if (e is DioException) {
        throw Exception('Không thể đánh dấu đã đọc: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<void> markAllAsRead() async {
    _cachedNotifications =
        _cachedNotifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _cachedNotifications =
        _cachedNotifications.where((n) => n.id != notificationId).toList();
  }

  @override
  Future<int> getUnreadCount() async {
    if (_cachedNotifications.isEmpty) {
      _cachedNotifications = await getNotifications();
    }
    return _cachedNotifications.where((n) => !n.isRead).length;
  }
}

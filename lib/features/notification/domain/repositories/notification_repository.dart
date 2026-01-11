import '../entities/notification_entity.dart';

/// Notification repository interface - Domain layer
abstract class NotificationRepository {
  /// Get all notifications
  Future<List<NotificationEntity>> getNotifications();

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Get unread count
  Future<int> getUnreadCount();
}

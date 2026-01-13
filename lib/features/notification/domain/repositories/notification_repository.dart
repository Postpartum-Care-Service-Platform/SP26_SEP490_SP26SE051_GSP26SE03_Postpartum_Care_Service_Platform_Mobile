import '../entities/notification_entity.dart';

/// Notification repository interface - Domain layer
abstract class NotificationRepository {
  /// Get all notifications
  Future<List<NotificationEntity>> getNotifications();

  /// Get notification by ID
  Future<NotificationEntity> getNotificationById(String notificationId);

  /// Mark notification as read
  Future<void> markAsRead(String notificationId);

  /// Mark all notifications as read
  Future<void> markAllAsRead();

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Get unread count
  Future<int> getUnreadCount();
}

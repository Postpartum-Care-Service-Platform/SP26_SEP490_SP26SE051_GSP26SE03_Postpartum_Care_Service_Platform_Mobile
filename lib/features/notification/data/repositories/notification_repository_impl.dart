import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

/// Notification repository implementation - Data layer
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource dataSource;

  NotificationRepositoryImpl(this.dataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final models = await dataSource.getNotifications();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<NotificationEntity> getNotificationById(String notificationId) async {
    final model = await dataSource.getNotificationById(notificationId);
    return model.toEntity();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await dataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() async {
    await dataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await dataSource.deleteNotification(notificationId);
  }

  @override
  Future<int> getUnreadCount() async {
    return await dataSource.getUnreadCount();
  }
}

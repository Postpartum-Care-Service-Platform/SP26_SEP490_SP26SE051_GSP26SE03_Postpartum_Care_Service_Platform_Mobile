import '../repositories/notification_repository.dart';

/// Mark notification as read use case
class MarkNotificationReadUsecase {
  final NotificationRepository repository;

  MarkNotificationReadUsecase(this.repository);

  Future<void> call(String notificationId) async {
    await repository.markAsRead(notificationId);
  }
}

import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Get notification by ID use case
class GetNotificationByIdUsecase {
  final NotificationRepository repository;

  GetNotificationByIdUsecase(this.repository);

  Future<NotificationEntity> call(String notificationId) async {
    return await repository.getNotificationById(notificationId);
  }
}

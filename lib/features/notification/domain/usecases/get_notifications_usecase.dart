import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Get notifications use case
class GetNotificationsUsecase {
  final NotificationRepository repository;

  GetNotificationsUsecase(this.repository);

  Future<List<NotificationEntity>> call() async {
    return await repository.getNotifications();
  }
}

import '../repositories/notification_repository.dart';

/// Get unread notification count use case
class GetUnreadCountUsecase {
  final NotificationRepository repository;

  GetUnreadCountUsecase(this.repository);

  Future<int> call() async {
    return await repository.getUnreadCount();
  }
}

import 'package:equatable/equatable.dart';

/// Notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load notifications event
class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

/// Mark notification as read event
class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsRead(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Mark all notifications as read event
class NotificationMarkAllAsRead extends NotificationEvent {
  const NotificationMarkAllAsRead();
}

/// Delete notification event
class NotificationDelete extends NotificationEvent {
  final String notificationId;

  const NotificationDelete(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Refresh notifications event
class NotificationRefresh extends NotificationEvent {
  const NotificationRefresh();
}

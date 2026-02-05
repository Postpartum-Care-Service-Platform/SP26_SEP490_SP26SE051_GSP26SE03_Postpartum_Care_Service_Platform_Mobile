import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

/// Notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading state
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Loaded state
class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final NotificationEntity? viewingDetail;

  static const Object _viewingDetailNoChange = Object();

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.viewingDetail,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, viewingDetail];

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    int? unreadCount,
    Object? viewingDetail = _viewingDetailNoChange,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      viewingDetail: identical(viewingDetail, _viewingDetailNoChange)
          ? this.viewingDetail
          : viewingDetail as NotificationEntity?,
    );
  }
}

/// Detail loaded state
class NotificationDetailLoaded extends NotificationState {
  final NotificationEntity notification;

  const NotificationDetailLoaded({required this.notification});

  @override
  List<Object?> get props => [notification];
}

/// Error state
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}

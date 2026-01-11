import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// Notification BloC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUsecase getNotificationsUsecase;
  final MarkNotificationReadUsecase markNotificationReadUsecase;
  final GetUnreadCountUsecase getUnreadCountUsecase;

  NotificationBloc({
    required this.getNotificationsUsecase,
    required this.markNotificationReadUsecase,
    required this.getUnreadCountUsecase,
  }) : super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationDelete>(_onDelete);
    on<NotificationRefresh>(_onRefresh);
  }

  Future<void> _onLoadRequested(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      final notifications = await getNotificationsUsecase();
      final unreadCount = await getUnreadCountUsecase();
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      try {
        await markNotificationReadUsecase(event.notificationId);
        final notifications = await getNotificationsUsecase();
        final unreadCount = await getUnreadCountUsecase();
        emit(NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      try {
        final notifications = await getNotificationsUsecase();
        for (final notification in notifications) {
          if (!notification.isRead) {
            await markNotificationReadUsecase(notification.id);
          }
        }
        final updatedNotifications = await getNotificationsUsecase();
        final unreadCount = await getUnreadCountUsecase();
        emit(NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onDelete(
    NotificationDelete event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      try {
        // Delete will be handled by repository
        final notifications = await getNotificationsUsecase();
        final unreadCount = await getUnreadCountUsecase();
        emit(NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onRefresh(
    NotificationRefresh event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notifications = await getNotificationsUsecase();
      final unreadCount = await getUnreadCountUsecase();
      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/get_notification_by_id_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/get_unread_count_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// Notification BloC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUsecase getNotificationsUsecase;
  final GetNotificationByIdUsecase getNotificationByIdUsecase;
  final MarkNotificationReadUsecase markNotificationReadUsecase;
  final GetUnreadCountUsecase getUnreadCountUsecase;

  NotificationBloc({
    required this.getNotificationsUsecase,
    required this.getNotificationByIdUsecase,
    required this.markNotificationReadUsecase,
    required this.getUnreadCountUsecase,
  }) : super(const NotificationInitial()) {
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationLoadDetailRequested>(_onLoadDetailRequested);
    on<NotificationClearDetail>(_onClearDetail);
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

  Future<void> _onLoadDetailRequested(
    NotificationLoadDetailRequested event,
    Emitter<NotificationState> emit,
  ) async {
    // Keep the current NotificationLoaded state and just add the detail
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      try {
        final notification = await getNotificationByIdUsecase(event.notificationId);
        // Always emit new state even if notification is the same
        // This ensures listener is triggered every time
        emit(NotificationLoaded(
          notifications: current.notifications,
          unreadCount: current.unreadCount,
          viewingDetail: notification,
        ));
      } catch (e) {
        // On error, keep current state
        emit(NotificationError(e.toString()));
      }
    } else {
      // If not in NotificationLoaded state, try to load detail anyway
      try {
        final notification = await getNotificationByIdUsecase(event.notificationId);
        emit(NotificationDetailLoaded(notification: notification));
      } catch (e) {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _onClearDetail(
    NotificationClearDetail event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      emit(current.copyWith(viewingDetail: null));
    }
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      try {
        await markNotificationReadUsecase(event.notificationId);
        final updatedNotifications = current.notifications
            .map(
              (n) => n.id == event.notificationId
                  ? n.copyWith(isRead: true)
                  : n,
            )
            .toList();
        final unreadCount =
            updatedNotifications.where((n) => !n.isRead).length;
        emit(current.copyWith(
          notifications: updatedNotifications,
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
      final current = state as NotificationLoaded;
      try {
        for (final notification in current.notifications) {
          if (!notification.isRead) {
            await markNotificationReadUsecase(notification.id);
          }
        }
        final updatedNotifications =
            current.notifications.map((n) => n.copyWith(isRead: true)).toList();
        emit(current.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
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
      final current = state as NotificationLoaded;
      try {
        final updatedNotifications =
            current.notifications.where((n) => n.id != event.notificationId).toList();
        final unreadCount =
            updatedNotifications.where((n) => !n.isRead).length;
        emit(current.copyWith(
          notifications: updatedNotifications,
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

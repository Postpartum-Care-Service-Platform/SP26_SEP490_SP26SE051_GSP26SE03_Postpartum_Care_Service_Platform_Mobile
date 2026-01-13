import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../screens/notification_screen.dart';
import 'notification_detail_drawer.dart';
import 'notification_empty_state.dart';
import 'notification_item.dart';
import '../../domain/entities/notification_entity.dart';

/// Notification list widget with pull-to-refresh
class NotificationList extends StatelessWidget {
  final List<NotificationEntity> notifications;
  final NotificationFilter currentFilter;

  const NotificationList({
    super.key,
    required this.notifications,
    required this.currentFilter,
  });

  List<NotificationEntity> _getFilteredNotifications() {
    switch (currentFilter) {
      case NotificationFilter.unread:
        return notifications.where((n) => !n.isRead).toList();
      case NotificationFilter.read:
        return notifications.where((n) => n.isRead).toList();
      case NotificationFilter.all:
        return notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final bloc = context.read<NotificationBloc>();
    final filteredNotifications = _getFilteredNotifications();

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(const NotificationRefresh());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      strokeWidth: 3,
      child: filteredNotifications.isEmpty
          ? NotificationEmptyState(currentFilter: currentFilter)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                20 * scale,
                16 * scale,
                20 * scale,
                24 * scale,
              ),
              itemCount: filteredNotifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 12 * scale),
              itemBuilder: (context, index) {
                final notification = filteredNotifications[index];
                return NotificationItem(
                  notification: notification,
                  onTap: () {
                    // Mark as read if unread
                    if (!notification.isRead) {
                      bloc.add(NotificationMarkAsRead(notification.id));
                    }
                    // Directly open drawer with the notification
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (sheetContext) => NotificationDetailDrawer(
                        notification: notification,
                      ),
                    ).then((_) {
                      // Refresh notifications when drawer closes
                      if (context.mounted) {
                        bloc.add(const NotificationRefresh());
                      }
                    });
                  },
                );
              },
            ),
    );
  }
}

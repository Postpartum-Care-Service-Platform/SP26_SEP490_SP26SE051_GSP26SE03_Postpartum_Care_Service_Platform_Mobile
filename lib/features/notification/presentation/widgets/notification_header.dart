import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../screens/notification_screen.dart';
import 'notification_filter_tabs.dart';
import 'notification_unread_badge.dart';

/// Notification header widget with filter tabs and unread badge
class NotificationHeader extends StatelessWidget {
  final NotificationFilter currentFilter;
  final ValueChanged<NotificationFilter> onFilterChanged;
  final int unreadCount;

  const NotificationHeader({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      padding: EdgeInsets.fromLTRB(
        20 * scale,
        20 * scale,
        20 * scale,
        20 * scale,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter tabs
          NotificationFilterTabs(
            currentFilter: currentFilter,
            onFilterChanged: onFilterChanged,
            unreadCount: unreadCount,
          ),
          // Unread count badge (only show when filter is all)
          if (currentFilter == NotificationFilter.all && unreadCount > 0)
            NotificationUnreadBadge(unreadCount: unreadCount),
        ],
      ),
    );
  }
}

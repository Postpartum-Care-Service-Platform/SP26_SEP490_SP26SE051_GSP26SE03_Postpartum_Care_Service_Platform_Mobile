import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../screens/notification_screen.dart';

/// Notification empty state widget
class NotificationEmptyState extends StatelessWidget {
  final NotificationFilter currentFilter;

  const NotificationEmptyState({
    super.key,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final message = _getMessage();
    final icon = _getIcon();

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32 * scale,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120 * scale,
              height: 120 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32 * scale),
            Text(
              message,
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12 * scale),
            Text(
              'Bạn chưa có thông báo nào',
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getMessage() {
    switch (currentFilter) {
      case NotificationFilter.unread:
        return 'Không có thông báo chưa đọc';
      case NotificationFilter.read:
        return 'Không có thông báo đã đọc';
      case NotificationFilter.all:
        return AppStrings.noNotifications;
    }
  }

  IconData _getIcon() {
    switch (currentFilter) {
      case NotificationFilter.unread:
        return Icons.notifications_none_rounded;
      case NotificationFilter.read:
        return Icons.check_circle_outline_rounded;
      case NotificationFilter.all:
        return Icons.notifications_none_rounded;
    }
  }
}

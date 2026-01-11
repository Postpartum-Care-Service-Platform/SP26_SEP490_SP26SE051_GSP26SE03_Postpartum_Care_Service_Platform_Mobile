import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/notification_entity.dart';

/// Notification item widget
class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback? onTap;

  const NotificationItem({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.reminder:
        return Icons.notifications_active_rounded;
      case NotificationType.security:
        return Icons.security_rounded;
      case NotificationType.loan:
        return Icons.account_balance_wallet_rounded;
      case NotificationType.budget:
        return Icons.account_balance_rounded;
      case NotificationType.general:
        return Icons.info_rounded;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppStrings.justNow;
    } else if (difference.inMinutes < 60) {
      return AppStrings.minutesAgo.replaceAll('{minutes}', '${difference.inMinutes}');
    } else if (difference.inHours < 24) {
      return AppStrings.hoursAgo.replaceAll('{hours}', '${difference.inHours}');
    } else {
      return AppStrings.daysAgo.replaceAll('{days}', '${difference.inDays}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12 * scale),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with background
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48 * scale,
                  height: 48 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(notification.type),
                    size: 22 * scale,
                    color: AppColors.primary,
                  ),
                ),
                // Unread indicator
                if (!notification.isRead)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8 * scale,
                      height: 8 * scale,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 1.5 * scale,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 20 * scale),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    notification.category,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  // Title
                  Text(
                    notification.title,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8 * scale),
                  // Time ago
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/notification_entity.dart';

/// Modern notification item widget
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

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return const Color(0xFF4CAF50);
      case NotificationType.reminder:
        return const Color(0xFFFF9800);
      case NotificationType.security:
        return const Color(0xFFF44336);
      case NotificationType.loan:
        return const Color(0xFF2196F3);
      case NotificationType.budget:
        return const Color(0xFF9C27B0);
      case NotificationType.general:
        return AppColors.primary;
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
    } else if (difference.inDays < 7) {
      return AppStrings.daysAgo.replaceAll('{days}', '${difference.inDays}');
    } else {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}${DateTime.now().year != dateTime.year ? '/${dateTime.year}' : ''}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final typeColor = _getColorForType(notification.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18 * scale),
        child: Container(
          padding: EdgeInsets.all(18 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18 * scale),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.borderLight
                  : typeColor.withValues(alpha: 0.3),
              width: notification.isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: notification.isRead
                    ? Colors.black.withValues(alpha: 0.04)
                    : typeColor.withValues(alpha: 0.08),
                blurRadius: 12 * scale,
                offset: Offset(0, 4 * scale),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with colored background
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56 * scale,
                    height: 56 * scale,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForType(notification.type),
                      size: 26 * scale,
                      color: typeColor,
                    ),
                  ),
                  // Unread indicator
                  if (!notification.isRead)
                    Positioned(
                      right: -2 * scale,
                      top: -2 * scale,
                      child: Container(
                        width: 14 * scale,
                        height: 14 * scale,
                        decoration: BoxDecoration(
                          color: typeColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.white,
                            width: 2.5 * scale,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 16 * scale),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.w700,
                        color: AppColors.textPrimary,
                      ).copyWith(
                        letterSpacing: -0.3,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (notification.description != null &&
                        notification.description!.isNotEmpty) ...[
                      SizedBox(height: 8 * scale),
                      // Description
                      Text(
                        notification.description!,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.normal,
                          color: AppColors.textSecondary,
                        ).copyWith(height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 10 * scale),
                    // Time ago with icon
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13 * scale,
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: 6 * scale),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.normal,
                            color: AppColors.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Arrow indicator
              SizedBox(width: 8 * scale),
              Icon(
                Icons.chevron_right_rounded,
                size: 20 * scale,
                color: AppColors.textSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

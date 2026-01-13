import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../../domain/entities/notification_entity.dart';

/// Modern notification detail drawer widget
class NotificationDetailDrawer extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationDetailDrawer({
    super.key,
    required this.notification,
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

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'vi');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final typeColor = _getColorForType(notification.type);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: AppDrawerForm(
        title: AppStrings.notificationDetail,
        saveButtonText: null,
        onSave: null,
        children: [
          // Header with icon and title
          Container(
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: typeColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56 * scale,
                  height: 56 * scale,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForType(notification.type),
                    size: 28 * scale,
                    color: typeColor,
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Text(
                        notification.title,
                        style: AppTextStyles.arimo(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(height: 24 * scale),

          // Content section
          if (notification.description != null &&
              notification.description!.isNotEmpty) ...[
            Row(
              children: [
                Icon(
                  Icons.description_rounded,
                  size: 18 * scale,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 8 * scale),
            Text(
              AppStrings.notificationContent,
              style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(18 * scale),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14 * scale),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
              ),
              child: Text(
                notification.description!,
                style: AppTextStyles.arimo(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textPrimary,
                ).copyWith(height: 1.6),
              ),
            ),
            SizedBox(height: 24 * scale),
          ],

          // Info section
          Container(
            padding: EdgeInsets.all(18 * scale),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Column(
            children: [
                // Status
                _buildInfoRow(
                  scale,
                  Icons.circle,
                  AppStrings.notificationStatus,
                  notification.isRead
                      ? AppStrings.notificationStatusRead
                      : AppStrings.notificationStatusUnread,
                  notification.isRead
                      ? const Color(0xFF4CAF50)
                      : AppColors.primary,
                ),
                SizedBox(height: 16 * scale),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderLight,
          ),
          SizedBox(height: 16 * scale),
                // Created at
                _buildInfoRow(
            scale,
                  Icons.access_time_rounded,
            AppStrings.notificationCreatedAt,
            _formatDateTime(notification.createdAt),
            AppColors.textSecondary,
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    double scale,
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36 * scale,
          height: 36 * scale,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Icon(
          icon,
          size: 18 * scale,
          color: iconColor,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                value,
                style: AppTextStyles.arimo(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

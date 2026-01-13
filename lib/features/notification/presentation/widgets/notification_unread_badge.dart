import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Notification unread count badge widget
class NotificationUnreadBadge extends StatelessWidget {
  final int unreadCount;

  const NotificationUnreadBadge({
    super.key,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8 * scale,
            height: 8 * scale,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            '$unreadCount ${unreadCount == 1 ? 'thông báo chưa đọc' : 'thông báo chưa đọc'}',
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

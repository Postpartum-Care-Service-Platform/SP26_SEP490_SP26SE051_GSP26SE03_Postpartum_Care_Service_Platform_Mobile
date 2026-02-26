import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Notification unread count badge widget
class NotificationUnreadBadge extends StatelessWidget {
  final int unreadCount;
  final VoidCallback? onTap;

  const NotificationUnreadBadge({
    super.key,
    required this.unreadCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final summary = AppStrings.notificationUnreadSummary
        .replaceAll('{count}', '$unreadCount');

    return Padding(
      padding: EdgeInsets.only(top: 12 * scale),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16 * scale),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(14 * scale),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.20),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36 * scale,
                  height: 36 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_unread_rounded,
                    size: 18 * scale,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Text(
                    summary,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    AppStrings.notificationUnreadCta,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

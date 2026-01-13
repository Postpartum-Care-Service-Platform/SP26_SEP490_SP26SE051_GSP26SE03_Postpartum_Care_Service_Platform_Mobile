import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Notification list empty state widget (when no notifications at all)
class NotificationListEmptyState extends StatelessWidget {
  const NotificationListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 32 * AppResponsive.scaleFactor(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120 * AppResponsive.scaleFactor(context),
              height: 120 * AppResponsive.scaleFactor(context),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 64 * AppResponsive.scaleFactor(context),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 32 * AppResponsive.scaleFactor(context)),
            Text(
              AppStrings.noNotifications,
              style: AppTextStyles.tinos(
                fontSize: 22 * AppResponsive.scaleFactor(context),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12 * AppResponsive.scaleFactor(context)),
            Text(
              'Bạn chưa có thông báo nào',
              style: AppTextStyles.arimo(
                fontSize: 15 * AppResponsive.scaleFactor(context),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

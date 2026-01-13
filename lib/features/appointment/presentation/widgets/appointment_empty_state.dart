import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Empty state widget when no appointments are found
class AppointmentEmptyState extends StatelessWidget {
  const AppointmentEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(40 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 64 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              AppStrings.noAppointments,
              style: AppTextStyles.arimo(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Tạo lịch hẹn đầu tiên của bạn',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';

/// Notification error state widget
class NotificationErrorState extends StatelessWidget {
  final String message;

  const NotificationErrorState({
    super.key,
    required this.message,
  });

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
              width: 100 * AppResponsive.scaleFactor(context),
              height: 100 * AppResponsive.scaleFactor(context),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 56 * AppResponsive.scaleFactor(context),
                color: AppColors.red,
              ),
            ),
            SizedBox(height: 24 * AppResponsive.scaleFactor(context)),
            Text(
              'Đã xảy ra lỗi',
              style: AppTextStyles.tinos(
                fontSize: 22 * AppResponsive.scaleFactor(context),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12 * AppResponsive.scaleFactor(context)),
            Text(
              message,
              style: AppTextStyles.arimo(
                fontSize: 15 * AppResponsive.scaleFactor(context),
                color: AppColors.textSecondary,
              ).copyWith(height: 1.5),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32 * AppResponsive.scaleFactor(context)),
            ElevatedButton.icon(
              onPressed: () {
                context.read<NotificationBloc>().add(
                      const NotificationLoadRequested(),
                    );
              },
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(AppStrings.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 32 * AppResponsive.scaleFactor(context),
                  vertical: 16 * AppResponsive.scaleFactor(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    16 * AppResponsive.scaleFactor(context),
                  ),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

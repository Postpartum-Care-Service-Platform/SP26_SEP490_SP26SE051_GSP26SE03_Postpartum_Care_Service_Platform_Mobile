import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';

/// Notification loading state widget
class NotificationLoadingState extends StatelessWidget {
  const NotificationLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppLoadingIndicator(
            size: 56 * AppResponsive.scaleFactor(context),
            color: AppColors.primary,
          ),
          SizedBox(height: 24 * AppResponsive.scaleFactor(context)),
          Text(
            AppStrings.loading,
            style: AppTextStyles.arimo(
              fontSize: 16 * AppResponsive.scaleFactor(context),
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

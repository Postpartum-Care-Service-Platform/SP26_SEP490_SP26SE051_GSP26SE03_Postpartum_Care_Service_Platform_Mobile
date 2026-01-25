import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

class PaymentStatusIndicator extends StatelessWidget {
  const PaymentStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.12),
            AppColors.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18 * scale,
            height: 18 * scale,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(width: 12 * scale),
          Flexible(
            child: Text(
              AppStrings.paymentChecking,
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ).copyWith(letterSpacing: 0.3),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

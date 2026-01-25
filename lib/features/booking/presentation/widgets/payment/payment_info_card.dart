import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../domain/entities/payment_link_entity.dart';

class PaymentInfoCard extends StatelessWidget {
  final PaymentLinkEntity paymentLink;
  final String Function(double) formatPrice;

  const PaymentInfoCard({
    super.key,
    required this.paymentLink,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16 * scale,
            offset: Offset(0, 3 * scale),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 20 * scale,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  AppStrings.paymentDeposit,
                  style: AppTextStyles.tinos(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.paymentAmount,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    formatPrice(paymentLink.amount),
                    style: AppTextStyles.tinos(
                      fontSize: 26 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(6 * scale),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  size: 20 * scale,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Row(
            children: [
              Icon(
                Icons.payment_rounded,
                size: 18 * scale,
                color: AppColors.primary,
              ),
              SizedBox(width: 8 * scale),
              Text(
                AppStrings.paymentMethod,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                AppStrings.paymentPayOS,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

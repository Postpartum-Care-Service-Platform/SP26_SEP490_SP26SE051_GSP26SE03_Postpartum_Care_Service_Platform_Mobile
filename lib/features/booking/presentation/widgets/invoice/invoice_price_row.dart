import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

class InvoicePriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final String Function(double) formatPrice;
  final bool isTotal;
  final bool isPaid;
  final bool isRemaining;

  const InvoicePriceRow({
    super.key,
    required this.label,
    required this.amount,
    required this.formatPrice,
    this.isTotal = false,
    this.isPaid = false,
    this.isRemaining = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    Color amountColor = AppColors.textPrimary;
    if (isTotal) {
      amountColor = AppColors.primary;
    } else if (isPaid) {
      amountColor = AppColors.verified;
    } else if (isRemaining) {
      amountColor = AppColors.primary;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: isTotal ? 16 * scale : 14 * scale,
            fontWeight: isTotal || isPaid || isRemaining
                ? FontWeight.w600
                : FontWeight.normal,
            color: isTotal || isPaid || isRemaining
                ? AppColors.textPrimary
                : AppColors.textSecondary,
          ),
        ),
        Text(
          formatPrice(amount),
          style: AppTextStyles.arimo(
            fontSize: isTotal ? 20 * scale : isPaid || isRemaining ? 16 * scale : 14 * scale,
            fontWeight: FontWeight.bold,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

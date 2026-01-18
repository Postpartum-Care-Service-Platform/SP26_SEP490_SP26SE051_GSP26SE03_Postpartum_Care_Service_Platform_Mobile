import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import 'invoice_price_row.dart';

class PriceDetailsCard extends StatelessWidget {
  final double totalPrice;
  final double discountAmount;
  final double finalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String Function(double) formatPrice;

  const PriceDetailsCard({
    super.key,
    required this.totalPrice,
    required this.discountAmount,
    required this.finalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.invoicePriceDetails,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ).copyWith(letterSpacing: 0.8),
          ),
          SizedBox(height: 20 * scale),
          InvoicePriceRow(
            label: AppStrings.invoiceTotalPrice,
            amount: totalPrice,
            formatPrice: formatPrice,
          ),
          SizedBox(height: 12 * scale),
          InvoicePriceRow(
            label: AppStrings.invoiceDiscount,
            amount: discountAmount,
            formatPrice: formatPrice,
          ),
          SizedBox(height: 16 * scale),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.borderLight,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SizedBox(height: 16 * scale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 12 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.invoiceFinalAmount,
                  style: AppTextStyles.arimo(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  formatPrice(finalAmount),
                  style: AppTextStyles.tinos(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20 * scale),
          Container(
            padding: EdgeInsets.all(16 * scale),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                InvoicePriceRow(
                  label: AppStrings.invoicePaidAmount,
                  amount: paidAmount,
                  formatPrice: formatPrice,
                  isPaid: true,
                ),
                SizedBox(height: 12 * scale),
                Divider(height: 1, color: AppColors.borderLight),
                SizedBox(height: 12 * scale),
                InvoicePriceRow(
                  label: AppStrings.invoiceRemainingAmount,
                  amount: remainingAmount,
                  formatPrice: formatPrice,
                  isRemaining: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

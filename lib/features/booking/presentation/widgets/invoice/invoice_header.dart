import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

class InvoiceHeader extends StatelessWidget {
  final int bookingId;
  final String status;
  final DateTime createdAt;
  final String Function(String) getStatusLabel;
  final String Function(DateTime) formatDateTime;

  const InvoiceHeader({
    super.key,
    required this.bookingId,
    required this.status,
    required this.createdAt,
    required this.getStatusLabel,
    required this.formatDateTime,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.invoiceCode,
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        color: AppColors.textSecondary,
                      ).copyWith(letterSpacing: 0.5),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      '#$bookingId',
                      style: AppTextStyles.tinos(
                        fontSize: 28 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ).copyWith(height: 1.2),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14 * scale,
                  vertical: 8 * scale,
                ),
                decoration: BoxDecoration(
                  color: status == 'Confirmed'
                      ? AppColors.verified.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: status == 'Confirmed'
                        ? AppColors.verified.withValues(alpha: 0.3)
                        : AppColors.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  getStatusLabel(status),
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                    color: status == 'Confirmed'
                        ? AppColors.verified
                        : AppColors.primary,
                  ).copyWith(letterSpacing: 0.3),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
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
          SizedBox(height: 20 * scale),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16 * scale,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 8 * scale),
              Text(
                AppStrings.invoiceDate,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  formatDateTime(createdAt),
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

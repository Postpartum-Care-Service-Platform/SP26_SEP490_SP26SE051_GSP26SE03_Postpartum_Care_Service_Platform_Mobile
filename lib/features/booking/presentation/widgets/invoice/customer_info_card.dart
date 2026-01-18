import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../domain/entities/customer_entity.dart';
import 'invoice_info_row.dart';

class CustomerInfoCard extends StatelessWidget {
  final CustomerEntity customer;

  const CustomerInfoCard({
    super.key,
    required this.customer,
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
            AppStrings.invoiceCustomer,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ).copyWith(letterSpacing: 0.8),
          ),
          SizedBox(height: 16 * scale),
          Text(
            customer.username,
            style: AppTextStyles.tinos(
              fontSize: 20 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ).copyWith(height: 1.3),
          ),
          SizedBox(height: 16 * scale),
          InvoiceInfoRow(
            icon: Icons.email_rounded,
            label: AppStrings.invoiceEmail,
            value: customer.email,
          ),
          SizedBox(height: 12 * scale),
          InvoiceInfoRow(
            icon: Icons.phone_rounded,
            label: AppStrings.invoicePhone,
            value: customer.phone,
          ),
        ],
      ),
    );
  }
}

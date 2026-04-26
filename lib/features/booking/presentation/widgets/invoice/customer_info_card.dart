import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../domain/entities/customer_entity.dart';
import '../../../domain/entities/target_booking_entity.dart';
import 'invoice_info_row.dart';

class CustomerInfoCard extends StatelessWidget {
  final CustomerEntity customer;
  final List<TargetBookingEntity> targetBookings;

  const CustomerInfoCard({
    super.key,
    required this.customer,
    this.targetBookings = const [],
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
          if (targetBookings.isNotEmpty) ...[
            SizedBox(height: 16 * scale),
            Text(
              'Đối tượng được phục vụ',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 10 * scale),
            ...targetBookings.map(
              (target) => Padding(
                padding: EdgeInsets.only(bottom: 8 * scale),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 10 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10 * scale),
                    border: Border.all(
                      color: AppColors.borderLight,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18 * scale,
                        backgroundColor: AppColors.borderLight,
                        backgroundImage: (target.avatarUrl != null &&
                                target.avatarUrl!.isNotEmpty)
                            ? NetworkImage(target.avatarUrl!)
                            : null,
                        child: (target.avatarUrl == null ||
                                target.avatarUrl!.isEmpty)
                            ? Icon(
                                target.memberTypeId == 3
                                    ? Icons.child_care_rounded
                                    : Icons.pregnant_woman_rounded,
                                size: 18 * scale,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text(
                          target.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if ((target.relationship ?? '').trim().isNotEmpty)
                        Text(
                          target.relationship!,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../domain/entities/package_info_entity.dart';
import '../../../domain/entities/room_info_entity.dart';
import 'invoice_info_row.dart';

class BookingDetailsCard extends StatelessWidget {
  final PackageInfoEntity? package;
  final RoomInfoEntity? room;
  final DateTime startDate;
  final DateTime endDate;
  final String Function(DateTime) formatDate;

  const BookingDetailsCard({
    super.key,
    required this.package,
    required this.room,
    required this.startDate,
    required this.endDate,
    required this.formatDate,
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
            AppStrings.invoiceBookingDetails,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ).copyWith(letterSpacing: 0.8),
          ),
          SizedBox(height: 18 * scale),
          Row(
            children: [
              if (package != null)
                Expanded(
                  child: InvoiceInfoRow(
                    icon: Icons.card_giftcard_rounded,
                    label: AppStrings.invoicePackage,
                    value: package!.packageName,
                  ),
                ),
              if (package != null && room != null)
                SizedBox(width: 16 * scale),
              if (room != null)
                Expanded(
                  child: InvoiceInfoRow(
                    icon: Icons.hotel_rounded,
                    label: AppStrings.invoiceRoom,
                    value: 'Phòng ${room!.name}',
                  ),
                ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Row(
            children: [
              Expanded(
                child: InvoiceInfoRow(
                  icon: Icons.login_rounded,
                  label: AppStrings.invoiceCheckIn,
                  value: formatDate(startDate),
                ),
              ),
              SizedBox(width: 16 * scale),
              Expanded(
                child: InvoiceInfoRow(
                  icon: Icons.logout_rounded,
                  label: AppStrings.invoiceCheckOut,
                  value: formatDate(endDate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

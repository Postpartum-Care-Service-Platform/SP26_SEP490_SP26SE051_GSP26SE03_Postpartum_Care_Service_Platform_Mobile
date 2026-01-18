import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../domain/entities/booking_entity.dart';

class BookingCard extends StatelessWidget {
  final BookingEntity booking;
  final String Function(double) formatPrice;
  final String Function(DateTime) formatDate;
  final String Function(String) getStatusLabel;
  final Color Function(String) getStatusColor;
  final VoidCallback onTap;

  const BookingCard({
    super.key,
    required this.booking,
    required this.formatPrice,
    required this.formatDate,
    required this.getStatusLabel,
    required this.getStatusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * scale),
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8 * scale,
              offset: Offset(0, 2 * scale),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookingCardHeader(
              bookingId: booking.id,
              status: booking.status,
              getStatusLabel: getStatusLabel,
              getStatusColor: getStatusColor,
            ),
            SizedBox(height: 14 * scale),
            if (booking.package != null)
              _BookingInfoRow(
                icon: Icons.bed_rounded,
                text: booking.package!.packageName,
                isBold: true,
              ),
            if (booking.package != null) SizedBox(height: 10 * scale),
            if (booking.room != null)
              _BookingInfoRow(
                icon: Icons.business_rounded,
                text: 'Phòng ${booking.room!.name}${booking.room!.floor != null ? ' - Tầng ${booking.room!.floor}' : ''}',
              ),
            SizedBox(height: 10 * scale),
            _BookingInfoRow(
              icon: Icons.calendar_today_rounded,
              text: '${formatDate(booking.startDate)} - ${formatDate(booking.endDate)}',
            ),
            SizedBox(height: 14 * scale),
            Divider(height: 1, color: AppColors.borderLight),
            SizedBox(height: 14 * scale),
            _BookingPriceSection(
              finalAmount: booking.finalAmount,
              paidAmount: booking.paidAmount,
              remainingAmount: booking.remainingAmount,
              formatPrice: formatPrice,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCardHeader extends StatelessWidget {
  final int bookingId;
  final String status;
  final String Function(String) getStatusLabel;
  final Color Function(String) getStatusColor;

  const _BookingCardHeader({
    required this.bookingId,
    required this.status,
    required this.getStatusLabel,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mã đặt phòng',
              style: AppTextStyles.arimo(
                fontSize: 10 * scale,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 3 * scale),
            Text(
              '#$bookingId',
              style: AppTextStyles.tinos(
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 6 * scale,
          ),
          decoration: BoxDecoration(
            color: getStatusColor(status).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Text(
            getStatusLabel(status),
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w600,
              color: getStatusColor(status),
            ),
          ),
        ),
      ],
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isBold;

  const _BookingInfoRow({
    required this.icon,
    required this.text,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16 * scale,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 6 * scale),
        Expanded(
          child: Text(
            text,
            style: isBold
                ? AppTextStyles.tinos(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  )
                : AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BookingPriceSection extends StatelessWidget {
  final double finalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String Function(double) formatPrice;

  const _BookingPriceSection({
    required this.finalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
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
                    'Thành tiền',
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    formatPrice(finalAmount),
                    style: AppTextStyles.tinos(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Đã thanh toán',
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    formatPrice(paidAmount),
                    style: AppTextStyles.tinos(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.verified,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (remainingAmount > 0) ...[
          SizedBox(height: 12 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Còn lại',
                style: AppTextStyles.arimo(
                  fontSize: 11 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                formatPrice(remainingAmount),
                style: AppTextStyles.tinos(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

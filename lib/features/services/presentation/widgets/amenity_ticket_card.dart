import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_date_time_utils.dart';
import '../../domain/entities/amenity_ticket_entity.dart';

/// Amenity Ticket Card Widget
class AmenityTicketCard extends StatelessWidget {
  final AmenityTicketEntity ticket;

  const AmenityTicketCard({
    super.key,
    required this.ticket,
  });

  String _getStatusText() {
    switch (ticket.status.toLowerCase()) {
      case 'booked':
        return AppStrings.amenityStatusBooked;
      case 'accepted':
        return AppStrings.amenityStatusAccepted;
      case 'completed':
        return AppStrings.amenityStatusCompleted;
      case 'cancelled':
        return AppStrings.amenityStatusCancelled;
      default:
        return ticket.status;
    }
  }

  Color _getStatusColor() {
    switch (ticket.status.toLowerCase()) {
      case 'booked':
        return AppColors.appointmentPending;
      case 'accepted':
        return AppColors.appointmentScheduled;
      case 'completed':
        return AppColors.appointmentCompleted;
      case 'cancelled':
        return AppColors.appointmentCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    return AppDateTimeUtils.formatVietnamDateTime(date).split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(ticket.startTime),
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      ticket.timeRange,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(
                    color: _getStatusColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusText(),
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/appointment_entity.dart';

/// Appointment status badge widget - Redesigned based on Figma template
class AppointmentStatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const AppointmentStatusBadge({
    super.key,
    required this.status,
  });

  Color _getBackgroundColor() {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppColors.appointmentScheduled.withValues(alpha: 0.15);
      case AppointmentStatus.rescheduled:
        return AppColors.appointmentRescheduled.withValues(alpha: 0.15);
      case AppointmentStatus.completed:
        return AppColors.appointmentCompleted.withValues(alpha: 0.15);
      case AppointmentStatus.pending:
        return AppColors.appointmentPending.withValues(alpha: 0.15);
      case AppointmentStatus.cancelled:
        return AppColors.appointmentCancelled.withValues(alpha: 0.15);
    }
  }

  Color _getTextColor() {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppColors.appointmentScheduled;
      case AppointmentStatus.rescheduled:
        return AppColors.appointmentRescheduled;
      case AppointmentStatus.completed:
        return AppColors.appointmentCompleted;
      case AppointmentStatus.pending:
        return AppColors.appointmentPending;
      case AppointmentStatus.cancelled:
        return AppColors.appointmentCancelled;
    }
  }

  String _getStatusText() {
    switch (status) {
      case AppointmentStatus.scheduled:
        return AppStrings.statusScheduled;
      case AppointmentStatus.rescheduled:
        return AppStrings.statusRescheduled;
      case AppointmentStatus.completed:
        return AppStrings.statusCompleted;
      case AppointmentStatus.pending:
        return AppStrings.statusPending;
      case AppointmentStatus.cancelled:
        return AppStrings.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: _getTextColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(),
        style: AppTextStyles.arimo(
          fontSize: 12 * scale,
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        ),
      ),
    );
  }
}

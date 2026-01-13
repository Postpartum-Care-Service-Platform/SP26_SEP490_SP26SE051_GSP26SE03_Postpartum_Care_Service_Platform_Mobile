import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/appointment_entity.dart';
import 'appointment_status_badge.dart';

/// Appointment card widget - Redesigned based on Figma template
class AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onOpenMap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onEdit,
    this.onCancel,
    this.onOpenMap,
  });

  Color _getStatusColor() {
    switch (appointment.status) {
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

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _canEdit() {
    return appointment.status != AppointmentStatus.completed &&
        appointment.status != AppointmentStatus.cancelled;
  }

  bool _canCancel() {
    return appointment.status != AppointmentStatus.completed &&
        appointment.status != AppointmentStatus.cancelled;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _getStatusColor();

    return Container(
      margin: EdgeInsets.only(top: 6, bottom: 16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.16),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.08),
            blurRadius: 16 * scale,
            offset: Offset(0, 4 * scale),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10 * scale,
            offset: Offset(0, 3 * scale),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24 * scale),
        child: InkWell(
          borderRadius: BorderRadius.circular(24 * scale),
          onTap: onOpenMap,
          child: Padding(
            padding: EdgeInsets.all(20 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with title and menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        appointment.name,
                        style: AppTextStyles.arimo(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (_canEdit() || _canCancel())
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: AppColors.textSecondary,
                          size: 20 * scale,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        itemBuilder: (context) => [
                          if (_canEdit())
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 18 * scale,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Text(
                                    AppStrings.edit,
                                    style: AppTextStyles.arimo(
                                      fontSize: 14 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_canCancel())
                            PopupMenuItem<String>(
                              value: 'cancel',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.cancel_outlined,
                                    size: 18 * scale,
                                    color: AppColors.appointmentCancelled,
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Text(
                                    AppStrings.cancelAppointment,
                                    style: AppTextStyles.arimo(
                                      fontSize: 14 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.appointmentCancelled,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit' && onEdit != null) {
                            onEdit!();
                          } else if (value == 'cancel' && onCancel != null) {
                            onCancel!();
                          }
                        },
                      ),
                  ],
                ),
                SizedBox(height: 8 * scale),

                // Appointment type (if available)
                if (appointment.appointmentType != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 18 * scale,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text(
                          appointment.appointmentType!.name,
                          style: AppTextStyles.arimo(
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10 * scale),
                ],

                // Ngày hẹn

                Row(
                  children: [
                    _IconBadge(icon: Icons.event_available, scale: scale),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appointmentDate,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            _formatDate(appointment.appointmentDate),
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),

                // Thời gian
                Row(
                  children: [
                    _IconBadge(icon: Icons.schedule, scale: scale),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appointmentTime,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            _formatTime(appointment.appointmentDate),
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),

                // Địa điểm
                InkWell(
                  borderRadius: BorderRadius.circular(12 * scale),
                  onTap: onOpenMap,
                  child: Row(
                    children: [
                      _IconBadge(icon: Icons.place, scale: scale),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appointmentLocation,
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              AppStrings.appointmentLocationName,
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20 * scale,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * scale),

                // Nhân viên tiếp quản (nếu có)
                if (appointment.staff != null) ...[
                  Row(
                    children: [
                      _IconBadge(icon: Icons.person_outline, scale: scale),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhân viên tiếp quản',
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              appointment.staff!.username,
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                ],

                // Trạng thái
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AppointmentStatusBadge(status: appointment.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small icon badge used in appointment card rows
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final double scale;

  const _IconBadge({required this.icon, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12 * scale),
      ),
      child: Icon(icon, size: 16 * scale, color: AppColors.textSecondary),
    );
  }
}

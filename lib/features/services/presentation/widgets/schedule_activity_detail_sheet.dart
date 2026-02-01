import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_date_time_utils.dart';
import '../../domain/entities/family_schedule_entity.dart';
import '../../domain/entities/staff_schedule_entity.dart';

/// Schedule Activity Detail Bottom Sheet
/// Displays staff information and notes when long pressing an activity
class ScheduleActivityDetailSheet extends StatelessWidget {
  final FamilyScheduleEntity schedule;

  const ScheduleActivityDetailSheet({
    super.key,
    required this.schedule,
  });

  static void show(BuildContext context, FamilyScheduleEntity schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScheduleActivityDetailSheet(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12 * scale),
                width: 40 * scale,
                height: 4 * scale,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2 * scale),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                schedule.activity,
                                style: AppTextStyles.tinos(
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10 * scale,
                                  vertical: 4 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6 * scale),
                                ),
                                child: Text(
                                  schedule.timeRange,
                                  style: AppTextStyles.arimo(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 24 * scale,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  children: [
                    // Staff Section
                    if (schedule.hasStaff) ...[
                      _buildSectionHeader(
                        AppStrings.scheduleStaffAssigned,
                        Icons.people_outline,
                        scale,
                      ),
                      SizedBox(height: 12 * scale),
                      ...schedule.staffSchedules.map((staff) => _buildStaffCard(staff, scale)),
                      SizedBox(height: 24 * scale),
                    ] else ...[
                      _buildEmptyState(
                        AppStrings.scheduleNoStaffAssigned,
                        Icons.people_outline,
                        scale,
                      ),
                      SizedBox(height: 24 * scale),
                    ],
                    // Note Section
                    if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                      _buildSectionHeader(
                        AppStrings.scheduleNote,
                        Icons.note_outlined,
                        scale,
                      ),
                      SizedBox(height: 12 * scale),
                      _buildNoteCard(schedule.note!, scale),
                      SizedBox(height: 24 * scale),
                    ],
                    // Activity Note Section (if exists)
                    if (schedule.note == null || schedule.note!.isEmpty) ...[
                      _buildEmptyState(
                        AppStrings.scheduleNoNote,
                        Icons.note_outlined,
                        scale,
                      ),
                      SizedBox(height: 24 * scale),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, double scale) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20 * scale,
          color: AppColors.primary,
        ),
        SizedBox(width: 8 * scale),
        Text(
          title,
          style: AppTextStyles.tinos(
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStaffCard(StaffScheduleEntity staff, double scale) {
    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: staff.isChecked
              ? AppColors.verified.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status indicator
              Container(
                width: 12 * scale,
                height: 12 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: staff.isChecked ? AppColors.verified : AppColors.textSecondary,
                ),
                child: staff.isChecked
                    ? Icon(
                        Icons.check,
                        size: 8 * scale,
                        color: AppColors.white,
                      )
                    : null,
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      staff.staffName ?? AppStrings.scheduleStaff,
                      style: AppTextStyles.arimo(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (staff.staffName == null) ...[
                      SizedBox(height: 2 * scale),
                      Text(
                        'ID: ${staff.staffId.substring(0, 8)}...',
                        style: AppTextStyles.arimo(
                          fontSize: 12 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Check status badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: staff.isChecked
                      ? AppColors.verified.withValues(alpha: 0.15)
                      : AppColors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6 * scale),
                ),
                child: Text(
                  staff.isChecked ? AppStrings.scheduleCompleted : AppStrings.scheduleNotCompleted,
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: staff.isChecked ? AppColors.verified : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (staff.managerName != null) ...[
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Icon(
                  Icons.supervisor_account_outlined,
                  size: 16 * scale,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '${AppStrings.scheduleManager}: ${staff.managerName}',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          if (staff.checkedAt != null) ...[
            SizedBox(height: 8 * scale),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '${AppStrings.scheduleCompletedAt}: ${_formatDateTime(staff.checkedAt!)}',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoteCard(String note, double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.note_outlined,
            size: 20 * scale,
            color: AppColors.primary,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              note,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textPrimary,
              ).copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32 * scale),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48 * scale,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12 * scale),
          Text(
            message,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return AppDateTimeUtils.formatVietnamDateTime(dateTime);
  }
}

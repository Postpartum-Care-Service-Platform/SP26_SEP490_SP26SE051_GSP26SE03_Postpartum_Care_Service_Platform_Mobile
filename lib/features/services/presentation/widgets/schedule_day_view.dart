import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/family_schedule_entity.dart';
import 'schedule_activity_item.dart';

/// Schedule Day View Widget
/// Displays all activities for a selected day in timeline format
class ScheduleDayView extends StatelessWidget {
  final DateTime date;
  final List<FamilyScheduleEntity> schedules;
  final int dayNo;

  const ScheduleDayView({
    super.key,
    required this.date,
    required this.schedules,
    required this.dayNo,
  });

  /// Sort schedules by start time
  List<FamilyScheduleEntity> _getSortedSchedules() {
    final sorted = List<FamilyScheduleEntity>.from(schedules);
    sorted.sort((a, b) {
      return a.startTime.compareTo(b.startTime);
    });
    return sorted;
  }

  /// Get completion statistics
  Map<String, int> _getStats() {
    final total = schedules.length;
    final completed = schedules.where((s) => s.isCompleted).length; // Done status
    final pending = schedules.where((s) => s.status.toLowerCase() == 'scheduled').length;
    return {
      'total': total,
      'completed': completed,
      'pending': pending,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final sortedSchedules = _getSortedSchedules();
    final stats = _getStats();

    if (sortedSchedules.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 8 * scale),
        padding: EdgeInsets.symmetric(
          horizontal: 48 * scale,
          vertical: 48 * scale,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24 * scale),
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 20 * scale,
              offset: Offset(0, 6 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with background circle
            Container(
              width: 80 * scale,
              height: 80 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  AppAssets.calendar,
                  width: 40 * scale,
                  height: 40 * scale,
                  colorFilter: ColorFilter.mode(
                    AppColors.primary.withValues(alpha: 0.6),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20 * scale),
            // Main message
            Text(
              AppStrings.scheduleNoScheduleForDay,
              style: AppTextStyles.arimo(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8 * scale),
            // Sub message
            Text(
              'Hãy tận hưởng ngày nghỉ ngơi của bạn',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 16 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Header
          Row(
            children: [
              // Day number badge - smaller
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  '${AppStrings.scheduleDay} $dayNo',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              // Compact stats - only completed and pending
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CompactStatBadge(
                    icon: Icons.check_circle,
                    count: stats['completed']!,
                    color: AppColors.verified,
                    scale: scale,
                  ),
                  SizedBox(width: 6 * scale),
                  _CompactStatBadge(
                    icon: Icons.schedule,
                    count: stats['pending']!,
                    color: AppColors.textSecondary,
                    scale: scale,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          // Timeline
          ...sortedSchedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;
            final isLast = index == sortedSchedules.length - 1;
            return ScheduleActivityItem(
              schedule: schedule,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }
}

/// Compact stat badge - smaller and more subtle
class _CompactStatBadge extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  final double scale;

  const _CompactStatBadge({
    required this.icon,
    required this.count,
    required this.color,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12 * scale,
          color: color,
        ),
        SizedBox(width: 3 * scale),
        Text(
          '$count',
          style: AppTextStyles.arimo(
            fontSize: 11 * scale,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

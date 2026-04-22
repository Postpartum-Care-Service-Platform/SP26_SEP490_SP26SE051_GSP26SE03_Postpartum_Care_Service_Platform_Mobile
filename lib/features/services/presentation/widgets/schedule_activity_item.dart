import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/family_schedule_entity.dart';
import 'schedule_activity_detail_sheet.dart';

/// Schedule Activity Item Widget
/// Displays a single activity in the timeline
class ScheduleActivityItem extends StatelessWidget {
  final FamilyScheduleEntity schedule;
  final bool isLast;

  const ScheduleActivityItem({
    super.key,
    required this.schedule,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final isCompleted = schedule.isCompleted; // Done status
    final isStaffDone = schedule.isStaffDone;
    final isMissed = schedule.isMissed;
    final isCancelled = schedule.isCancelled;
    final isForMom = schedule.isForMom;
    final isForBoth = schedule.isForBoth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time representation (prominent on the left)
        SizedBox(
          width: 46 * scale,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(height: 10 * scale), // adjust vertical alignment
              Text(
                schedule.startTime.substring(0, 5),
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                  color: isCompleted
                      ? AppColors.verified
                      : isStaffDone
                          ? AppColors.primary
                          : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                schedule.endTime.substring(0, 5),
                style: AppTextStyles.arimo(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 10 * scale),

        // Timeline indicator
        Column(
          children: [
            SizedBox(height: 12 * scale), // line up dot with first time text
            // Dot - simple indicator without background
            Container(
              width: 14 * scale, // slightly larger dot
              height: 14 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.verified
                    : isStaffDone
                        ? AppColors.primary
                        : isMissed
                            ? AppColors.scheduleMissed
                            : isCancelled
                                ? AppColors.scheduleCancelled
                                : AppColors.textSecondary,
                border: Border.all(
                  color: AppColors.white,
                  width: 2 * scale, // Inner white ring effect to make it pop
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCompleted
                            ? AppColors.verified
                            : isStaffDone
                                ? AppColors.primary
                                : AppColors.textSecondary)
                        .withValues(alpha: 0.3),
                    blurRadius: 4 * scale,
                    spreadRadius: 1 * scale,
                  ),
                ],
              ),
            ),
            // Line (if not last)
            if (!isLast)
              Container(
                width: 2 * scale,
                height: 56 * scale, // slightly longer line to accommodate larger dot
                margin: EdgeInsets.symmetric(vertical: 4 * scale),
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(1 * scale),
                ),
              ),
          ],
        ),
        SizedBox(width: 12 * scale),

        // Activity content
        Expanded(
          child: GestureDetector(
            onTap: () {
              ScheduleActivityDetailSheet.show(context, schedule);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12 * scale),
              padding: EdgeInsets.symmetric(
                horizontal: 14 * scale,
                vertical: 12 * scale,
              ),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.verified.withValues(alpha: 0.06)
                    : isStaffDone
                        ? AppColors.primary.withValues(alpha: 0.04)
                        : isMissed
                            ? AppColors.scheduleMissed.withValues(alpha: 0.04)
                            : isCancelled
                                ? AppColors.scheduleCancelled.withValues(alpha: 0.04)
                                : AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.verified.withValues(alpha: 0.3)
                      : isStaffDone
                          ? AppColors.primary
                          : isMissed
                              ? AppColors.scheduleMissed.withValues(alpha: 0.2)
                              : isCancelled
                                  ? AppColors.scheduleCancelled.withValues(alpha: 0.2)
                                  : AppColors.textPrimary.withValues(alpha: 0.2),
                  width: isStaffDone ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 6 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity name
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4 * scale),
                      child: Text(
                        (schedule.title?.trim().isNotEmpty ?? false)
                            ? schedule.title!.trim()
                            : schedule.activity,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? AppColors.verified
                              : isStaffDone
                                  ? AppColors.primary
                                  : isMissed
                                      ? AppColors.scheduleMissed
                                      : isCancelled
                                          ? AppColors.scheduleCancelled
                                          : AppColors.textPrimary,
                        ).copyWith(
                          decoration: (isMissed || isCancelled)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  // Target icon(s)
                  if (isForBoth)
                    // Show both icons when target is "both"
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTargetIcon(
                          AppAssets.appIconFirst,
                          isCompleted,
                          isStaffDone,
                          scale,
                        ),
                        SizedBox(width: 4 * scale),
                        _buildTargetIcon(
                          AppAssets.appIconSecond,
                          isCompleted,
                          isStaffDone,
                          scale,
                        ),
                      ],
                    )
                  else
                    // Show single icon for Mom or Baby
                    _buildTargetIcon(
                      isForMom ? AppAssets.appIconFirst : AppAssets.appIconSecond,
                      isCompleted,
                      isStaffDone,
                      scale,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build target icon widget
  Widget _buildTargetIcon(String assetPath, bool isCompleted, bool isStaffDone, double scale) {
    return Container(
      width: 44 * scale,
      height: 44 * scale,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12 * scale),
          bottomLeft: Radius.circular(8 * scale),
        ),
      ),
      padding: EdgeInsets.all(6 * scale),
      child: SvgPicture.asset(
        assetPath,
        fit: BoxFit.contain,
        colorFilter: (isCompleted || isStaffDone)
            ? ColorFilter.mode(
                isCompleted ? AppColors.verified : AppColors.primary,
                BlendMode.srcIn,
              )
            : null,
      ),
    );
  }
}

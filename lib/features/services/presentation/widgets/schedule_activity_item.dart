import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
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
    final isMissed = schedule.isMissed;
    final isCancelled = schedule.isCancelled;
    final isForMom = schedule.isForMom;
    final isForBoth = schedule.isForBoth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            // Dot - simple indicator without background
            Container(
              width: 12 * scale,
              height: 12 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.verified
                    : isMissed
                        ? AppColors.scheduleMissed
                        : isCancelled
                            ? AppColors.scheduleCancelled
                            : AppColors.textSecondary,
              ),
            ),
            // Line (if not last) - shorter
            if (!isLast)
              Container(
                width: 2 * scale,
                height: 50 * scale,
                margin: EdgeInsets.symmetric(vertical: 3 * scale),
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
            onLongPress: () {
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
                    : isMissed
                        ? AppColors.scheduleMissed.withValues(alpha: 0.04)
                        : isCancelled
                            ? AppColors.scheduleCancelled.withValues(alpha: 0.04)
                            : AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: isCompleted
                      ? AppColors.verified.withValues(alpha: 0.3)
                      : isMissed
                          ? AppColors.scheduleMissed.withValues(alpha: 0.2)
                          : isCancelled
                              ? AppColors.scheduleCancelled.withValues(alpha: 0.2)
                              : AppColors.textPrimary.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 6 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time badge and Target icon - same row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Time badge - more compact
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8 * scale,
                        vertical: 4 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.verified.withValues(alpha: 0.12)
                            : AppColors.textSecondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6 * scale),
                      ),
                      child: Text(
                        schedule.timeRange,
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AppColors.verified
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Target icon(s) - smaller
                    if (isForBoth)
                      // Show both icons when target is "both"
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTargetIcon(
                            AppAssets.appIconFirst,
                            isCompleted,
                            scale,
                          ),
                          SizedBox(width: 4 * scale),
                          _buildTargetIcon(
                            AppAssets.appIconSecond,
                            isCompleted,
                            scale,
                          ),
                        ],
                      )
                    else
                      // Show single icon for Mom or Baby
                      _buildTargetIcon(
                        isForMom ? AppAssets.appIconFirst : AppAssets.appIconSecond,
                        isCompleted,
                        scale,
                      ),
                  ],
                ),
                SizedBox(height: 10 * scale),
                // Activity name - smaller
                Text(
                  schedule.activity,
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? AppColors.verified
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
                ),
                // Status indicator - below activity name (only for Missed and Cancelled)
                if (isMissed || isCancelled) ...[
                  SizedBox(height: 8 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: isMissed
                          ? AppColors.scheduleMissed.withValues(alpha: 0.15)
                          : AppColors.scheduleCancelled.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6 * scale),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMissed ? Icons.cancel : Icons.block,
                          size: 12 * scale,
                          color: isMissed ? AppColors.scheduleMissed : AppColors.scheduleCancelled,
                        ),
                        SizedBox(width: 4 * scale),
                        Text(
                          isMissed ? AppStrings.scheduleMissed : AppStrings.scheduleCancelled,
                          style: AppTextStyles.tinos(
                            fontSize: 10 * scale,
                            fontWeight: FontWeight.w600,
                            color: isMissed ? AppColors.scheduleMissed : AppColors.scheduleCancelled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Note (if exists)
                if (schedule.note != null && schedule.note!.isNotEmpty) ...[
                  SizedBox(height: 8 * scale),
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 16 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: Text(
                            schedule.note!,
                            style: AppTextStyles.tinos(
                              fontSize: 13 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build target icon widget
  Widget _buildTargetIcon(String assetPath, bool isCompleted, double scale) {
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
        colorFilter: isCompleted
            ? ColorFilter.mode(
                AppColors.verified,
                BlendMode.srcIn,
              )
            : null,
      ),
    );
  }
}

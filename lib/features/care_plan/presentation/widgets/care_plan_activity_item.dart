import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../domain/entities/care_plan_entity.dart';

class CarePlanActivityItem extends StatelessWidget {
  final CarePlanEntity carePlan;
  final bool isLast;

  const CarePlanActivityItem({
    super.key,
    required this.carePlan,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline column
          SizedBox(
            width: 24 * scale,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 12 * scale,
                  height: 12 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 4 * scale,
                      ),
                    ],
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2 * scale,
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12 * scale),
          // Activity card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: 12 * scale),
              padding: EdgeInsets.all(14 * scale),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.borderLight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      '${carePlan.startTime} - ${carePlan.endTime}',
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  // Activity name
                  Text(
                    carePlan.activityName,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // Instruction
                  if (carePlan.instruction != null &&
                      carePlan.instruction!.isNotEmpty &&
                      carePlan.instruction != 'string') ...[
                    SizedBox(height: 6 * scale),
                    Text(
                      carePlan.instruction!,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

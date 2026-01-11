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

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time indicator
          Column(
            children: [
              Container(
                width: 12 * scale,
                height: 12 * scale,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2 * scale,
                  height: 60 * scale,
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
            ],
          ),
          SizedBox(width: 16 * scale),
          // Content
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Activity name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          carePlan.activityName,
                          style: AppTextStyles.tinos(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10 * scale,
                          vertical: 6 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8 * scale),
                        ),
                        child: Text(
                          '${carePlan.startTime} - ${carePlan.endTime}',
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Instruction
                  if (carePlan.instruction.isNotEmpty && carePlan.instruction != 'string') ...[
                    SizedBox(height: 8 * scale),
                      Text(
                      carePlan.instruction,
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ).copyWith(height: 1.4),
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

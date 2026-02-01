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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8 * scale),
            child: Container(
        padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10 * scale),
                border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
            style: BorderStyle.solid,
                  ),
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
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6 * scale),
                        ),
                        child: Text(
                          '${carePlan.startTime} - ${carePlan.endTime}',
                          style: AppTextStyles.arimo(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                          ),
                        ),
                      ),
            SizedBox(height: 8 * scale),
            // Activity name
            Text(
              carePlan.activityName,
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
                  ),
                  // Instruction
            if (carePlan.instruction.isNotEmpty && 
                carePlan.instruction != 'string') ...[
              SizedBox(height: 6 * scale),
                      Text(
                      carePlan.instruction,
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
    );
  }
}

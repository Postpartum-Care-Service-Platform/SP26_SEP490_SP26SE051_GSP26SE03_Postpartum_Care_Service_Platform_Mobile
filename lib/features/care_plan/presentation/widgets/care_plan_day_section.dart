import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../domain/entities/care_plan_entity.dart';
import 'care_plan_activity_item.dart';

class CarePlanDaySection extends StatelessWidget {
  final int dayNo;
  final List<CarePlanEntity> activities;
  final bool isLast;

  const CarePlanDaySection({
    super.key,
    required this.dayNo,
    required this.activities,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 12 * scale,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10 * scale),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 18 * scale,
                color: AppColors.primary,
              ),
              SizedBox(width: 8 * scale),
              Text(
                '${AppStrings.day} $dayNo',
                style: AppTextStyles.tinos(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Text(
                '${activities.length} ${AppStrings.activity.toLowerCase()}',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12 * scale),
        // Activities list
        ...activities.asMap().entries.map((entry) {
          final index = entry.key;
          final activity = entry.value;
          return CarePlanActivityItem(
            carePlan: activity,
            isLast: index == activities.length - 1 && isLast,
          );
        }),
        if (!isLast) SizedBox(height: 24 * scale),
      ],
    );
  }
}

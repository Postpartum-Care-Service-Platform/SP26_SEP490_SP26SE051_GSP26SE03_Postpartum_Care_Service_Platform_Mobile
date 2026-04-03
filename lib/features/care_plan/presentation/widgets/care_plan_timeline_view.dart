import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/care_plan_entity.dart';
import 'care_plan_activity_item.dart';

class CarePlanTimelineView extends StatelessWidget {
  final int dayNo;
  final List<CarePlanEntity> activities;

  const CarePlanTimelineView({
    super.key,
    required this.dayNo,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (activities.isEmpty) {
      return Center(
        child: Text(
          'Không có hoạt động nào cho ngày $dayNo',
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 20 * scale,
        vertical: 4 * scale,
      ),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isLast = index == activities.length - 1;

        return CarePlanActivityItem(
          carePlan: activity,
          isLast: isLast,
        );
      },
    );
  }
}

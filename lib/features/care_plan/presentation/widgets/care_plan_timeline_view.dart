import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../domain/entities/care_plan_entity.dart';
import 'care_plan_activity_item.dart';

class CarePlanTimelineView extends StatefulWidget {
  final int dayNo;
  final List<CarePlanEntity> activities;

  const CarePlanTimelineView({
    super.key,
    required this.dayNo,
    required this.activities,
  });

  @override
  State<CarePlanTimelineView> createState() => _CarePlanTimelineViewState();
}

class _CarePlanTimelineViewState extends State<CarePlanTimelineView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Group activities by hour slot
  Map<String, List<CarePlanEntity>> _groupActivitiesByHour() {
    final activities = widget.activities;
    final Map<String, List<CarePlanEntity>> grouped = {};

    for (final activity in activities) {
      // Extract hour from startTime (format: "HH:mm")
      final hour = activity.startTime.split(':').first;
      final key = hour.padLeft(2, '0'); // Ensure 2 digits

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(activity);
    }

    // Sort activities within each hour by sortOrder
    for (final key in grouped.keys) {
      grouped[key]!.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return grouped;
  }

  /// Generate hour slots from 0 to 23
  List<String> _generateHourSlots() {
    return List.generate(24, (index) => index.toString().padLeft(2, '0'));
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final groupedActivities = _groupActivitiesByHour();
    final hourSlots = _generateHourSlots();

    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: hourSlots.map((hour) {
            final hourActivities = groupedActivities[hour] ?? [];
            
            if (hourActivities.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Padding(
              padding: EdgeInsets.only(bottom: 16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: hourActivities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  final isLast = index == hourActivities.length - 1;
                  
                  return CarePlanActivityItem(
                    carePlan: activity,
                    isLast: isLast,
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

}

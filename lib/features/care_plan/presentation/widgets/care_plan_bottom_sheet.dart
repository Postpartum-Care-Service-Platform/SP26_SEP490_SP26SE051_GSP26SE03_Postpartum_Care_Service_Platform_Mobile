import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/care_plan_entity.dart';
import '../bloc/care_plan_bloc.dart';
import '../bloc/care_plan_event.dart';
import '../bloc/care_plan_state.dart';
import 'care_plan_day_section.dart';

class CarePlanBottomSheet extends StatelessWidget {
  final int packageId;
  final String packageName;

  const CarePlanBottomSheet({
    super.key,
    required this.packageId,
    required this.packageName,
  });

  static void show(BuildContext context, {required int packageId, required String packageName}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => InjectionContainer.carePlanBloc
          ..add(CarePlanLoadRequested(packageId)),
        child: CarePlanBottomSheet(
          packageId: packageId,
          packageName: packageName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12 * scale, bottom: 8 * scale),
            width: 40 * scale,
            height: 4 * scale,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 16 * scale),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.carePlanTitle,
                        style: AppTextStyles.tinos(
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        packageName,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: AppColors.textPrimary,
                    size: 24 * scale,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: BlocBuilder<CarePlanBloc, CarePlanState>(
              builder: (context, state) {
                if (state is CarePlanLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }

                if (state is CarePlanError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16 * scale),
                        Text(
                          state.message,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24 * scale),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CarePlanBloc>().add(
                                  CarePlanLoadRequested(packageId),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                          ),
                          child: Text(
                            AppStrings.retry,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is CarePlanLoaded) {
                  if (state.carePlans.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy_outlined,
                            size: 64 * scale,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16 * scale),
                          Text(
                            AppStrings.noCarePlanDetails,
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

                  // Group activities by day
                  final activitiesByDay = <int, List<CarePlanEntity>>{};
                  for (final carePlan in state.carePlans) {
                    activitiesByDay.putIfAbsent(carePlan.dayNo, () => []).add(carePlan);
                  }

                  // Sort days
                  final sortedDays = activitiesByDay.keys.toList()..sort();

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<CarePlanBloc>().add(CarePlanRefresh(packageId));
                    },
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: EdgeInsets.all(20 * scale),
                      itemCount: sortedDays.length,
                      itemBuilder: (context, index) {
                        final dayNo = sortedDays[index];
                        final activities = activitiesByDay[dayNo];
                        if (activities == null) return const SizedBox.shrink();
                        
                        // Sort activities by sortOrder
                        final sortedActivities = List<CarePlanEntity>.from(activities)
                          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                        return CarePlanDaySection(
                          dayNo: dayNo,
                          activities: sortedActivities,
                          isLast: index == sortedDays.length - 1,
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

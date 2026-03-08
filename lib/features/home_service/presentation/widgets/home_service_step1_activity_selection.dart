import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/home_activity_entity.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../bloc/home_service_bloc.dart';
import '../bloc/home_service_event.dart';
import '../bloc/home_service_state.dart';

class HomeServiceStep1ActivitySelection extends StatelessWidget {
  const HomeServiceStep1ActivitySelection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<HomeServiceBloc, HomeServiceState>(
      builder: (context, state) {
        if (state is HomeServiceLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (state is HomeServiceError) {
          return Center(
            child: Text(
              state.message,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }

        final data = _extractStepData(state);
        if (data == null) return const SizedBox();

        final activities = data.activities.where((a) => a.isActive).toList();
        final selectedActivityIds = data.selections.map((s) => s.activity.id).toSet();

        return SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16 * scale),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    final isSelected = selectedActivityIds.contains(activity.id);

                    return _ActivityCard(
                      activity: activity,
                      isSelected: isSelected,
                      onToggle: () {
                        context.read<HomeServiceBloc>().add(
                              HomeServiceToggleActivitySelection(activity: activity),
                            );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 8 * scale),
            ],
          ),
        );
      },
    );
  }

  _Step1Data? _extractStepData(HomeServiceState state) {
    if (state is HomeServiceActivitiesLoaded) {
      return _Step1Data(activities: state.activities, selections: state.selections);
    }
    if (state is HomeServiceFreeStaffLoaded) {
      return _Step1Data(activities: state.activities, selections: state.selections);
    }
    if (state is HomeServiceSummaryReady) {
      return _Step1Data(activities: state.activities, selections: state.selections);
    }
    return null;
  }
}

class _Step1Data {
  final List<HomeActivityEntity> activities;
  final List<HomeServiceSelectionEntity> selections;

  const _Step1Data({
    required this.activities,
    required this.selections,
  });
}

class _ActivityCard extends StatelessWidget {
  final HomeActivityEntity activity;
  final bool isSelected;
  final VoidCallback onToggle;

  const _ActivityCard({
    required this.activity,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * scale),
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    style: AppTextStyles.tinos(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    activity.description,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Text(
                    '${activity.price.toStringAsFixed(0)}${AppStrings.currencyUnit.trim()} • ${activity.duration} ${AppStrings.homeServiceMinutes}',
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 24 * scale,
            ),
          ],
        ),
      ),
    );
  }
}

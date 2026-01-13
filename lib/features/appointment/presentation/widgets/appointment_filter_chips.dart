import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../screens/appointment_screen.dart';

/// Filter chips widget for appointment filtering
class AppointmentFilterChips extends StatelessWidget {
  final AppointmentFilterType selectedFilter;
  final Function(AppointmentFilterType) onFilterChanged;

  const AppointmentFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      height: 50 * scale,
      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: AppStrings.filterAll,
            isSelected: selectedFilter == AppointmentFilterType.all,
            onTap: () => onFilterChanged(AppointmentFilterType.all),
            scale: scale,
          ),
          SizedBox(width: 12 * scale),
          _FilterChip(
            label: AppStrings.filterUpcoming,
            isSelected: selectedFilter == AppointmentFilterType.upcoming,
            onTap: () => onFilterChanged(AppointmentFilterType.upcoming),
            scale: scale,
          ),
          SizedBox(width: 12 * scale),
          _FilterChip(
            label: AppStrings.filterCompleted,
            isSelected: selectedFilter == AppointmentFilterType.completed,
            onTap: () => onFilterChanged(AppointmentFilterType.completed),
            scale: scale,
          ),
          SizedBox(width: 12 * scale),
          _FilterChip(
            label: AppStrings.filterCancelled,
            isSelected: selectedFilter == AppointmentFilterType.cancelled,
            onTap: () => onFilterChanged(AppointmentFilterType.cancelled),
            scale: scale,
          ),
        ],
      ),
    );
  }
}

/// Individual filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double scale;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 8 * scale,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8 * scale,
                    offset: Offset(0, 2 * scale),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/package_event.dart';

/// Package filter tabs widget
class PackageFilterTabs extends StatelessWidget {
  final PackageFilter currentFilter;
  final ValueChanged<PackageFilter> onFilterChanged;

  const PackageFilterTabs({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        Expanded(
          child: _FilterTab(
            scale: scale,
            label: AppStrings.packageTypeCenter,
            filter: PackageFilter.center,
            isSelected: currentFilter == PackageFilter.center,
            onTap: () => onFilterChanged(PackageFilter.center),
          ),
        ),
        SizedBox(width: 8 * scale),
        Expanded(
          child: _FilterTab(
            scale: scale,
            label: AppStrings.packageTypeHome,
            filter: PackageFilter.home,
            isSelected: currentFilter == PackageFilter.home,
            onTap: () => onFilterChanged(PackageFilter.home),
          ),
        ),
      ],
    );
  }
}

class _FilterTab extends StatelessWidget {
  final double scale;
  final String label;
  final PackageFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.scale,
    required this.label,
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12 * scale,
            vertical: 10 * scale,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

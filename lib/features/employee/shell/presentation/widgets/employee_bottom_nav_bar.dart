// lib/features/employee/presentation/widgets/employee_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';  
import '../../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_quick_menu.dart';

/// Bottom nav cho nhân viên, được **đồng bộ** với quick menu
/// Sử dụng EmployeeQuickMenuPresets để đảm bảo tính nhất quán
class EmployeeBottomNavBar extends StatelessWidget {
  final AppBottomTab currentTab;
  final ValueChanged<AppBottomTab> onTabSelected;

  const EmployeeBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy các bottom tab items từ quick menu presets
    final primaryItems = EmployeeQuickMenuPresets.primaryItems();
    final bottomTabItems = primaryItems
        .where((item) => item.type == EmployeeQuickMenuItemType.bottomTab)
        .toList();

    // Map sang AppBottomTab
    final tabs = bottomTabItems
        .map((item) => item.bottomTab!)
        .whereType<AppBottomTab>()
        .toList();

    // Tìm index hiện tại
    final currentIndex = tabs.indexOf(currentTab);
    final safeIndex = currentIndex >= 0 ? currentIndex : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) {
            if (index < tabs.length) {
              onTabSelected(tabs[index]);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.third,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          items: bottomTabItems.map((item) {
            final isSelected = item.bottomTab == currentTab;
            return BottomNavigationBarItem(
              icon: _EmployeeNavIcon(
                asset: item.iconAsset,
                isActive: isSelected,
              ),
              activeIcon: _EmployeeNavIcon(
                asset: item.iconAsset,
                isActive: true,
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EmployeeNavIcon extends StatelessWidget {
  final String asset;
  final bool isActive;

  const _EmployeeNavIcon({
    required this.asset,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SvgPicture.asset(
        asset,
        width: 22,
        height: 22,
        colorFilter: ColorFilter.mode(
          isActive ? AppColors.primary : AppColors.third,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}

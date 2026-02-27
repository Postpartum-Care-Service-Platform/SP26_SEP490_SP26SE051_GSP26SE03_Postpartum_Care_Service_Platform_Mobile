// lib/features/employee/presentation/widgets/employee_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';

/// Bottom nav cho nhân viên, được **đồng bộ** với quick menu
/// dựa theo cấu hình trong `EmployeeQuickMenuPresets`:
/// - Lịch làm việc  -> AppBottomTab.appointment
/// - Dịch vụ        -> AppBottomTab.services
/// - Trao đổi (chat)-> AppBottomTab.chat
class EmployeeBottomNavBar extends StatelessWidget {
  final AppBottomTab currentTab;
  final ValueChanged<AppBottomTab> onTabSelected;

  const EmployeeBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  static const List<AppBottomTab> _tabs = [
    AppBottomTab.appointment,
    AppBottomTab.services,
    AppBottomTab.chat,
  ];

  @override
  Widget build(BuildContext context) {
    // Nếu currentTab không thuộc 3 tab nhân viên, mặc định chọn tab đầu tiên
    final currentIndex = _tabs.indexOf(currentTab);
    final safeIndex = currentIndex >= 0 ? currentIndex : 0;

    return BottomNavigationBar(
      currentIndex: safeIndex,
      onTap: (index) => onTabSelected(_tabs[index]),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.third,
      items: const [
        BottomNavigationBarItem(
          icon: _EmployeeNavIcon(asset: AppAssets.calendar),
          label: 'Lịch làm việc',
        ),
        BottomNavigationBarItem(
          icon: _EmployeeNavIcon(asset: AppAssets.appIconThird),
          label: 'Dịch vụ',
        ),
        BottomNavigationBarItem(
          icon: _EmployeeNavIcon(asset: AppAssets.chatMessage),
          label: 'Trao đổi',
        ),
      ],
    );
  }
}

class _EmployeeNavIcon extends StatelessWidget {
  final String asset;

  const _EmployeeNavIcon({required this.asset});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: 22,
      height: 22,
    );
  }
}

// lib/features/employee/presentation/widgets/employee_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_quick_menu.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    String? memberType;
    try {
      final authState = context.watch<AuthBloc>().state;
        if (authState is AuthCurrentAccountLoaded) {
          memberType = (authState.account as dynamic).memberType;
          memberType ??= (authState.account as dynamic).ownerProfile?.memberTypeName;
        }
    } catch (_) {}

    final isHomeStaff =
        (memberType?.toLowerCase().contains('homestaff') ?? false) ||
        (memberType?.toLowerCase().contains('home-staff') ?? false) ||
        (memberType?.toLowerCase().contains('home nurse') ?? false) ||
        (memberType?.toLowerCase().contains('tại nhà') ?? false);

    // Khai báo danh sách Bottom Navigation Bar phụ thuộc vào role
    final List<EmployeeQuickMenuItem> bottomTabItems = isHomeStaff
        ? [
            EmployeeQuickMenuItem.bottom(
              id: 'family',
              label: 'Gia đình',
              iconAsset: AppAssets.family,
              tab: AppBottomTab.family,
            ),
            EmployeeQuickMenuItem.bottom(
              id: 'myBookings',
              label: 'Booking của tôi',
              iconAsset: AppAssets.calendarBold,
              tab: AppBottomTab.myBookings,
            ),
            EmployeeQuickMenuItem.bottom(
              id: 'wallet',
              label: 'Ví tiền',
              iconAsset: AppAssets
                  .menuSecond, // Using a generic icon for wallet since wallet isn't in AppAssets yet
              tab: AppBottomTab.wallet,
            ),
          ]
        : [
            EmployeeQuickMenuItem.bottom(
              id: 'family',
              label: 'Gia đình',
              iconAsset: AppAssets.family,
              tab: AppBottomTab.family,
            ),
            EmployeeQuickMenuItem.bottom(
              id: 'contracts',
              label: 'Hợp đồng',
              iconAsset: AppAssets.menuThird,
              tab: AppBottomTab.contracts,
            ),
            EmployeeQuickMenuItem.bottom(
              id: 'amenities',
              label: 'Tiện ích',
              iconAsset: AppAssets.serviceAmenity,
              tab: AppBottomTab.amenities,
            ),
            EmployeeQuickMenuItem.bottom(
              id: 'services',
              label: 'Dịch vụ',
              iconAsset: AppAssets.appIconThird,
              tab: AppBottomTab.services,
            ),
          ];

    return Container(
      padding: const EdgeInsets.only(top: 8),
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
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: bottomTabItems.map((item) {
              final isSelected = item.bottomTab == currentTab;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (item.bottomTab != null) {
                      onTabSelected(item.bottomTab!);
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _EmployeeNavIcon(
                        asset: item.iconAsset,
                        isActive: isSelected,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: isSelected ? 12 : 11,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          letterSpacing: isSelected ? 0.2 : 0.1,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.third,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _EmployeeNavIcon extends StatelessWidget {
  final String asset;
  final bool isActive;

  const _EmployeeNavIcon({required this.asset, required this.isActive});

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

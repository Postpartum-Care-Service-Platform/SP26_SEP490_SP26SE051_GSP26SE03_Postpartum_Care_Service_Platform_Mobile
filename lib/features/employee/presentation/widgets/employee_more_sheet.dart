// lib/features/employee/presentation/widgets/employee_more_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../screens/employee_meal_plan_screen.dart';
import '../screens/employee_profile_screen.dart';
import '../screens/service_booking_screen.dart';

class EmployeeMoreSheet {
  EmployeeMoreSheet._();

  static void show(BuildContext context) {
    // EmployeePortalScreen không luôn nằm dưới Provider<AuthBloc>, nên lấy bloc từ DI.
    final authBloc = InjectionContainer.authBloc;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 12),
                _SheetItem(
                  icon: Icons.restaurant_menu,
                  title: 'Coi bữa ăn theo hộ',
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EmployeeMealPlanScreen(),
                      ),
                    );
                  },
                ),
                _SheetItem(
                  icon: Icons.auto_awesome,
                  title: 'Đặt dịch vụ',
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ServiceBookingScreen(),
                      ),
                    );
                  },
                ),
                _SheetItem(
                  icon: Icons.person_rounded,
                  title: AppStrings.employeeProfile,
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: authBloc,
                          child: const EmployeeProfileScreen(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SheetItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}

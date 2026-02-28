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
      isScrollControlled: false,
      builder: (bottomSheetContext) {
        final bottomInset = MediaQuery.of(bottomSheetContext).padding.bottom;

        return Container(
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: EdgeInsets.only(
              top: 8,
              left: 0,
              right: 0,
              bottom: bottomInset > 0 ? bottomInset : 8,
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tiện ích cho nhân viên',
                                style: AppTextStyles.arimo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Truy cập nhanh các chức năng thường dùng trong ca làm.',
                                style: AppTextStyles.arimo(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 4),
                  _SheetItem(
                    icon: Icons.restaurant_menu,
                    title: 'Coi bữa ăn theo hộ',
                    subtitle: 'Xem suất ăn theo từng hộ gia đình được phụ trách.',
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
                    subtitle: 'Đặt gói chăm sóc, dịch vụ tiện ích cho khách hàng.',
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
                    subtitle: 'Xem và cập nhật thông tin tài khoản nhân viên.',
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
          ),
        );
      },
    );
  }
}

class _SheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SheetItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTextStyles.arimo(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

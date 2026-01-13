// lib/features/employee/presentation/widgets/employee_header_bar.dart
import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';
import 'employee_notifications_sheet.dart';

class EmployeeHeaderBar extends StatelessWidget {
  final String title;
  final String subtitle;

  const EmployeeHeaderBar({
    super.key,
    required this.title,
    required this.subtitle,
  });

  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await AppWidgets.showConfirmDialog(
      context,
      title: AppStrings.logoutTitle,
      message: AppStrings.logoutConfirmation,
      confirmText: AppStrings.logout,
      cancelText: AppStrings.cancel,
      confirmColor: AppColors.logout,
      icon: Icons.logout_rounded,
    );

    if (confirmed != true) return;

    // Clear authentication data
    await AuthService.logout();
    
    // Reset API client
    ApiClient.reset();

    if (context.mounted) {
      AppToast.showSuccess(
        context,
        message: AppStrings.successLogout,
      );

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: Mock list giống TSX -> unreadCount.
    const unreadCount = 2;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.85),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => EmployeeNotificationsSheet.show(context),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_none, color: AppColors.textPrimary),
                  if (unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$unreadCount',
                          style: AppTextStyles.arimo(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _handleLogout(context),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.logout_rounded,
                color: AppColors.logout,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

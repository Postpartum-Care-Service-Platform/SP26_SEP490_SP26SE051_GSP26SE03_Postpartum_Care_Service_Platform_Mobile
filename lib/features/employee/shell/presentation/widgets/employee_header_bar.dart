// lib/features/employee/presentation/widgets/employee_header_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/services/auth_service.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';

class EmployeeHeaderBar extends StatefulWidget {
  final String title;
  final String subtitle;

  final bool showBackButton;
  final VoidCallback? onBack;

  const EmployeeHeaderBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<EmployeeHeaderBar> createState() => _EmployeeHeaderBarState();
}

class _EmployeeHeaderBarState extends State<EmployeeHeaderBar> {
  int _unreadCount = 0;
  bool _isLoadingUnread = false;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    if (_isLoadingUnread) return;
    setState(() => _isLoadingUnread = true);
    try {
      final count =
          await InjectionContainer.notificationRepository.getUnreadCount();
      if (!mounted) return;
      setState(() => _unreadCount = count);
    } catch (_) {
      // Nếu API lỗi (chưa có endpoint / role không có quyền),
      // tránh crash header: ẩn badge bằng cách set về 0.
      if (!mounted) return;
      setState(() => _unreadCount = 0);
    } finally {
      if (mounted) {
        setState(() => _isLoadingUnread = false);
      }
    }
  }

  Future<void> _openNotifications() async {
    await AppRouter.push(context, AppRoutes.notifications);
    await _loadUnreadCount();
  }

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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            const Color(0xFFE67E22), // Deep orange
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 24),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Column(
              children: [
                Row(
                  children: [
                    if (widget.showBackButton) ...[
                      _HeaderIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: widget.onBack ?? () {
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: AppTextStyles.arimo(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.subtitle,
                                  style: AppTextStyles.arimo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.white.withValues(alpha: 0.9),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: _openNotifications,
                      badgeCount: _unreadCount,
                    ),
                    const SizedBox(width: 12),
                    _HeaderIconButton(
                      icon: Icons.logout_rounded,
                      onTap: () => _handleLogout(context),
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final bool isDestructive;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.white,
              size: 22,
            ),
            if (badgeCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo luôn cố gắng load current account khi mở màn hình
    context.read<AuthBloc>().add(const AuthLoadCurrentAccount());
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.employeeProfileTitle,
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: AppLoadingIndicator(color: AppColors.primary),
            );
          }

          if (state is! AuthCurrentAccountLoaded) {
            return _buildEmptyState(scale);
          }

          final account = state.account;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 16 * scale),
            child: Column(
              children: [
                _buildHeader(
                  scale,
                  account.displayName,
                  account.email,
                  account.avatarUrl,
                  account.roleName,
                ),
                SizedBox(height: 16 * scale),
                _buildInfoSection(scale, account),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off_rounded,
              size: 64 * scale,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16 * scale),
            Text(
              AppStrings.noEmployeeProfile,
              style: AppTextStyles.tinos(
                fontSize: 18 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8 * scale),
            Text(
              AppStrings.employeeProfileHint,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    double scale,
    String name,
    String email,
    String? avatarUrl,
    String roleName,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: Container(
        padding: EdgeInsets.all(16 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar style gần giống FamilyMemberCard / ProfileHeader
            Container(
              width: 64 * scale,
              height: 64 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Container(
                margin: EdgeInsets.all(2 * scale),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                ),
                child: avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_rounded,
                            size: 32 * scale,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.person_rounded,
                        size: 32 * scale,
                        color: AppColors.primary,
                      ),
              ),
            ),
            SizedBox(height: 16 * scale, width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.tinos(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    email,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  AppWidgets.pillBadge(
                    context,
                    text: roleName,
                    background:
                        AppColors.primary.withValues(alpha: 0.12),
                    borderColor:
                        AppColors.primary.withValues(alpha: 0.3),
                    textColor: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(double scale, dynamic account) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale),
      child: AppWidgets.sectionContainer(
        context,
        children: [
          _buildInfoRow(
            scale,
            icon: Icons.badge_rounded,
            label: 'ID tài khoản',
            value: account.id,
          ),
          _buildInfoRow(
            scale,
            icon: Icons.person_outline_rounded,
            label: AppStrings.username,
            value: account.username,
          ),
          _buildInfoRow(
            scale,
            icon: Icons.email_rounded,
            label: AppStrings.email,
            value: account.email,
          ),
          _buildInfoRow(
            scale,
            icon: Icons.phone_rounded,
            label: AppStrings.phoneNumber,
            value: account.phone,
          ),
          _buildInfoRow(
            scale,
            icon: Icons.verified_user_rounded,
            label: AppStrings.accountStatus,
            value: account.isActive
                ? AppStrings.accountStatusActive
                : AppStrings.accountStatusLocked,
          ),
          if (account.ownerProfile != null)
            _buildInfoRow(
              scale,
              icon: Icons.home_rounded,
              label: 'Khách hàng phụ trách',
              value: account.ownerProfile!.fullName,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    double scale, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        children: [
          Icon(icon, size: 20 * scale, color: AppColors.primary),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  value,
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

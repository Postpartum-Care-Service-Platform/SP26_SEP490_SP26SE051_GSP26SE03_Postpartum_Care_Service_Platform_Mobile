import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../profile/presentation/widgets/account_info_row.dart';
import '../widgets/employee_scaffold.dart';

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

    return EmployeeScaffold(
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

          return SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16 * scale,
                right: 16 * scale,
                top: 16 * scale,
                bottom: 24 * scale,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Account summary card (gradient style)
                  _buildAccountSummaryCard(scale, account),
                  SizedBox(height: 20 * scale),
                  // Account details section
                  _buildAccountDetailsSection(scale, account),
                ],
              ),
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

  Widget _buildAccountSummaryCard(double scale, dynamic account) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20 * scale,
            offset: Offset(0, 10 * scale),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30 * scale,
            right: -30 * scale,
            child: Container(
              width: 120 * scale,
              height: 120 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20 * scale,
            left: -20 * scale,
            child: Container(
              width: 80 * scale,
              height: 80 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(24 * scale),
            child: Column(
              children: [
                // Avatar with border and verified badge
                AvatarWidget(
                  imageUrl: account.avatarUrl,
                  displayName: account.displayName,
                  size: 100,
                  showVerifiedBadge: true,
                  isVerified: account.isEmailVerified ?? false,
                  backgroundColor: AppColors.white,
                  borderWidth: 4,
                  borderColor: AppColors.white,
                ),
                SizedBox(height: 20 * scale),
                // Display name with verified icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        account.displayName,
                        style: AppTextStyles.tinos(
                          fontSize: 24 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (account.isEmailVerified == true) ...[
                      SizedBox(width: 8 * scale),
                      Icon(
                        Icons.verified,
                        size: 20 * scale,
                        color: AppColors.white,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8 * scale),
                // Email
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16 * scale,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                    SizedBox(width: 6 * scale),
                    Flexible(
                      child: Text(
                        account.email,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.normal,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16 * scale),
                // Role badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 8 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    account.roleName.toUpperCase(),
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsSection(double scale, dynamic account) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppWidgets.sectionHeader(
          context,
          title: AppStrings.accountDetailsTitle,
        ),
        AppWidgets.sectionContainer(
          context,
          padding: EdgeInsets.symmetric(vertical: 4 * scale),
          children: [
            if (account.username != null && account.username.isNotEmpty)
              AccountInfoRow(
                label: AppStrings.username,
                value: account.username,
              ),
            if (account.phone != null && account.phone.isNotEmpty)
              AccountInfoRow(
                label: AppStrings.accountPhoneNumber,
                value: account.phone,
              ),
            AccountInfoRow(
              label: AppStrings.accountStatus,
              value: account.isActive
                  ? AppStrings.accountStatusActive
                  : AppStrings.accountStatusLocked,
              valueColor: account.isActive ? AppColors.verified : AppColors.red,
            ),
            AccountInfoRow(
              label: 'Email',
              value: account.isEmailVerified == true
                  ? 'Đã xác thực'
                  : 'Chưa xác thực',
              valueColor: account.isEmailVerified == true
                  ? AppColors.verified
                  : AppColors.red,
            ),
            if (account.createdAt != null)
              AccountInfoRow(
                label: AppStrings.accountCreatedAt,
                value: '${account.createdAt.toLocal()}'.split('.').first,
              ),
            if (account.updatedAt != null)
              AccountInfoRow(
                label: AppStrings.accountUpdatedAt,
                value: '${account.updatedAt.toLocal()}'.split('.').first,
              ),
            if (account.ownerProfile != null)
              AccountInfoRow(
                label: 'Khách hàng phụ trách',
                value: account.ownerProfile!.fullName,
              ),
          ],
        ),
      ],
    );
  }
}

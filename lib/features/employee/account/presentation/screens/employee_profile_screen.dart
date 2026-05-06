import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../core/widgets/app_widgets.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../../core/widgets/avatar_widget.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../features/profile/presentation/widgets/account_info_row.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';
import '../../../../../core/routing/app_routes.dart';

class EmployeeProfileScreen extends StatefulWidget {
  const EmployeeProfileScreen({super.key});

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthLoadCurrentAccount());
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return EmployeeScaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
              AppRoutes.login,
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const Center(child: AppLoadingIndicator(color: AppColors.primary));
            }

            if (state is! AuthCurrentAccountLoaded) {
              return _buildEmptyState(scale);
            }

            final account = state.account;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSliverHeader(scale, account),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 20 * scale),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionHeader(scale, 'Thông tin cá nhân', Icons.person_outline_rounded),
                      _buildInfoCard(scale, [
                        _buildInfoRow(scale, Icons.badge_outlined, 'Họ và tên', account.ownerProfile?.fullName ?? account.displayName),
                        _buildInfoRow(scale, Icons.alternate_email_rounded, 'Tên đăng nhập', account.username),
                        _buildInfoRow(scale, Icons.cake_outlined, 'Ngày sinh', account.ownerProfile?.dateOfBirth != null ? DateFormat('dd/MM/yyyy').format(DateTime.parse(account.ownerProfile!.dateOfBirth.toString())) : 'Chưa cập nhật'),
                        _buildInfoRow(scale, Icons.phone_iphone_rounded, 'Số điện thoại', account.phone),
                        _buildInfoRow(scale, Icons.email_outlined, 'Email', account.email),
                        _buildInfoRow(scale, Icons.location_on_outlined, 'Địa chỉ', account.ownerProfile?.address ?? 'Chưa cập nhật', isLast: true),
                      ]),
                      SizedBox(height: 24 * scale),
                      _buildSectionHeader(scale, 'Chuyên môn & Công việc', Icons.work_outline_rounded),
                      _buildInfoCard(scale, [
                        _buildInfoRow(scale, Icons.workspace_premium_outlined, 'Chức danh', account.ownerProfile?.memberTypeName ?? 'Nhân viên'),
                        _buildInfoRow(scale, Icons.history_rounded, 'Kinh nghiệm', '${account.experience ?? 0} năm'),
                        _buildInfoRow(scale, Icons.check_circle_outline_rounded, 'Trạng thái', account.isActive ? 'Đang hoạt động' : 'Đã khóa', valueColor: account.isActive ? Colors.green : Colors.grey, isLast: true),
                      ]),
                      if (account.certificate != null && account.certificate!.isNotEmpty) ...[
                        SizedBox(height: 24 * scale),
                        _buildSectionHeader(scale, 'Chứng chỉ hành nghề', Icons.verified_user_outlined),
                        _buildCertificateCard(scale, account.certificate!),
                      ],
                      SizedBox(height: 40 * scale),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSliverHeader(double scale, dynamic account) {
    return SliverAppBar(
      expandedHeight: 280 * scale,
      pinned: true,
      stretch: true,
      backgroundColor: const Color(0xFF1A1A2E),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthLogout());
          },
        ),
        SizedBox(width: 8 * scale),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Dark Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
                ),
              ),
            ),
            // Decorative orbs
            Positioned(
              top: -50 * scale,
              right: -50 * scale,
              child: Container(
                width: 200 * scale,
                height: 200 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ),
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 60 * scale),
                // Avatar with glow
                Container(
                  padding: EdgeInsets.all(4 * scale),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 20 * scale,
                        spreadRadius: 5 * scale,
                      ),
                    ],
                  ),
                  child: AvatarWidget(
                    imageUrl: account.avatarUrl,
                    displayName: account.displayName,
                    size: 100 * scale,
                    backgroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Text(
                  account.ownerProfile?.fullName ?? account.displayName,
                  style: AppTextStyles.arimo(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    account.roleName.toUpperCase(),
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(double scale, String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * scale, bottom: 12 * scale),
      child: Row(
        children: [
          Icon(icon, size: 18 * scale, color: AppColors.primary),
          SizedBox(width: 8 * scale),
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(double scale, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15 * scale,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(double scale, IconData icon, String label, String value, {Color? valueColor, bool isLast = false}) {
    final color = AppColors.primary;
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(icon, size: 18 * scale, color: color),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  value,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(double scale, String imageUrl) {
    return Container(
      height: 200 * scale,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15 * scale,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20 * scale),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                ),
              ),
            ),
            Positioned(
              bottom: 16 * scale,
              left: 16 * scale,
              right: 16 * scale,
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 18),
                  SizedBox(width: 8 * scale),
                  Text(
                    'Chứng chỉ chuyên môn đã xác thực',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildEmptyState(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_rounded, size: 80 * scale, color: Colors.grey.shade300),
          SizedBox(height: 16 * scale),
          Text('Không tìm thấy thông tin', style: AppTextStyles.arimo(fontSize: 18 * scale, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

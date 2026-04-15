import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/utils/app_text_styles.dart';
import '../../../../../auth/data/models/current_account_model.dart';

class CustomerProfileAccountTab extends StatelessWidget {
  final Future<CurrentAccountModel> future;
  final double scale;
  final String Function(DateTime) fmtDate;

  const CustomerProfileAccountTab({
    super.key,
    required this.future,
    required this.scale,
    required this.fmtDate,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CurrentAccountModel>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Không tải được thông tin tài khoản:\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
            ),
          );
        }
        final acc = snapshot.data;
        if (acc == null) {
          return Center(
            child: Text(
              'Không có dữ liệu tài khoản.',
              style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
            ),
          );
        }

        final displayName = acc.ownerProfile?.fullName ?? acc.username;
        final status = acc.isActive ? 'Hoạt động' : 'Ngưng hoạt động';
        final isVerified = acc.isEmailVerified;

        return ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            _buildProfileHeaderSection(acc, displayName),
            SizedBox(height: 20 * scale),
            _buildInfoCard('Thông tin cá nhân', Icons.person_rounded, [
              _infoRow(Icons.email_outlined, 'Email', acc.email),
              _infoRow(Icons.phone_android_rounded, 'Số điện thoại', acc.phone),
              if (acc.ownerProfile?.gender != null)
                _infoRow(Icons.wc_rounded, 'Giới tính', acc.ownerProfile!.gender!),
              if (acc.ownerProfile?.dateOfBirth != null)
                _infoRow(Icons.cake_outlined, 'Ngày sinh', fmtDate(acc.ownerProfile!.dateOfBirth!)),
            ]),
            SizedBox(height: 16 * scale),
            _buildInfoCard('Chi tiết tài khoản', Icons.manage_accounts_rounded, [
              _infoRow(Icons.person_outline_rounded, 'Username', acc.username),
              _infoRow(Icons.badge_outlined, 'Vai trò', acc.roleName),
              _infoRow(Icons.info_outline_rounded, 'Trạng thái', status, valueColor: acc.isActive ? Colors.green : Colors.red),
              _infoRow(
                isVerified ? Icons.verified_user_outlined : Icons.gpp_maybe_outlined,
                'Xác minh email',
                isVerified ? 'Đã xác minh' : 'Chưa xác minh',
                valueColor: isVerified ? Colors.green : Colors.orange,
              ),
            ]),
            if (acc.ownerProfile?.address != null) ...[
              SizedBox(height: 16 * scale),
              _buildInfoCard('Địa chỉ liên lạc', Icons.location_on_rounded, [
                _infoRow(Icons.home_outlined, 'Địa chỉ hiện tại', acc.ownerProfile!.address!),
              ]),
            ],
            SizedBox(height: 24 * scale),
          ],
        );
      },
    );
  }

  Widget _buildProfileHeaderSection(CurrentAccountModel acc, String name) {
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80 * scale,
            height: 80 * scale,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 44 * scale),
          ),
          SizedBox(width: 20 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.tinos(
                    fontSize: 24 * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_rounded, size: 12 * scale, color: Colors.white),
                      SizedBox(width: 6 * scale),
                      Text(
                        acc.roleName.toUpperCase(),
                        style: AppTextStyles.arimo(
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData titleIcon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(titleIcon, size: 20 * scale, color: AppColors.primary),
              SizedBox(width: 8 * scale),
              Text(
                title,
                style: AppTextStyles.arimo(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * scale),
          const Divider(color: AppColors.borderLight),
          SizedBox(height: 8 * scale),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16 * scale, color: AppColors.textSecondary),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
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
          ),
        ],
      ),
    );
  }
}

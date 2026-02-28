// lib/features/employee/presentation/screens/staff_member_type_detail_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../family_profile/data/datasources/family_profile_remote_datasource.dart';
import '../../../family_profile/data/models/member_type_model.dart';
import '../widgets/employee_header_bar.dart';

/// Màn hình chi tiết loại thành viên cho staff
class StaffMemberTypeDetailScreen extends StatefulWidget {
  final int memberTypeId;

  const StaffMemberTypeDetailScreen({
    super.key,
    required this.memberTypeId,
  });

  @override
  State<StaffMemberTypeDetailScreen> createState() =>
      _StaffMemberTypeDetailScreenState();
}

class _StaffMemberTypeDetailScreenState
    extends State<StaffMemberTypeDetailScreen> {
  final _remote = FamilyProfileRemoteDataSourceImpl(dio: ApiClient.dio);
  late Future<MemberTypeModel> _future =
      _remote.getMemberTypeById(widget.memberTypeId);

  Future<void> _refresh() async {
    setState(() {
      _future = _remote.getMemberTypeById(widget.memberTypeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            EmployeeHeaderBar(
              title: 'Chi tiết loại thành viên',
              subtitle: 'Thông tin loại thành viên trong hệ thống',
            ),
            Expanded(
              child: FutureBuilder<MemberTypeModel>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: padding,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64 * scale,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16 * scale),
                            Text(
                              'Lỗi tải thông tin loại thành viên',
                              style: AppTextStyles.arimo(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8 * scale),
                            Text(
                              snapshot.error.toString(),
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24 * scale),
                            ElevatedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final memberType = snapshot.data;
                  if (memberType == null) {
                    return Center(
                      child: Text(
                        'Không tìm thấy loại thành viên',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      padding: padding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16 * scale),
                          // Header Card
                          Container(
                            padding: EdgeInsets.all(20 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16 * scale),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10 * scale,
                                  offset: Offset(0, 4 * scale),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(12 * scale),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12 * scale,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.group,
                                        size: 32 * scale,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 16 * scale),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Loại thành viên',
                                            style: AppTextStyles.arimo(
                                              fontSize: 12 * scale,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          SizedBox(height: 4 * scale),
                                          Text(
                                            memberType.name,
                                            style: AppTextStyles.arimo(
                                              fontSize: 20 * scale,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12 * scale,
                                        vertical: 6 * scale,
                                      ),
                                      decoration: BoxDecoration(
                                        color: memberType.isActive
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : Colors.red.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        memberType.isActive
                                            ? 'Đang hoạt động'
                                            : 'Đã vô hiệu hóa',
                                        style: AppTextStyles.arimo(
                                          fontSize: 11 * scale,
                                          fontWeight: FontWeight.w600,
                                          color: memberType.isActive
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                          // Details Card
                          Container(
                            padding: EdgeInsets.all(20 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16 * scale),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10 * scale,
                                  offset: Offset(0, 4 * scale),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thông tin chi tiết',
                                  style: AppTextStyles.arimo(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 16 * scale),
                                _InfoRow(
                                  icon: Icons.tag,
                                  label: 'ID',
                                  value: '#${memberType.id}',
                                  scale: scale,
                                ),
                                SizedBox(height: 12 * scale),
                                Divider(height: 1, color: AppColors.borderLight),
                                SizedBox(height: 12 * scale),
                                _InfoRow(
                                  icon: Icons.label,
                                  label: 'Tên loại thành viên',
                                  value: memberType.name,
                                  scale: scale,
                                ),
                                SizedBox(height: 12 * scale),
                                Divider(height: 1, color: AppColors.borderLight),
                                SizedBox(height: 12 * scale),
                                _InfoRow(
                                  icon: Icons.toggle_on,
                                  label: 'Trạng thái',
                                  value: memberType.isActive
                                      ? 'Đang hoạt động'
                                      : 'Đã vô hiệu hóa',
                                  valueColor: memberType.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  scale: scale,
                                ),
                                if (memberType.roleId != null) ...[
                                  SizedBox(height: 12 * scale),
                                  Divider(height: 1, color: AppColors.borderLight),
                                  SizedBox(height: 12 * scale),
                                  _InfoRow(
                                    icon: Icons.security,
                                    label: 'Role ID',
                                    value: memberType.roleId.toString(),
                                    scale: scale,
                                  ),
                                ],
                                if (memberType.roleName != null) ...[
                                  SizedBox(height: 12 * scale),
                                  Divider(height: 1, color: AppColors.borderLight),
                                  SizedBox(height: 12 * scale),
                                  _InfoRow(
                                    icon: Icons.badge,
                                    label: 'Tên Role',
                                    value: memberType.roleName!,
                                    scale: scale,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                          // Usage Info Card
                          Container(
                            padding: EdgeInsets.all(20 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 24 * scale,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 12 * scale),
                                Expanded(
                                  child: Text(
                                    'Loại thành viên này được sử dụng để phân loại các thành viên trong hồ sơ gia đình của khách hàng.',
                                    style: AppTextStyles.arimo(
                                      fontSize: 13 * scale,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24 * scale),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final double scale;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20 * scale,
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 12 * scale),
        Expanded(
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
              SizedBox(height: 4 * scale),
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
    );
  }
}

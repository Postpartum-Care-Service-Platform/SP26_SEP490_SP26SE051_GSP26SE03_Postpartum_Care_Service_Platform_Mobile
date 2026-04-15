import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/auth/data/models/current_account_model.dart';
import '../../../../../features/family_profile/domain/entities/family_profile_entity.dart';
import '../../../../../features/family_profile/presentation/widgets/family_member_card.dart';
import '../../../../../features/services/data/models/menu_model.dart';
import '../../../../../features/services/data/models/menu_record_model.dart';

class EmployeeCustomerFamilyProfilesTab extends StatelessWidget {
  final Future<List<FamilyProfileEntity>> future;
  final String customerId;
  final String customerName;
  final double scale;

  const EmployeeCustomerFamilyProfilesTab({
    super.key,
    required this.future,
    required this.customerId,
    required this.customerName,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FamilyProfileEntity>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _ErrorText(scale: scale, text: 'Tải dữ liệu thất bại: ${snapshot.error}');
        }

        final members = snapshot.data ?? const [];
        if (members.isEmpty) {
          return _EmptyText(scale: scale, text: 'Chưa có hồ sơ gia đình cho khách hàng này.');
        }

        final owner = members.where((m) => m.isOwner).toList();
        final others = members.where((m) => !m.isOwner).toList();
        final ordered = [...owner, ...others];

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30 * scale)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64 * scale,
                    height: 64 * scale,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFFFF9A8B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                        style: AppTextStyles.tinos(
                          fontSize: 28 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customerName,
                          style: AppTextStyles.tinos(
                            fontSize: 22 * scale,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          'Mã định danh: $customerId',
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20 * scale, 24 * scale, 16 * scale, 12 * scale),
              child: Row(
                children: [
                  Container(
                    width: 4 * scale,
                    height: 18 * scale,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2 * scale),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Text(
                    'Thành viên (${members.length})',
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ...ordered.map((m) => FamilyMemberCard(member: m, showActions: false, onTap: null)),
            SizedBox(height: 32 * scale),
          ],
        );
      },
    );
  }
}

class EmployeeCustomerMenuRecordsTab extends StatelessWidget {
  final double scale;
  final Future<List<MenuRecordModel>> future;
  final Widget filterBar;
  final void Function(MenuRecordModel record) onEdit;
  final void Function(MenuRecordModel record) onDelete;
  final String Function(DateTime value) fmtDate;
  final Map<int, MenuModel>? menuDetails;

  const EmployeeCustomerMenuRecordsTab({
    super.key,
    required this.scale,
    required this.future,
    required this.filterBar,
    required this.onEdit,
    required this.onDelete,
    required this.fmtDate,
    this.menuDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filterBar,
        Expanded(
          child: FutureBuilder<List<MenuRecordModel>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (snapshot.hasError) {
                return _ErrorText(
                  scale: scale,
                  text: 'Không tải được thực đơn: ${snapshot.error}',
                );
              }

              final records = snapshot.data ?? const [];
              if (records.isEmpty) {
                return _EmptyText(
                  scale: scale,
                  text: 'Chưa có thực đơn nào được thiết lập.',
                );
              }

              records.sort((a, b) => b.date.compareTo(a.date));

              return ListView.separated(
                padding: EdgeInsets.fromLTRB(20 * scale, 10 * scale, 20 * scale, 40 * scale),
                itemCount: records.length,
                separatorBuilder: (_, __) => SizedBox(height: 20 * scale),
                itemBuilder: (context, index) {
                  final r = records[index];
                  final details = menuDetails?[r.menuId];
                  final foods = details?.foods ?? [];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12 * scale),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(16 * scale),
                                    ),
                                    child: Icon(
                                      Icons.restaurant_rounded,
                                      color: AppColors.primary,
                                      size: 22 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 14 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          r.name,
                                          style: AppTextStyles.arimo(
                                            fontSize: 16 * scale,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                            height: 1.2,
                                          ),
                                        ),
                                        SizedBox(height: 4 * scale),
                                        Text(
                                          'Menu #${r.menuId} • Loại: ${details?.menuTypeName ?? 'N/A'}',
                                          style: AppTextStyles.arimo(
                                            fontSize: 11 * scale,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _iconButton(
                                        icon: Icons.edit_note_rounded,
                                        color: AppColors.primary,
                                        onPressed: () => onEdit(r),
                                      ),
                                      SizedBox(width: 8 * scale),
                                      _iconButton(
                                        icon: Icons.delete_outline_rounded,
                                        color: Colors.redAccent,
                                        onPressed: () => onDelete(r),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (foods.isNotEmpty) ...[
                                SizedBox(height: 16 * scale),
                                Text(
                                  'Món ăn trong thực đơn:',
                                  style: AppTextStyles.arimo(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 10 * scale),
                                SizedBox(
                                  height: 80 * scale,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: foods.length,
                                    separatorBuilder: (_, __) => SizedBox(width: 12 * scale),
                                    itemBuilder: (context, fIdx) {
                                      final food = foods[fIdx];
                                      return Container(
                                        width: 180 * scale,
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(12 * scale),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.horizontal(left: Radius.circular(12 * scale)),
                                              child: food.imageUrl != null
                                                  ? Image.network(
                                                      food.imageUrl!,
                                                      width: 60 * scale,
                                                      height: 80 * scale,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, __, ___) => _noImage(60 * scale),
                                                    )
                                                  : _noImage(60 * scale),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                                                child: Text(
                                                  food.name,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: AppTextStyles.arimo(
                                                    fontSize: 11 * scale,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                              SizedBox(height: 16 * scale),
                              Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(14 * scale),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.event_available_rounded, size: 16 * scale, color: AppColors.primary),
                                    SizedBox(width: 10 * scale),
                                    Text(
                                      'Ngày phục vụ',
                                      style: AppTextStyles.arimo(
                                        fontSize: 12 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      fmtDate(r.date),
                                      style: AppTextStyles.arimo(
                                        fontSize: 14 * scale,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
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
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _iconButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20 * scale),
      ),
    );
  }

  Widget _noImage(double size) {
    return Container(
      width: size,
      color: Colors.grey[200],
      child: Icon(Icons.image_not_supported_outlined, size: 20 * scale, color: Colors.grey),
    );
  }
}

class EmployeeCustomerMapTab extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final double scale;
  final String errorPrefix;
  final String emptyText;
  final String Function(Map<String, dynamic>) titleBuilder;
  final String Function(Map<String, dynamic>) subtitleBuilder;
  final Widget? emptyState;

  const EmployeeCustomerMapTab({
    super.key,
    required this.future,
    required this.scale,
    required this.errorPrefix,
    required this.emptyText,
    required this.titleBuilder,
    required this.subtitleBuilder,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _ErrorText(scale: scale, text: '$errorPrefix: ${snapshot.error}');
        }

        final records = snapshot.data ?? const [];
        if (records.isEmpty) {
          return emptyState ?? _EmptyText(scale: scale, text: emptyText);
        }

        return ListView.separated(
          padding: EdgeInsets.all(16 * scale),
          itemCount: records.length,
          separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
          itemBuilder: (context, index) {
            final item = records[index];
            return Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleBuilder(item),
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    subtitleBuilder(item),
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class EmployeeCustomerAccountInfoTab extends StatelessWidget {
  final Future<CurrentAccountModel> future;
  final double scale;
  final String Function(DateTime value) fmtDate;

  const EmployeeCustomerAccountInfoTab({
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
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _ErrorText(
            scale: scale,
            text: 'Không tải được thông tin tài khoản: ${snapshot.error}',
          );
        }

        final acc = snapshot.data;
        if (acc == null) {
          return _EmptyText(scale: scale, text: 'Không có dữ liệu tài khoản.');
        }

        final displayName = acc.ownerProfile?.fullName ?? acc.username;
        final status = acc.isActive ? 'Hoạt động' : 'Ngưng hoạt động';

        return ListView(
          padding: EdgeInsets.all(20 * scale),
          children: [
            Container(
              padding: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24 * scale),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 70 * scale,
                    height: 70 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 40 * scale),
                  ),
                  SizedBox(width: 20 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: AppTextStyles.tinos(
                            fontSize: 22 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8 * scale),
                          ),
                          child: Text(
                            acc.roleName.toUpperCase(),
                            style: AppTextStyles.arimo(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24 * scale),
            _infoSectionTitle('Thông tin cá nhân', Icons.contact_page_rounded),
            _InfoTile(scale: scale, label: 'Email', value: acc.email, icon: Icons.alternate_email_rounded),
            _InfoTile(scale: scale, label: 'Số điện thoại', value: acc.phone, icon: Icons.phone_iphone_rounded),
            if (acc.ownerProfile?.gender != null)
              _InfoTile(scale: scale, label: 'Giới tính', value: acc.ownerProfile!.gender!, icon: Icons.wc_rounded),
            if (acc.ownerProfile?.dateOfBirth != null)
              _InfoTile(
                scale: scale,
                label: 'Ngày sinh',
                value: fmtDate(acc.ownerProfile!.dateOfBirth!),
                icon: Icons.cake_rounded,
              ),
            SizedBox(height: 16 * scale),
            _infoSectionTitle('Thông tin tài khoản', Icons.manage_accounts_rounded),
            _InfoTile(scale: scale, label: 'Username', value: acc.username, icon: Icons.face_rounded),
            _InfoTile(scale: scale, label: 'Trạng thái', value: status, icon: Icons.info_outline_rounded, valueColor: acc.isActive ? Colors.green : Colors.red),
            _InfoTile(
              scale: scale,
              label: 'Xác minh email',
              value: acc.isEmailVerified ? 'Đã xác minh' : 'Chưa xác minh',
              icon: Icons.verified_user_rounded,
              valueColor: acc.isEmailVerified ? Colors.green : Colors.orange,
            ),
            if (acc.ownerProfile?.address != null)
              _InfoTile(scale: scale, label: 'Địa chỉ', value: acc.ownerProfile!.address!, icon: Icons.location_on_rounded),
            SizedBox(height: 24 * scale),
          ],
        );
      },
    );
  }

  Widget _infoSectionTitle(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * scale, bottom: 12 * scale),
      child: Row(
        children: [
          Icon(icon, size: 18 * scale, color: AppColors.primary),
          SizedBox(width: 10 * scale),
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
    );
  }
}

class _InfoTile extends StatelessWidget {
  final double scale;
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const _InfoTile({
    required this.scale,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Icon(icon, size: 20 * scale, color: AppColors.textSecondary),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  value,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
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
}

class _ErrorText extends StatelessWidget {
  final double scale;
  final String text;

  const _ErrorText({required this.scale, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  final double scale;
  final String text;

  const _EmptyText({required this.scale, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.arimo(
          fontSize: 13 * scale,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

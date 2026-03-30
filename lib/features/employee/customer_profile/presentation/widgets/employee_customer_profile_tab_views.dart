import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/auth/data/models/current_account_model.dart';
import '../../../../../features/family_profile/domain/entities/family_profile_entity.dart';
import '../../../../../features/family_profile/presentation/widgets/family_member_card.dart';
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
          padding: EdgeInsets.symmetric(vertical: 8 * scale),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16 * scale, 10 * scale, 16 * scale, 6 * scale),
              child: Text(
                customerName,
                style: AppTextStyles.tinos(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16 * scale, 0, 16 * scale, 10 * scale),
              child: Text(
                'CustomerId: $customerId',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            for (final m in ordered)
              FamilyMemberCard(member: m, showActions: false, onTap: null),
            SizedBox(height: 18 * scale),
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

  const EmployeeCustomerMenuRecordsTab({
    super.key,
    required this.scale,
    required this.future,
    required this.filterBar,
    required this.onEdit,
    required this.onDelete,
    required this.fmtDate,
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
                  text: 'Không tải được Menu Record: ${snapshot.error}',
                );
              }

              final records = snapshot.data ?? const [];
              if (records.isEmpty) {
                return _EmptyText(
                  scale: scale,
                  text: 'Không có Menu Record theo bộ lọc hiện tại.',
                );
              }

              records.sort((a, b) => b.date.compareTo(a.date));

              return ListView.separated(
                padding: EdgeInsets.all(16 * scale),
                itemCount: records.length,
                separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
                itemBuilder: (context, index) {
                  final r = records[index];
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
                          r.name,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 6 * scale),
                        Text(
                          'Ngày: ${fmtDate(r.date)}',
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'MenuId: ${r.menuId} • AccountId: ${r.accountId}',
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Sửa',
                              onPressed: () => onEdit(r),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                            IconButton(
                              tooltip: 'Xóa',
                              onPressed: () => onDelete(r),
                              icon: const Icon(Icons.delete_outline_rounded),
                            ),
                          ],
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
          padding: EdgeInsets.all(16 * scale),
          children: [
            _InfoTile(scale: scale, label: 'Họ tên', value: displayName),
            _InfoTile(scale: scale, label: 'Email', value: acc.email),
            _InfoTile(scale: scale, label: 'Số điện thoại', value: acc.phone),
            _InfoTile(scale: scale, label: 'Username', value: acc.username),
            _InfoTile(scale: scale, label: 'Vai trò', value: acc.roleName),
            _InfoTile(scale: scale, label: 'Trạng thái', value: status),
            _InfoTile(
              scale: scale,
              label: 'Đã xác minh email',
              value: acc.isEmailVerified ? 'Có' : 'Chưa',
            ),
            if (acc.ownerProfile?.address != null)
              _InfoTile(scale: scale, label: 'Địa chỉ', value: acc.ownerProfile!.address!),
            if (acc.ownerProfile?.gender != null)
              _InfoTile(scale: scale, label: 'Giới tính', value: acc.ownerProfile!.gender!),
            if (acc.ownerProfile?.dateOfBirth != null)
              _InfoTile(
                scale: scale,
                label: 'Ngày sinh',
                value: fmtDate(acc.ownerProfile!.dateOfBirth!),
              ),
          ],
        );
      },
    );
  }
}

class TransactionEmptyState extends StatelessWidget {
  final double scale;
  final VoidCallback onCreateTransaction;

  const TransactionEmptyState({
    super.key,
    required this.scale,
    required this.onCreateTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72 * scale,
              height: 72 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 34 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 14 * scale),
            Text(
              'Chưa có giao dịch',
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              'Khách hàng này chưa phát sinh giao dịch nào.',
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 12.5 * scale,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 14 * scale),
            FilledButton.icon(
              onPressed: onCreateTransaction,
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('Tạo giao dịch mới'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final double scale;
  final String label;
  final String value;

  const _InfoTile({
    required this.scale,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10 * scale),
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
              color: AppColors.textPrimary,
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

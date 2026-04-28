import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_colors.dart';
import '../../../../../../../core/utils/app_text_styles.dart';
import '../../../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../../operations/presentation/screens/staff_health_care_flow_screen.dart';

class CustomerProfileFamilyTab extends StatelessWidget {
  final Future<List<FamilyProfileEntity>> future;
  final String customerId;
  final String customerName;
  final double scale;

  const CustomerProfileFamilyTab({
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
          return _buildErrorState(snapshot.error.toString());
        }
        final members = snapshot.data ?? const [];
        if (members.isEmpty) {
          return _buildEmptyState();
        }

        final owner = members.where((m) => m.isOwner).toList();
        final others = members.where((m) => !m.isOwner).toList();
        final ordered = [...owner, ...others];

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeaderSection(),
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
                  SizedBox(width: 10 * scale),
                  Text(
                    'Thành viên gia đình (${members.length})',
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ...ordered.map((m) => _FamilyMemberItem(member: m, scale: scale)),
            SizedBox(height: 32 * scale),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24 * scale, 12 * scale, 24 * scale, 30 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32 * scale)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 84 * scale,
            height: 84 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF9A8B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                style: AppTextStyles.tinos(
                  fontSize: 36 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 20 * scale),
          Text(
            customerName,
            style: AppTextStyles.tinos(
              fontSize: 24 * scale,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_off_rounded, size: 64 * scale, color: AppColors.textSecondary.withValues(alpha: 0.2)),
          SizedBox(height: 16 * scale),
          Text(
            'Chưa có hồ sơ gia đình.',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 48),
            SizedBox(height: 16 * scale),
            Text(
              'Tải hồ sơ gia đình thất bại:\n$error',
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyMemberItem extends StatelessWidget {
  final FamilyProfileEntity member;
  final double scale;

  const _FamilyMemberItem({required this.member, required this.scale});

  String _translateMemberType(String value) {
    final normalized = value.trim().toLowerCase();
    switch (normalized) {
      case 'head of family':
        return 'Người đại diện';
      case 'mom':
        return 'Người mẹ';
      case 'baby':
        return 'Bé sơ sinh';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = member.isOwner;
    final typeName = _translateMemberType(member.memberTypeName ?? '');
    final isBaby = member.memberTypeName?.toLowerCase().contains('baby') ?? false;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16 * scale),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4 * scale,
                color: isOwner
                    ? AppColors.primary
                    : isBaby
                        ? const Color(0xFFF472B6) // Pink
                        : const Color(0xFF60A5FA), // Blue
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16 * scale),
                  child: Row(
                    children: [
                      Container(
                        width: 52 * scale,
                        height: 52 * scale,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: member.avatarUrl != null
                            ? ClipOval(child: Image.network(member.avatarUrl!, fit: BoxFit.cover))
                            : Icon(
                                isBaby ? Icons.child_care_rounded : Icons.person_rounded,
                                color: AppColors.textSecondary,
                                size: 28 * scale,
                              ),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    member.fullName,
                                    style: AppTextStyles.arimo(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isOwner)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6 * scale),
                                    ),
                                    child: Text(
                                      'Chủ hộ',
                                      style: AppTextStyles.arimo(
                                        fontSize: 10 * scale,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              typeName,
                              style: AppTextStyles.arimo(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w600,
                                color: isBaby ? const Color(0xFFDB2777) : AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 12 * scale),
                            if (!(member.memberTypeName?.toLowerCase().contains('head of family') ?? false) && 
                                !(member.memberTypeName?.toLowerCase().contains('chủ hộ') ?? false))
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    StaffHealthCareFlowScreen.showAsBottomSheet(
                                      context,
                                      familyProfileId: member.id,
                                      familyMemberName: member.fullName,
                                      memberType: member.memberTypeName,
                                    );
                                  },
                                  icon: Icon(Icons.medical_services_outlined, size: 16 * scale),
                                  label: Text(
                                    'Ghi nhận sức khỏe',
                                    style: AppTextStyles.arimo(
                                      fontSize: 12 * scale,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 8 * scale),
                                    side: const BorderSide(color: AppColors.primary),
                                    foregroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10 * scale),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

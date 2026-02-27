import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../family_profile/presentation/widgets/family_member_card.dart';

class EmployeeCustomerFamilyProfilesScreen extends StatefulWidget {
  final String customerId;
  final String customerName;

  const EmployeeCustomerFamilyProfilesScreen({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<EmployeeCustomerFamilyProfilesScreen> createState() =>
      _EmployeeCustomerFamilyProfilesScreenState();
}

class _EmployeeCustomerFamilyProfilesScreenState
    extends State<EmployeeCustomerFamilyProfilesScreen> {
  late Future<List<FamilyProfileEntity>> _future =
      _load(widget.customerId);

  Future<List<FamilyProfileEntity>> _load(String customerId) async {
    return await InjectionContainer.familyProfileRepository
        .getFamilyProfilesByCustomerId(customerId);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Hồ sơ gia đình',
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () {
              setState(() => _future = _load(widget.customerId));
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<FamilyProfileEntity>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Text(
                  'Tải dữ liệu thất bại: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final members = snapshot.data ?? const [];
          if (members.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Text(
                  'Chưa có hồ sơ gia đình cho khách hàng này.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          final owner = members.where((m) => m.isOwner).toList();
          final others = members.where((m) => !m.isOwner).toList();
          final ordered = [...owner, ...others];

          return ListView(
            padding: EdgeInsets.symmetric(vertical: 8 * scale),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  10 * scale,
                  16 * scale,
                  6 * scale,
                ),
                child: Text(
                  widget.customerName,
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
                  'CustomerId: ${widget.customerId}',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              for (final m in ordered)
                FamilyMemberCard(
                  member: m,
                  showActions: false, // staff chỉ xem
                  onTap: null,
                ),
              SizedBox(height: 18 * scale),
            ],
          );
        },
      ),
    );
  }
}


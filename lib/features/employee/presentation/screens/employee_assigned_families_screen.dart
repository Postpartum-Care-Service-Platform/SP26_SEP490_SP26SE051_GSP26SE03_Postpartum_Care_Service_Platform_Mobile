import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../domain/entities/appointment_entity.dart';
import 'employee_customer_family_profiles_screen.dart';
import '../widgets/employee_scaffold.dart';

class EmployeeAssignedFamiliesScreen extends StatefulWidget {
  const EmployeeAssignedFamiliesScreen({super.key});

  @override
  State<EmployeeAssignedFamiliesScreen> createState() =>
      _EmployeeAssignedFamiliesScreenState();
}

class _EmployeeAssignedFamiliesScreenState
    extends State<EmployeeAssignedFamiliesScreen> {
  late final Future<List<_AssignedCustomer>> _futureCustomers =
      _loadAssignedCustomers();

  Future<List<_AssignedCustomer>> _loadAssignedCustomers() async {
    final appointments = await InjectionContainer.appointmentEmployeeRepository
        .getMyAssignedAppointments();

    final byCustomer = <String, List<AppointmentEntity>>{};
    for (final a in appointments) {
      final id = a.customerId.trim();
      if (id.isEmpty) continue;
      byCustomer.putIfAbsent(id, () => []).add(a);
    }

    final result = <_AssignedCustomer>[];
    for (final entry in byCustomer.entries) {
      final customerId = entry.key;
      final items = entry.value;
      final info = items.first.customer;
      final email = info?.email ?? '';
      final displayName = (info?.username?.trim().isNotEmpty == true)
          ? info!.username!.trim()
          : (email.isNotEmpty ? email : customerId);

      result.add(
        _AssignedCustomer(
          customerId: customerId,
          displayName: displayName,
          email: email,
          phone: info?.phone,
          appointmentsCount: items.length,
        ),
      );
    }

    result.sort((a, b) => a.displayName.compareTo(b.displayName));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return EmployeeScaffold(
      appBar: const AppAppBar(
        title: 'Gia đình được phân công',
        centerTitle: true,
      ),
      body: FutureBuilder<List<_AssignedCustomer>>(
        future: _futureCustomers,
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

          final customers = snapshot.data ?? const [];
          if (customers.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24 * scale),
                child: Text(
                  'Bạn chưa được phân công hộ gia đình nào.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 12 * scale,
            ),
            itemCount: customers.length,
            separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
            itemBuilder: (context, index) {
              final c = customers[index];
              return _CustomerCard(
                customer: c,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EmployeeCustomerFamilyProfilesScreen(
                        customerId: c.customerId,
                        customerName: c.displayName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _AssignedCustomer {
  final String customerId;
  final String displayName;
  final String email;
  final String? phone;
  final int appointmentsCount;

  const _AssignedCustomer({
    required this.customerId,
    required this.displayName,
    required this.email,
    required this.phone,
    required this.appointmentsCount,
  });
}

class _CustomerCard extends StatelessWidget {
  final _AssignedCustomer customer;
  final VoidCallback onTap;

  const _CustomerCard({required this.customer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16 * scale),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        child: Padding(
          padding: EdgeInsets.all(14 * scale),
          child: Row(
            children: [
              Container(
                width: 44 * scale,
                height: 44 * scale,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.family_restroom_rounded,
                  color: AppColors.primary,
                  size: 22 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      customer.phone?.isNotEmpty == true
                          ? '${customer.email} • ${customer.phone}'
                          : customer.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      'Lịch hẹn được giao: ${customer.appointmentsCount}',
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 26 * scale,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/features/employee/presentation/screens/employee_meal_plan_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/appointment_entity.dart';
import '../widgets/employee_scaffold.dart';
import 'employee_customer_family_profiles_screen.dart';

class EmployeeMealPlanScreen extends StatefulWidget {
  const EmployeeMealPlanScreen({super.key});

  @override
  State<EmployeeMealPlanScreen> createState() => _EmployeeMealPlanScreenState();
}

class _EmployeeMealPlanScreenState extends State<EmployeeMealPlanScreen> {
  late final Future<List<_AssignedCustomer>> _futureCustomers =
      _loadAssignedCustomers();
  String? _selectedCustomerId;

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
        ),
      );
    }

    result.sort((a, b) => a.displayName.compareTo(b.displayName));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return EmployeeScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Suất ăn / Menu Record',
          style: AppTextStyles.arimo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<_AssignedCustomer>>(
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
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Không tải được danh sách gia đình: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final customers = snapshot.data ?? const [];
            if (customers.isEmpty) {
              return const Center(
                child: Text('Bạn chưa được phân công gia đình nào để quản lý suất ăn.'),
              );
            }

            _selectedCustomerId ??= customers.first.customerId;
            final selected = customers.firstWhere(
              (e) => e.customerId == _selectedCustomerId,
              orElse: () => customers.first,
            );

            return SingleChildScrollView(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  const _HeaderCard(
                    title: 'Quản lý suất ăn',
                    subtitle:
                        'Chọn gia đình được phân công để vào màn profile và thao tác tab Menu Record',
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Chọn gia đình',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: selected.customerId,
                          items: [
                            for (final c in customers)
                              DropdownMenuItem<String>(
                                value: c.customerId,
                                child: Text(
                                  '${c.displayName} • ${c.email}',
                                  style: AppTextStyles.arimo(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _selectedCustomerId = v);
                          },
                          decoration: InputDecoration(
                            hintText: '— Chọn gia đình —',
                            hintStyle: AppTextStyles.arimo(
                              color: AppColors.textSecondary,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.borderLight),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.borderLight),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EmployeeCustomerFamilyProfilesScreen(
                                  customerId: selected.customerId,
                                  customerName: selected.displayName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.restaurant_menu_rounded),
                          label: const Text('Mở màn Profile khách hàng'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AssignedCustomer {
  final String customerId;
  final String displayName;
  final String email;

  const _AssignedCustomer({
    required this.customerId,
    required this.displayName,
    required this.email,
  });
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

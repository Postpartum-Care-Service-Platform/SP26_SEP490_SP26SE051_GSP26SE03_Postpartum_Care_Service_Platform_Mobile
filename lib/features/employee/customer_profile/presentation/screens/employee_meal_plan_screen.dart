// lib/features/employee/presentation/screens/employee_meal_plan_screen.dart
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';  
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';
import '../../../../../features/services/data/datasources/staff_schedule_remote_datasource.dart';
import '../../../../../features/services/data/models/menu_record_model.dart';
import '../../../../../features/services/data/models/menu_model.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../data/datasources/employee_customer_profile_remote_datasource.dart';

class EmployeeMealPlanScreen extends StatefulWidget {
  const EmployeeMealPlanScreen({super.key});

  @override
  State<EmployeeMealPlanScreen> createState() => _EmployeeMealPlanScreenState();
}

class _EmployeeMealPlanScreenState extends State<EmployeeMealPlanScreen> {
  late final Future<List<_AssignedCustomer>> _futureCustomers =
      _loadAssignedCustomers();
  final _profileDs = EmployeeCustomerProfileRemoteDataSource();
  
  String? _selectedCustomerId;
  Future<List<MenuRecordModel>>? _menuRecordsFuture;

  Future<List<_AssignedCustomer>> _loadAssignedCustomers() async {
    final result = <_AssignedCustomer>[];
    final customerIds = <String>{};

    // 1. Try from appointments
    try {
      final appointments = await InjectionContainer.appointmentEmployeeRepository
          .getMyAssignedAppointments();

      for (final a in appointments) {
        final id = a.customerId.trim();
        if (id.isEmpty || customerIds.contains(id)) continue;

        final info = a.customer;
        final email = info?.email ?? '';
        final displayName = (info?.username?.trim().isNotEmpty == true)
            ? info!.username!.trim()
            : (email.isNotEmpty ? email : id);

        result.add(
          _AssignedCustomer(
            customerId: id,
            displayName: displayName,
            email: email,
          ),
        );
        customerIds.add(id);
      }
    } catch (e) {
      debugPrint('Error loading appointments: $e');
    }

    // 2. Try from staff schedule (always merge to find more families)
    try {
      final staffScheduleDs = StaffScheduleRemoteDataSourceImpl();
      final today = DateTime.now();
      // Look for any assignment in 30 days around today
      final from = today.subtract(const Duration(days: 15)).toIso8601String().split('T')[0];
      final to = today.add(const Duration(days: 15)).toIso8601String().split('T')[0];

      final schedules =
          await staffScheduleDs.getMySchedulesByDateRange(from: from, to: to);

      for (final s in schedules) {
        final fs = s.familySchedule;
        if (fs == null) continue;

        final id = fs.customerId.trim();
        if (id.isEmpty || customerIds.contains(id)) continue;

        result.add(
          _AssignedCustomer(
            customerId: id,
            displayName: fs.customerName?.trim().isNotEmpty == true
                ? fs.customerName!.trim()
                : 'Khách hàng #$id',
            email: '',
          ),
        );
        customerIds.add(id);
      }
    } catch (e) {
      debugPrint('Error loading staff schedules: $e');
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
          'Suất ăn theo gia đình',
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
                                  '${c.displayName} ${c.email.isNotEmpty ? "• ${c.email}" : ""}',
                                  style: AppTextStyles.arimo(),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              _selectedCustomerId = v;
                              _menuRecordsFuture = _loadMenuRecords(v);
                            });
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuRecordsSection(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<List<MenuRecordModel>> _loadMenuRecords(String customerId) {
    return _profileDs.getMenuRecordsByCustomer(customerId);
  }

  Widget _buildMenuRecordsSection(BuildContext context) {
    if (_selectedCustomerId == null) return const SizedBox.shrink();
    _menuRecordsFuture ??= _loadMenuRecords(_selectedCustomerId!);
    final scale = AppResponsive.scaleFactor(context);

    return FutureBuilder<List<MenuRecordModel>>(
      future: _menuRecordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Lỗi tải danh sách suất ăn: ${snapshot.error}'),
            ),
          );
        }

        final records = snapshot.data ?? const [];
        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(40 * scale),
              child: Column(
                children: [
                  Icon(Icons.restaurant_menu_outlined, 
                    size: 64 * scale, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  SizedBox(height: 16 * scale),
                  Text(
                    'Gia đình này chưa có bản ghi suất ăn nào.',
                    style: AppTextStyles.arimo(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        // Group by date
        final groupedByDate = <DateTime, List<MenuRecordModel>>{};
        for (final r in records) {
          final dateOnly = DateTime(r.date.year, r.date.month, r.date.day);
          groupedByDate.putIfAbsent(dateOnly, () => []).add(r);
        }
        
        final sortedDates = groupedByDate.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedDates.length,
          itemBuilder: (context, dateIndex) {
            final date = sortedDates[dateIndex];
            final dateRecords = groupedByDate[date]!;
            dateRecords.sort((a, b) => a.name.compareTo(b.name));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: 12 * scale),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, 
                        size: 14 * scale, color: AppColors.textPrimary),
                      SizedBox(width: 8 * scale),
                      Text(
                        _formatDate(date),
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Divider(color: AppColors.borderLight)),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dateRecords.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                  itemBuilder: (context, index) {
                    final r = dateRecords[index];
                    final isBreakfast = r.name.contains('sáng');
                    final isLunch = r.name.contains('trưa');
                    final isDinner = r.name.contains('tối');

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: InkWell(
                        onTap: () => _viewMenuDetails(context, r.menuId),
                        borderRadius: BorderRadius.circular(16 * scale),
                        child: Padding(
                          padding: EdgeInsets.all(16 * scale),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10 * scale),
                                decoration: BoxDecoration(
                                  color: (isBreakfast ? Colors.orange : (isLunch ? Colors.blue : (isDinner ? Colors.indigo : AppColors.primary))).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isBreakfast ? Icons.wb_sunny_rounded : (isLunch ? Icons.light_mode_rounded : (isDinner ? Icons.nightlight_round : Icons.restaurant_rounded)),
                                  color: isBreakfast ? Colors.orange : (isLunch ? Colors.blue : (isDinner ? Colors.indigo : AppColors.primary)),
                                  size: 24 * scale,
                                ),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.name,
                                      style: AppTextStyles.arimo(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      'Menu ID: ${r.menuId}',
                                      style: AppTextStyles.arimo(
                                        fontSize: 13 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20 * scale),
                                ),
                                child: Text(
                                  'Chi tiết',
                                  style: AppTextStyles.arimo(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 8 * scale),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) return 'Hôm nay';
    if (date == yesterday) return 'Hôm qua';
    
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _viewMenuDetails(BuildContext context, int menuId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final menu = await _profileDs.getMenuById(menuId);
      if (mounted) {
        Navigator.pop(context); // hide loader
        _showMenuDetailsDialog(context, menu);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // hide loader
        AppToast.showError(context, message: 'Không thể tải chi tiết thực đơn: $e');
      }
    }
  }

  void _showMenuDetailsDialog(BuildContext context, MenuModel menu) {
    final scale = AppResponsive.scaleFactor(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12 * scale),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16 * scale),
                          ),
                          child: Icon(Icons.restaurant_rounded, 
                            color: AppColors.primary, size: 28 * scale),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu.menuName,
                                style: AppTextStyles.arimo(
                                  fontSize: 22 * scale,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                menu.menuTypeName,
                                style: AppTextStyles.arimo(
                                  fontSize: 14 * scale,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (menu.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Text(
                          menu.description!,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textSecondary,
                          ).copyWith(height: 1.5),
                        ),
                      ),
                    ],
                    SizedBox(height: 24 * scale),
                    Row(
                      children: [
                        Text(
                          'Danh sách món ăn',
                          style: AppTextStyles.arimo(
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${menu.foods.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (menu.foods.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32 * scale),
                          child: Text('Chưa có món ăn nào trong thực đơn này.',
                            style: AppTextStyles.arimo(color: AppColors.textSecondary)),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16 * scale,
                          mainAxisSpacing: 16 * scale,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: menu.foods.length,
                        itemBuilder: (context, index) {
                          final food = menu.foods[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(color: AppColors.borderLight),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16 * scale)),
                                    child: food.imageUrl != null && food.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            food.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: AppColors.borderLight,
                                              child: Icon(Icons.restaurant, color: AppColors.textSecondary, size: 32 * scale),
                                            ),
                                          )
                                        : Container(
                                            color: AppColors.borderLight,
                                            child: Icon(Icons.restaurant, color: AppColors.textSecondary, size: 32 * scale),
                                          ),
                                  ),
                                ),
                                Padding(
                                    padding: EdgeInsets.all(12 * scale),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          food.name,
                                          style: AppTextStyles.arimo(
                                            fontSize: 14 * scale,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (food.type.isNotEmpty) ...[
                                          SizedBox(height: 4 * scale),
                                          Text(
                                            food.type,
                                            style: AppTextStyles.arimo(
                                              fontSize: 12 * scale,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 32 * scale),
                  ],
                ),
              ),
            ],
          ),
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

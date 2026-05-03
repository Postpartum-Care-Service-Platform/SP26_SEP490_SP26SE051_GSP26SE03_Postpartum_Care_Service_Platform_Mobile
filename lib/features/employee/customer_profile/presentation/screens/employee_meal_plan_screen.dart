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
import '../../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../data/datasources/employee_customer_profile_remote_datasource.dart';

class EmployeeMealPlanScreen extends StatefulWidget {
  const EmployeeMealPlanScreen({super.key});

  @override
  State<EmployeeMealPlanScreen> createState() => _EmployeeMealPlanScreenState();
}

enum _MenuFilterMode { all, date, range }

class _EmployeeMealPlanScreenState extends State<EmployeeMealPlanScreen> {
  late final Future<List<_AssignedCustomer>> _futureCustomers =
      _loadAssignedCustomers();
  final _profileDs = EmployeeCustomerProfileRemoteDataSource();
  
  String? _selectedCustomerId;
  Future<List<MenuRecordModel>>? _menuRecordsFuture;

  _MenuFilterMode _menuFilterMode = _MenuFilterMode.all;
  DateTime _selectedDate = DateTime.now();
  DateTime? _rangeFrom;
  DateTime? _rangeTo;


  Future<List<_AssignedCustomer>> _loadAssignedCustomers() async {
    final result = <_AssignedCustomer>[];
    final customerIds = <String>{};

    // 1. Collect unique Customer IDs from multiple sources
    
    // Source A: Appointments
    try {
      final appointments = await InjectionContainer.appointmentEmployeeRepository
          .getMyAssignedAppointments();
      for (final a in appointments) {
        if (a.customerId.isNotEmpty) customerIds.add(a.customerId);
      }
    } catch (e) {
      debugPrint('Error loading appointments IDs: $e');
    }

    // Source B: Staff Schedules
    try {
      final staffScheduleDs = StaffScheduleRemoteDataSourceImpl();
      final today = DateTime.now();
      final from = today.subtract(const Duration(days: 15)).toIso8601String().split('T')[0];
      final to = today.add(const Duration(days: 15)).toIso8601String().split('T')[0];

      final schedules = await staffScheduleDs.getMySchedulesByDateRange(from: from, to: to);
      for (final s in schedules) {
        if (s.familySchedule != null) {
          customerIds.add(s.familySchedule!.customerId);
        }
      }
    } catch (e) {
      debugPrint('Error loading schedule IDs: $e');
    }

    // Source C: Bookings
    try {
      final bookingDs = BookingRemoteDataSourceImpl();
      final bookings = await bookingDs.getBookingsByHomeStaff();
      for (final b in bookings) {
        if (b.customer?.id != null && b.customer!.id.isNotEmpty) {
           customerIds.add(b.customer!.id);
        }
      }
    } catch (e) {
      debugPrint('Error loading booking IDs: $e');
    }

    // 2. For each unique customer ID, fetch Family Profiles to get the "Gia đình" name
    for (final id in customerIds) {
      try {
        final profiles = await _profileDs.getFamilyProfilesByAccountId(id);
        if (profiles.isNotEmpty) {
          // Find Head of Family or use the first one
          final head = profiles.firstWhere(
            (p) => (p.memberTypeName ?? '').toLowerCase().contains('head'),
            orElse: () => profiles.first,
          );
          
          result.add(_AssignedCustomer(
            customerId: id,
            displayName: 'Gia đình ${head.fullName}',
            email: '',
          ));
        } else {
          // Fallback if no profiles found
          result.add(_AssignedCustomer(
            customerId: id,
            displayName: 'Gia đình #$id',
            email: '',
          ));
        }
      } catch (e) {
        debugPrint('Error loading profiles for $id: $e');
        result.add(_AssignedCustomer(
          customerId: id,
          displayName: 'Gia đình #$id',
          email: '',
        ));
      }
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
                              _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
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

  Future<List<MenuRecordModel>> _loadMenuRecordsByCurrentFilter() {
    if (_selectedCustomerId == null) return Future.value([]);
    
    final customerId = _selectedCustomerId!;
    switch (_menuFilterMode) {
      case _MenuFilterMode.date:
        return _profileDs.getMenuRecordsByCustomerDate(
          customerId: customerId,
          date: _selectedDate,
        );
      case _MenuFilterMode.range:
        if (_rangeFrom != null && _rangeTo != null) {
          return _profileDs.getMenuRecordsByCustomerDateRange(
            customerId: customerId,
            from: _rangeFrom!,
            to: _rangeTo!,
          );
        }
        return _profileDs.getMenuRecordsByCustomer(customerId);
      case _MenuFilterMode.all:
        return _profileDs.getMenuRecordsByCustomer(customerId);
    }
  }


  Widget _buildMenuRecordsSection(BuildContext context) {
    if (_selectedCustomerId == null) return const SizedBox.shrink();
    _menuRecordsFuture ??= _loadMenuRecordsByCurrentFilter();
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFilterBar(scale),
        SizedBox(height: 16 * scale),
        FutureBuilder<List<MenuRecordModel>>(
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

        // 1. Sort records: Date DESC, Meal ASC
        final sortedRecords = List<MenuRecordModel>.from(records)..sort((a, b) {
          // Compare dates first (DESC)
          final dateA = DateTime(a.date.year, a.date.month, a.date.day);
          final dateB = DateTime(b.date.year, b.date.month, b.date.day);
          final dateComp = dateB.compareTo(dateA);
          if (dateComp != 0) return dateComp;

          // Same date, compare meals (ASC)
          const mealPriority = {'Sáng': 1, 'Trưa': 2, 'Chiều': 3, 'Tối': 4};
          
          String getMeal(String name) {
            final p = name.split(' - ');
            if (p.length > 1) {
              final m = p.last.trim();
              if (m.contains('Sáng')) return 'Sáng';
              if (m.contains('Trưa')) return 'Trưa';
              if (m.contains('Chiều')) return 'Chiều';
              if (m.contains('Tối')) return 'Tối';
              return m;
            }
            if (name.contains('sáng')) return 'Sáng';
            if (name.contains('trưa')) return 'Trưa';
            if (name.contains('chiều')) return 'Chiều';
            if (name.contains('tối')) return 'Tối';
            return 'Bữa ăn';
          }

          int pA = mealPriority[getMeal(a.name)] ?? 99;
          int pB = mealPriority[getMeal(b.name)] ?? 99;
          return pA.compareTo(pB);
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedRecords.length,
          itemBuilder: (context, index) {
            final r = sortedRecords[index];
            
            // Check if we should show a date header
            bool showHeader = false;
            if (index == 0) {
              showHeader = true;
            } else {
              final prevDate = sortedRecords[index - 1].date;
              if (prevDate.year != r.date.year || 
                  prevDate.month != r.date.month || 
                  prevDate.day != r.date.day) {
                showHeader = true;
              }
            }

            final mealType = r.name.contains('Sáng') || r.name.contains('sáng') ? 'Sáng' : 
                            (r.name.contains('Trưa') || r.name.contains('trưa') ? 'Trưa' : 
                            (r.name.contains('Chiều') || r.name.contains('chiều') ? 'Chiều' : 
                            (r.name.contains('Tối') || r.name.contains('tối') ? 'Tối' : 'Khác')));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHeader) ...[
                  if (index != 0) SizedBox(height: 24 * scale),
                  Padding(
                    padding: EdgeInsets.only(bottom: 12 * scale),
                    child: Row(
                      children: [
                        Container(
                          width: 4 * scale,
                          height: 18 * scale,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 10 * scale),
                        Text(
                          _formatDate(r.date),
                          style: AppTextStyles.arimo(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Container(
                  margin: EdgeInsets.only(bottom: 16 * scale),
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24 * scale),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _viewMenuDetails(context, r.menuId),
                        child: Padding(
                          padding: EdgeInsets.all(16 * scale),
                          child: Row(
                            children: [
                              _buildMealIcon(mealType, scale),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.name,
                                      style: AppTextStyles.arimo(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 6 * scale),
                                    Row(
                                      children: [
                                        Icon(Icons.restaurant_menu_rounded, size: 12 * scale, color: AppColors.textSecondary),
                                        SizedBox(width: 4 * scale),
                                        Text(
                                          'Thực đơn mẫu #${r.menuId}',
                                          style: AppTextStyles.arimo(
                                            fontSize: 12 * scale,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 24 * scale),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    ),
      ],
    );
  }

  Widget _buildMealIcon(String type, double scale) {
    Color color;
    IconData icon;
    
    switch (type) {
      case 'Sáng':
        color = const Color(0xFFFF9800);
        icon = Icons.wb_sunny_rounded;
        break;
      case 'Trưa':
        color = const Color(0xFF4CAF50);
        icon = Icons.light_mode_rounded;
        break;
      case 'Chiều':
        color = const Color(0xFFFF5722);
        icon = Icons.bakery_dining_rounded;
        break;
      case 'Tối':
        color = const Color(0xFF3F51B5);
        icon = Icons.nightlight_round;
        break;
      default:
        color = AppColors.primary;
        icon = Icons.restaurant_rounded;
    }

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Icon(icon, color: color, size: 26 * scale),
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
      if (!context.mounted) return;
      Navigator.pop(context); // hide loader
      _showMenuDetailsDialog(context, menu);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // hide loader
      AppToast.showError(context, message: 'Không thể tải chi tiết thực đơn: $e');
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

  Widget _buildFilterBar(double scale) {
    final selectedDateText = _formatDate(_selectedDate);
    final isAll = _menuFilterMode == _MenuFilterMode.all;
    final isDate = _menuFilterMode == _MenuFilterMode.date;
    final isRange = _menuFilterMode == _MenuFilterMode.range;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        children: [
          Text(
            'Lọc:',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: SizedBox(
              height: 38 * scale,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip(
                    label: 'Tất cả',
                    icon: Icons.grid_view_rounded,
                    isSelected: isAll,
                    onTap: () {
                      setState(() {
                        _menuFilterMode = _MenuFilterMode.all;
                        _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
                      });
                    },
                    scale: scale,
                  ),
                  SizedBox(width: 8 * scale),
                  _filterChip(
                    label: selectedDateText,
                    icon: Icons.calendar_today_rounded,
                    isSelected: isDate,
                    onTap: _pickSingleDate,
                    scale: scale,
                  ),
                  SizedBox(width: 8 * scale),
                  _filterChip(
                    label: isRange ? '${_formatDate(_rangeFrom!)} → ${_formatDate(_rangeTo!)}' : 'Theo khoảng',
                    icon: Icons.date_range_rounded,
                    isSelected: isRange,
                    onTap: _pickDateRange,
                    scale: scale,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required double scale,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12 * scale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14 * scale, color: isSelected ? Colors.white : AppColors.textSecondary),
            SizedBox(width: 6 * scale),
            Text(
              label,
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSingleDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
        _menuFilterMode = _MenuFilterMode.date;
        _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
      });
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: (_rangeFrom != null && _rangeTo != null)
          ? DateTimeRange(start: _rangeFrom!, end: _rangeTo!)
          : null,
    );
    if (range != null) {
      setState(() {
        _rangeFrom = range.start;
        _rangeTo = range.end;
        _menuFilterMode = _MenuFilterMode.range;
        _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
      });
    }
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

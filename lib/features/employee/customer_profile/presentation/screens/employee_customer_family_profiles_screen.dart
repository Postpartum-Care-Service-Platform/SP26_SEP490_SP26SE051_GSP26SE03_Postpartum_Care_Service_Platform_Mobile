import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../features/auth/data/models/current_account_model.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../../../../features/family_profile/domain/entities/family_profile_entity.dart';
import '../../../../../features/services/data/datasources/family_schedule_remote_datasource.dart';
import '../../../../../features/services/data/models/menu_record_model.dart';
import '../../../../../features/services/data/models/menu_model.dart';
import '../../../../../features/employee/customer_profile/data/datasources/employee_customer_profile_remote_datasource.dart';
import '../widgets/tabs/customer_profile_family_tab.dart';
import '../widgets/tabs/customer_profile_menu_tab.dart';
import '../widgets/tabs/customer_profile_bookings_tab.dart';
import '../widgets/tabs/customer_profile_appointments_tab.dart';
import '../widgets/tabs/customer_profile_transactions_tab.dart';
import '../widgets/tabs/customer_profile_account_tab.dart';
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

enum _MenuFilterMode { all, date, range }

class _EmployeeCustomerFamilyProfilesScreenState
    extends State<EmployeeCustomerFamilyProfilesScreen> {
  final _profileDs = EmployeeCustomerProfileRemoteDataSource();

  late Future<List<FamilyProfileEntity>> _familyProfilesFuture =
      _loadFamilyProfiles(widget.customerId);
  late Future<List<MenuRecordModel>> _menuRecordsFuture =
      _loadMenuRecordsByCurrentFilter();
  late Future<List<Map<String, dynamic>>> _bookingsFuture =
      _profileDs.getBookingsByCustomer(widget.customerId);
  late Future<List<Map<String, dynamic>>> _appointmentsFuture =
      _profileDs.getAppointmentsByCustomer(widget.customerId);
  late Future<List<Map<String, dynamic>>> _transactionsFuture =
      _profileDs.getTransactionsByCustomer(widget.customerId);
  late Future<CurrentAccountModel> _accountFuture =
      _profileDs.getAccountById(widget.customerId);

  bool _creatingSchedule = false;
  _MenuFilterMode _menuFilterMode = _MenuFilterMode.all;
  DateTime _selectedDate = DateTime.now();
  DateTime? _rangeFrom;
  DateTime? _rangeTo;

  Future<List<FamilyProfileEntity>> _loadFamilyProfiles(String accountId) {
    return _profileDs.getFamilyProfilesByAccountId(accountId);
  }

  Future<List<MenuRecordModel>> _loadMenuRecordsByCurrentFilter() {
    switch (_menuFilterMode) {
      case _MenuFilterMode.all:
        return _profileDs.getMenuRecordsByCustomer(widget.customerId);
      case _MenuFilterMode.date:
        return _profileDs.getMenuRecordsByCustomerDate(
          customerId: widget.customerId,
          date: _selectedDate,
        );
      case _MenuFilterMode.range:
        if (_rangeFrom == null || _rangeTo == null) {
          throw Exception('Vui lòng chọn đủ ngày bắt đầu và kết thúc');
        }
        return _profileDs.getMenuRecordsByCustomerDateRange(
          customerId: widget.customerId,
          from: _rangeFrom!,
          to: _rangeTo!,
        );
    }
  }

  Future<void> _pickSingleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
      _menuFilterMode = _MenuFilterMode.date;
      _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: _rangeFrom != null && _rangeTo != null
          ? DateTimeRange(start: _rangeFrom!, end: _rangeTo!)
          : null,
    );

    if (picked == null) return;

    setState(() {
      _rangeFrom = picked.start;
      _rangeTo = picked.end;
      _menuFilterMode = _MenuFilterMode.range;
      _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
    });
  }

  Future<void> _createFamilySchedule() async {
    if (_creatingSchedule) return;

    setState(() {
      _creatingSchedule = true;
    });

    try {
      final bookingDs = BookingRemoteDataSourceImpl();
      final bookings = await bookingDs.getAllBookings();
      final customerBookings = bookings
          .where((b) => b.customer?.id == widget.customerId)
          .toList();

      if (customerBookings.isEmpty) {
        if (mounted) {
          AppToast.showError(
            context,
            message: 'Không tìm thấy booking nào cho khách hàng này',
          );
        }
        return;
      }

      customerBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latest = customerBookings.first;

      if (latest.remainingAmount > 0) {
        if (mounted) {
          AppToast.showError(
            context,
            message:
                'Booking mới nhất chưa thanh toán đủ. Vui lòng kiểm tra lại trước khi tạo lịch sinh hoạt.',
          );
        }
        return;
      }

      final contract = latest.contract;
      if (contract == null) {
        if (mounted) {
          AppToast.showError(
            context,
            message:
                'Booking mới nhất chưa có hợp đồng. Không thể tạo lịch sinh hoạt.',
          );
        }
        return;
      }

      final familyScheduleDs = FamilyScheduleRemoteDataSourceImpl();
      final message = await familyScheduleDs.createFamilySchedule(
        customerId: widget.customerId,
        contractId: contract.id,
      );

      if (mounted) {
        AppToast.showSuccess(context, message: message);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          message: 'Không thể tạo lịch sinh hoạt gia đình: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _creatingSchedule = false;
        });
      }
    }
  }

  Future<void> _createMenuRecordByStaff() async {
    final menuIdCtrl = TextEditingController();
    DateTime pickedDate = DateTime.now();
    String mealType = 'Breakfast';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Thêm Menu Record'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: menuIdCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Menu ID'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: mealType,
                    decoration: const InputDecoration(labelText: 'Meal Type'),
                    items: const [
                      DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                      DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                      DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          mealType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ngày áp dụng'),
                    subtitle: Text(_fmtDate(pickedDate)),
                    trailing: const Icon(Icons.calendar_month_rounded),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: pickedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setStateDialog(() {
                          pickedDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Tạo'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final menuId = int.tryParse(menuIdCtrl.text.trim());
    if (menuId == null) {
      if (mounted) {
        AppToast.showError(context, message: 'Menu ID không hợp lệ');
      }
      return;
    }

    try {
      await _profileDs.createMenuRecordsByStaff(
        customerId: widget.customerId,
        requests: [
          {
            'menuId': menuId,
            'date': _fmtDate(pickedDate),
            'mealType': mealType,
          }
        ],
      );
      _refreshAll();
      if (mounted) {
        AppToast.showSuccess(context, message: 'Tạo Menu Record thành công');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, message: 'Không thể tạo Menu Record: $e');
      }
    }
  }

  Future<void> _updateMenuRecordByStaff(MenuRecordModel record) async {
    final menuIdCtrl = TextEditingController(text: record.menuId.toString());
    DateTime pickedDate = record.date;
    String mealType = 'Breakfast';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Cập nhật Menu Record #${record.id}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: menuIdCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Menu ID'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: mealType,
                    decoration: const InputDecoration(labelText: 'Meal Type'),
                    items: const [
                      DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                      DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                      DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setStateDialog(() {
                          mealType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Ngày áp dụng'),
                    subtitle: Text(_fmtDate(pickedDate)),
                    trailing: const Icon(Icons.calendar_month_rounded),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: pickedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setStateDialog(() {
                          pickedDate = date;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Cập nhật'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) return;

    final menuId = int.tryParse(menuIdCtrl.text.trim());
    if (menuId == null) {
      if (mounted) {
        AppToast.showError(context, message: 'Menu ID không hợp lệ');
      }
      return;
    }

    try {
      await _profileDs.updateMenuRecordsByStaff(
        customerId: widget.customerId,
        requests: [
          {
            'id': record.id,
            'menuId': menuId,
            'date': _fmtDate(pickedDate),
            'mealType': mealType,
          }
        ],
      );
      _refreshAll();
      if (mounted) {
        AppToast.showSuccess(context, message: 'Cập nhật Menu Record thành công');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, message: 'Không thể cập nhật Menu Record: $e');
      }
    }
  }

  Future<void> _deleteMenuRecordByStaff(MenuRecordModel record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa Menu Record'),
        content: Text('Bạn có chắc muốn xóa Menu Record #${record.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _profileDs.deleteMenuRecordByStaff(
        menuRecordId: record.id,
        customerId: widget.customerId,
      );
      _refreshAll();
      if (mounted) {
        AppToast.showSuccess(context, message: 'Đã xóa Menu Record');
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, message: 'Không thể xóa Menu Record: $e');
      }
    }
  }

  Future<void> _viewMenuDetails(int menuId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final menu = await _profileDs.getMenuById(menuId);
      if (mounted) {
        Navigator.pop(context); // hide loader
        _showMenuDetailsDialog(menu);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // hide loader
        AppToast.showError(context, message: 'Không thể tải chi tiết thực đơn: $e');
      }
    }
  }

  void _showMenuDetailsDialog(MenuModel menu) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      menu.menuName,
                      style: AppTextStyles.arimo(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menu.menuTypeName,
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (menu.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Text(
                        menu.description!,
                        style: AppTextStyles.arimo(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const Divider(height: 32),
                    Text(
                      'Danh sách món ăn',
                      style: AppTextStyles.arimo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (menu.foods.isEmpty)
                      const Text('Chưa có món ăn nào trong thực đơn này.')
                    else
                      for (final food in menu.foods)
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: AppTextStyles.arimo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (food.description != null)
                                Text(
                                  food.description!,
                                  style: AppTextStyles.arimo(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
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
        ),
      ),
    );
  }

  void _refreshAll() {
    setState(() {
      _familyProfilesFuture = _loadFamilyProfiles(widget.customerId);
      _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
      _bookingsFuture = _profileDs.getBookingsByCustomer(widget.customerId);
      _appointmentsFuture = _profileDs.getAppointmentsByCustomer(widget.customerId);
      _transactionsFuture = _profileDs.getTransactionsByCustomer(widget.customerId);
      _accountFuture = _profileDs.getAccountById(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    final authBloc = context.read<AuthBloc>();
    final authState = authBloc.state;
    String? memberType;
    if (authState is AuthCurrentAccountLoaded) {
      final account = authState.account;
      memberType = (account as dynamic).memberType;

      if (memberType == null) {
        try {
          memberType = (account as dynamic).ownerProfile?.memberTypeName;
        } catch (_) {}
      }
    }

    final raw = memberType?.toLowerCase().trim() ?? '';
    final isHomeNurse = raw == 'home-staff' || 
                        raw == 'homestaff' || 
                        raw == 'hoemstaff' || 
                        raw == 'home nurse' || 
                        raw.contains('tại nhà') || 
                        raw.contains('tai nha') || 
                        raw.contains('homecare');

    return DefaultTabController(
      length: isHomeNurse ? 5 : 6,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Profile khách hàng',
            style: AppTextStyles.arimo(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 24 * scale,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12 * scale),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Tạo lịch sinh hoạt',
                    onPressed: _creatingSchedule ? null : _createFamilySchedule,
                    icon: const Icon(Icons.event_available_rounded),
                  ),
                  SizedBox(width: 12 * scale),
                  IconButton(
                    tooltip: 'Làm mới',
                    onPressed: _refreshAll,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: EdgeInsets.symmetric(horizontal: 12 * scale),
            labelStyle: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
            ),
            tabs: [
              const Tab(text: 'Hồ sơ gia đình'),
              if (!isHomeNurse) const Tab(text: 'Thực đơn khách hàng'),
              const Tab(text: 'Booking'),
              const Tab(text: 'Lịch hẹn'),
              const Tab(text: 'Giao dịch'),
              const Tab(text: 'Tài khoản'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CustomerProfileFamilyTab(
              future: _familyProfilesFuture,
              customerId: widget.customerId,
              customerName: widget.customerName,
              scale: scale,
            ),
            if (!isHomeNurse)
              CustomerProfileMenuTab(
                future: _menuRecordsFuture,
                scale: scale,
                fmtDate: _fmtDate,
                filterWidget: _buildMenuFilterBar(scale),
                onViewDetails: _viewMenuDetails,
                onEdit: _updateMenuRecordByStaff,
                onDelete: _deleteMenuRecordByStaff,
              ),
            CustomerProfileBookingsTab(
              future: _bookingsFuture,
              scale: scale,
              fmtDate: _fmtDate,
            ),
            CustomerProfileAppointmentsTab(
              future: _appointmentsFuture,
              scale: scale,
              fmtDate: _fmtDate,
            ),
            CustomerProfileTransactionsTab(
              future: _transactionsFuture,
              scale: scale,
              fmtDate: _fmtDate,
            ),
            CustomerProfileAccountTab(
              future: _accountFuture,
              scale: scale,
              fmtDate: _fmtDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuFilterBar(double scale) {
    final selectedDateText = _fmtDate(_selectedDate);
    final rangeText = (_rangeFrom != null && _rangeTo != null)
        ? '${_fmtDate(_rangeFrom!)} → ${_fmtDate(_rangeTo!)}'
        : 'Chưa chọn khoảng ngày';

    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 4 * scale),
      child: Wrap(
        spacing: 8 * scale,
        runSpacing: 8 * scale,
        children: [
          ChoiceChip(
            label: const Text('Tất cả'),
            selected: _menuFilterMode == _MenuFilterMode.all,
            onSelected: (_) {
              setState(() {
                _menuFilterMode = _MenuFilterMode.all;
                _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
              });
            },
          ),
          ChoiceChip(
            label: Text('Theo ngày: $selectedDateText'),
            selected: _menuFilterMode == _MenuFilterMode.date,
            onSelected: (_) => _pickSingleDate(),
          ),
          ChoiceChip(
            label: Text('Khoảng ngày: $rangeText'),
            selected: _menuFilterMode == _MenuFilterMode.range,
            onSelected: (_) => _pickDateRange(),
          ),
          ActionChip(
            avatar: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Thêm Thực Đơn'),
            onPressed: _createMenuRecordByStaff,
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime value) => value.toIso8601String().split('T').first;
}

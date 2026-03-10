import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../auth/data/models/current_account_model.dart';
import '../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../../family_profile/domain/entities/family_profile_entity.dart';
import '../../../family_profile/presentation/widgets/family_member_card.dart';
import '../../../services/data/datasources/family_schedule_remote_datasource.dart';
import '../../../services/data/models/menu_record_model.dart';
import '../../data/datasources/employee_customer_profile_remote_datasource.dart';

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
  late Future<List<Map<String, dynamic>>> _medicalRecordsFuture =
      _profileDs.getMedicalRecordsByCustomer(widget.customerId);
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

  Future<List<FamilyProfileEntity>> _loadFamilyProfiles(String customerId) {
    return InjectionContainer.familyProfileRepository
        .getFamilyProfilesByCustomerId(customerId);
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

  void _refreshAll() {
    setState(() {
      _familyProfilesFuture = _loadFamilyProfiles(widget.customerId);
      _menuRecordsFuture = _loadMenuRecordsByCurrentFilter();
      _medicalRecordsFuture = _profileDs.getMedicalRecordsByCustomer(widget.customerId);
      _bookingsFuture = _profileDs.getBookingsByCustomer(widget.customerId);
      _appointmentsFuture = _profileDs.getAppointmentsByCustomer(widget.customerId);
      _transactionsFuture = _profileDs.getTransactionsByCustomer(widget.customerId);
      _accountFuture = _profileDs.getAccountById(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return DefaultTabController(
      length: 7,
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
            IconButton(
              tooltip: 'Tạo lịch sinh hoạt',
              onPressed: _creatingSchedule ? null : _createFamilySchedule,
              icon: const Icon(Icons.event_available_rounded),
            ),
            IconButton(
              tooltip: 'Làm mới',
              onPressed: _refreshAll,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            labelStyle: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'Hồ sơ gia đình'),
              Tab(text: 'Menu Record'),
              Tab(text: 'Hồ sơ y tế'),
              Tab(text: 'Booking'),
              Tab(text: 'Lịch hẹn'),
              Tab(text: 'Giao dịch'),
              Tab(text: 'Tài khoản'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFamilyProfilesTab(scale),
            _buildMenuRecordsTab(scale),
            _buildMedicalRecordsTab(scale),
            _buildBookingsTab(scale),
            _buildAppointmentsTab(scale),
            _buildTransactionsTab(scale),
            _buildAccountInfoTab(scale),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyProfilesTab(double scale) {
    return FutureBuilder<List<FamilyProfileEntity>>(
      future: _familyProfilesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _errorText(scale, 'Tải dữ liệu thất bại: ${snapshot.error}');
        }

        final members = snapshot.data ?? const [];
        if (members.isEmpty) {
          return _emptyText(scale, 'Chưa có hồ sơ gia đình cho khách hàng này.');
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
              FamilyMemberCard(member: m, showActions: false, onTap: null),
            SizedBox(height: 18 * scale),
          ],
        );
      },
    );
  }

  Widget _buildMenuRecordsTab(double scale) {
    final selectedDateText = _fmtDate(_selectedDate);
    final rangeText = (_rangeFrom != null && _rangeTo != null)
        ? '${_fmtDate(_rangeFrom!)} → ${_fmtDate(_rangeTo!)}'
        : 'Chưa chọn khoảng ngày';

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(12 * scale, 10 * scale, 12 * scale, 6 * scale),
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
                label: const Text('Thêm record'),
                onPressed: _createMenuRecordByStaff,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<MenuRecordModel>>(
            future: _menuRecordsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (snapshot.hasError) {
                return _errorText(
                  scale,
                  'Không tải được Menu Record: ${snapshot.error}',
                );
              }

              final records = snapshot.data ?? const [];
              if (records.isEmpty) {
                return _emptyText(scale, 'Không có Menu Record theo bộ lọc hiện tại.');
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
                          'Ngày: ${_fmtDate(r.date)}',
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
                              onPressed: () => _updateMenuRecordByStaff(r),
                              icon: const Icon(Icons.edit_rounded),
                            ),
                            IconButton(
                              tooltip: 'Xóa',
                              onPressed: () => _deleteMenuRecordByStaff(r),
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

  Widget _buildMedicalRecordsTab(double scale) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _medicalRecordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _errorText(scale, 'Không tải được hồ sơ y tế: ${snapshot.error}');
        }

        final records = snapshot.data ?? const [];
        if (records.isEmpty) {
          return _emptyText(scale, 'Khách hàng chưa có hồ sơ y tế.');
        }

        return ListView.separated(
          padding: EdgeInsets.all(16 * scale),
          itemCount: records.length,
          separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
          itemBuilder: (context, index) {
            final r = records[index];
            final id = r['id']?.toString() ?? 'N/A';
            final updatedAt = (r['updatedAt'] ?? '').toString();
            final notes = (r['notes'] ?? r['description'] ?? r['diagnosis'] ?? '-')
                .toString();

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
                    'Medical Record #$id',
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    'Ghi chú: $notes',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (updatedAt.isNotEmpty)
                    Text(
                      'Cập nhật: $updatedAt',
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

  Widget _buildBookingsTab(double scale) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _errorText(scale, 'Không tải được Booking: ${snapshot.error}');
        }

        final records = snapshot.data ?? const [];
        if (records.isEmpty) {
          return _emptyText(scale, 'Không có booking của khách hàng này.');
        }

        return _buildGenericMapList(
          scale: scale,
          records: records,
          titleBuilder: (item) => 'Booking #${item['id'] ?? 'N/A'}',
          subtitleBuilder: (item) {
            final status = item['status']?.toString() ?? 'Unknown';
            final startDate = item['startDate']?.toString() ?? '-';
            return 'Trạng thái: $status • Bắt đầu: $startDate';
          },
        );
      },
    );
  }

  Widget _buildAppointmentsTab(double scale) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _errorText(scale, 'Không tải được Appointment: ${snapshot.error}');
        }

        final records = snapshot.data ?? const [];
        if (records.isEmpty) {
          return _emptyText(scale, 'Không có lịch hẹn của khách hàng này.');
        }

        return _buildGenericMapList(
          scale: scale,
          records: records,
          titleBuilder: (item) => 'Appointment #${item['id'] ?? 'N/A'}',
          subtitleBuilder: (item) {
            final status = item['status']?.toString() ?? 'Unknown';
            final date = item['appointmentDate']?.toString() ?? '-';
            return 'Trạng thái: $status • Ngày hẹn: $date';
          },
        );
      },
    );
  }

  Widget _buildTransactionsTab(double scale) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _errorText(scale, 'Không tải được giao dịch: ${snapshot.error}');
        }

        final records = snapshot.data ?? const [];
        if (records.isEmpty) {
          return _emptyText(scale, 'Không có giao dịch của khách hàng này.');
        }

        return _buildGenericMapList(
          scale: scale,
          records: records,
          titleBuilder: (item) => 'Transaction #${item['id'] ?? item['transactionId'] ?? 'N/A'}',
          subtitleBuilder: (item) {
            final amount = item['amount']?.toString() ?? '0';
            final status = item['status']?.toString() ?? item['transactionStatus']?.toString() ?? 'Unknown';
            return 'Số tiền: $amount • Trạng thái: $status';
          },
        );
      },
    );
  }

  Widget _buildGenericMapList({
    required double scale,
    required List<Map<String, dynamic>> records,
    required String Function(Map<String, dynamic>) titleBuilder,
    required String Function(Map<String, dynamic>) subtitleBuilder,
  }) {
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
  }

  Widget _buildAccountInfoTab(double scale) {
    return FutureBuilder<CurrentAccountModel>(
      future: _accountFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (snapshot.hasError) {
          return _errorText(
            scale,
            'Không tải được thông tin tài khoản: ${snapshot.error}',
          );
        }

        final acc = snapshot.data;
        if (acc == null) {
          return _emptyText(scale, 'Không có dữ liệu tài khoản.');
        }

        final displayName = acc.ownerProfile?.fullName ?? acc.username;
        final status = acc.isActive ? 'Hoạt động' : 'Ngưng hoạt động';

        return ListView(
          padding: EdgeInsets.all(16 * scale),
          children: [
            _infoTile(scale, 'Họ tên', displayName),
            _infoTile(scale, 'Email', acc.email),
            _infoTile(scale, 'Số điện thoại', acc.phone),
            _infoTile(scale, 'Username', acc.username),
            _infoTile(scale, 'Vai trò', acc.roleName),
            _infoTile(scale, 'Trạng thái', status),
            _infoTile(scale, 'Đã xác minh email', acc.isEmailVerified ? 'Có' : 'Chưa'),
            if (acc.ownerProfile?.address != null)
              _infoTile(scale, 'Địa chỉ', acc.ownerProfile!.address!),
            if (acc.ownerProfile?.gender != null)
              _infoTile(scale, 'Giới tính', acc.ownerProfile!.gender!),
            if (acc.ownerProfile?.dateOfBirth != null)
              _infoTile(scale, 'Ngày sinh', _fmtDate(acc.ownerProfile!.dateOfBirth!)),
          ],
        );
      },
    );
  }

  Widget _infoTile(double scale, String label, String value) {
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

  Widget _errorText(double scale, String text) {
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

  Widget _emptyText(double scale, String text) {
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

  String _fmtDate(DateTime value) => value.toIso8601String().split('T').first;
}

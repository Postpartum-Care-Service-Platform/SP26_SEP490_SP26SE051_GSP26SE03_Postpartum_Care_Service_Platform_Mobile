// lib/features/employee/presentation/screens/service_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/employee/account/data/datasources/account_remote_datasource.dart';
import '../../../../../features/employee/account/data/models/account_model.dart';
import '../../../../../features/employee/amenity_service/domain/entities/amenity_service_entity.dart';
import '../../../../../features/services/domain/entities/family_schedule_entity.dart';
import '../../../../../features/services/domain/entities/staff_schedule_entity.dart';
import '../../../../../features/services/presentation/bloc/staff_schedule/staff_schedule_bloc.dart';
import '../../../../../features/services/presentation/bloc/staff_schedule/staff_schedule_event.dart';
import '../../../../../features/services/presentation/bloc/staff_schedule/staff_schedule_state.dart';
import '../../../../../features/employee/amenity_service/presentation/bloc/amenity_service/amenity_service_bloc.dart';
import '../../../../../features/employee/amenity_service/presentation/bloc/amenity_service/amenity_service_state.dart';
import '../../../../../features/employee/amenity_ticket/presentation/bloc/amenity_ticket/amenity_ticket_bloc.dart';
import '../../../../../features/employee/amenity_ticket/presentation/bloc/amenity_ticket/amenity_ticket_event.dart';
import '../../../../../features/employee/amenity_ticket/presentation/bloc/amenity_ticket/amenity_ticket_state.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_header_bar.dart';  
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';
import '../../../../../core/utils/app_date_time_utils.dart';
import '../../domain/entities/amenity_ticket_entity.dart';
import '../../domain/entities/amenity_ticket_status.dart';

/// Service Booking Screen
/// Allows staff to book amenity services for customers
class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();

  AccountModel? _selectedCustomer;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;

  List<AccountModel> _customers = [];
  List<AccountModel> _filteredCustomers = [];
  List<StaffScheduleEntity> _staffSchedules = [];
  List<FamilyScheduleEntity> _availableFamilySchedules = [];
  AmenityServiceEntity? _selectedService;

  bool _isLoadingCustomers = false;
  bool _isLoadingStaffSchedules = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    _selectedDate = startDate;
    _loadStaffSchedulesForRange(startDate, startDate);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadStaffSchedulesForRange(DateTime from, DateTime to) {
    final formattedFrom = _formatDateOnly(from);
    final formattedTo = _formatDateOnly(to);
    context.read<StaffScheduleBloc>().add(
          LoadStaffSchedulesByDateRange(from: formattedFrom, to: formattedTo),
        );
  }

  String _formatDateOnly(DateTime value) {
    return DateFormat('yyyy-MM-dd').format(value);
  }

  String _formatTimeOnly(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final accountDataSource = AccountRemoteDataSource();
      final customers = await accountDataSource.getCustomers();

      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCustomers = false;
        _customers = [];
        _filteredCustomers = [];
      });
      debugPrint('Optional load all customers failed: $e');
    }

    if (_selectedDate != null) {
      _loadStaffSchedulesForRange(_selectedDate!, _selectedDate!);
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = _customers;
      } else {
        _filteredCustomers = _customers.where((customer) {
          return customer.displayName.toLowerCase().contains(query) ||
              customer.email.toLowerCase().contains(query) ||
              (customer.phone?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTime = null;
        _availableFamilySchedules = [];
        _staffSchedules = [];
      });
      _loadStaffSchedulesForRange(picked, picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _selectCustomer(AccountModel customer) {
    setState(() {
      _selectedCustomer = customer;
      _selectedTime = null;
      _searchController.text = customer.displayName;
    });

    _updateLocalSchedules();
    Navigator.pop(context);
  }

  void _updateLocalSchedules() {
    if (_selectedCustomer == null) return;
    setState(() {
      _availableFamilySchedules = _staffSchedules
          .map((schedule) => schedule.familySchedule)
          .whereType<FamilyScheduleEntity>()
          .where((schedule) =>
              schedule.customerId == _selectedCustomer!.id ||
              schedule.customerName == _selectedCustomer!.displayName)
          .toList();
    });
  }

  void _toggleService(AmenityServiceEntity service) {
    setState(() {
      if (_selectedService?.id == service.id) {
        _selectedService = null;
      } else {
        _selectedService = service;
      }
    });
  }

  List<String> _calculateAvailableStartTimes() {
    if (_selectedCustomer == null) return [];

    // 1. Phách hợp danh sách lịch bận từ Staff Schedule (Meal, Checkup, etc.)
    final busySchedules = _staffSchedules
        .map((s) => s.familySchedule)
        .whereType<FamilyScheduleEntity>()
        .where((s) =>
            s.customerId == _selectedCustomer!.id ||
            s.customerName == _selectedCustomer!.displayName)
        .where((s) => s.status.toLowerCase() != 'cancelled') // Bỏ qua lịch đã hủy
        .toList();

    // Sắp xếp các lịch bận theo thời gian bắt đầu
    busySchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    // 2. Định nghĩa khung giờ làm việc (07:00 đến 20:00)
    const workStartStr = "07:00:00";
    const workEndStr = "20:00:00";
    
    DateTime _toDT(String timeStr) => DateFormat("HH:mm:ss").parse(timeStr);
    String _fromDT(DateTime dt) => DateFormat("HH:mm:ss").format(dt);

    final workStart = _toDT(workStartStr);
    final workEnd = _toDT(workEndStr);
    final serviceDuration = int.tryParse(_selectedService?.duration ?? '30') ?? 30;

    // 3. Tìm các khoảng trống (gaps) giữa các lịch bận
    // Cấu trúc một gap: {start: DateTime, end: DateTime}
    List<Map<String, DateTime>> gaps = [];
    DateTime lastEnd = workStart;

    for (final busy in busySchedules) {
      DateTime busyStart = _toDT(busy.startTime);
      DateTime busyEnd = _toDT(busy.endTime);

      if (busyStart.isAfter(lastEnd)) {
        gaps.add({'start': lastEnd, 'end': busyStart});
      }
      
      // Cập nhật mốc kết thúc cuối cùng (đề phòng lịch chồng chéo hoặc sát nhau)
      if (busyEnd.isAfter(lastEnd)) {
        lastEnd = busyEnd;
      }
    }

    // Khoảng trống cuối cùng đến hết giờ làm việc
    if (lastEnd.isBefore(workEnd)) {
      gaps.add({'start': lastEnd, 'end': workEnd});
    }

    // 4. Lọc các khoảng trống thỏa mãn điều kiện "Gap >= 2 tiếng"
    List<String> availableSlots = [];
    const timeStep = 30; // 30 phút gợi ý 1 slot

    for (final gap in gaps) {
      final gapStart = gap['start']!;
      final gapEnd = gap['end']!;
      final gapDuration = gapEnd.difference(gapStart).inMinutes;

      // CHỈ đề xuất nếu khoảng trống >= 120 phút (2 tiếng)
      if (gapDuration >= 120) {
        DateTime current = gapStart;
        // Kiểm tra xem slot [current, current + duration] có nằm trọn trong gap không
        while (current.add(Duration(minutes: serviceDuration)).isBefore(gapEnd) || 
               current.add(Duration(minutes: serviceDuration)).isAtSameMomentAs(gapEnd)) {
          
          availableSlots.add(_fromDT(current).substring(0, 5));
          current = current.add(const Duration(minutes: timeStep));
        }
      }
    }

    return availableSlots;
  }

  void _applyAvailableSchedules(List<StaffScheduleEntity> schedules) {
    setState(() {
      _staffSchedules = schedules;

      // Cập nhật danh sách khách hàng từ schedule (để có data ban đầu nếu getCustomers lỗi)
      final List<AccountModel> scheduleCustomers = [];
      for (final s in _staffSchedules.where((item) => item.familySchedule != null)) {
        final family = s.familySchedule!;
        if (!scheduleCustomers.any((c) => c.id == family.customerId)) {
          scheduleCustomers.add(AccountModel(
            id: family.customerId,
            email: '',
            username: family.customerName ?? 'Khách hàng',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            roleName: 'Customer',
            isEmailVerified: true,
          ));
        }
      }
      
      if (_customers.isEmpty && scheduleCustomers.isNotEmpty) {
        _filteredCustomers = scheduleCustomers;
      }

      _updateLocalSchedules();
    });
  }

  void _submit() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn khách hàng')),
      );
      return;
    }
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn dịch vụ')),
      );
      return;
    }
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày và giờ')),
      );
      return;
    }

    // Thời lượng dịch vụ
    final durationMinutes = int.tryParse(_selectedService!.duration ?? '30') ?? 30;
    
    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));
    
    final endTimeStr = '${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}:00';

    context.read<AmenityTicketBloc>().add(
          CreateServiceBookingEvent(
            customerId: _selectedCustomer!.id,
            amenityServiceId: _selectedService!.id,
            date: _formatDateOnly(_selectedDate!),
            startTime: _formatTimeOnly(_selectedTime!),
            endTime: endTimeStr,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final padding = AppResponsive.pagePadding(context);

    return EmployeeScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const EmployeeHeaderBar(
              title: 'Đặt dịch vụ',
              subtitle: 'Thiết lập thời gian tiện ích cho khách hàng',
            ),
            Expanded(
              child: MultiBlocListener(
                listeners: [
                  BlocListener<StaffScheduleBloc, StaffScheduleState>(
                    listener: (context, state) {
                      if (state is StaffScheduleLoading) {
                        setState(() => _isLoadingStaffSchedules = true);
                      } else {
                        setState(() => _isLoadingStaffSchedules = false);
                      }
                      if (state is StaffScheduleLoaded) {
                        final schedules = state.schedules
                            .where((item) => item.familySchedule != null)
                            .toList();
                        _applyAvailableSchedules(schedules);
                      }
                    },
                  ),
                  BlocListener<AmenityTicketBloc, AmenityTicketState>(
                    listener: (context, state) {
                      if (state is ServiceBookingCreated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                        setState(() {
                          _selectedCustomer = null;
                          _selectedService = null;
                          _selectedDate = DateTime.now();
                          _selectedTime = null;
                          _notesController.clear();
                        });
                      } else if (state is AmenityTicketError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ],
                child: SingleChildScrollView(
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      
                      // 1. CHỌN NGÀY & KHÁCH HÀNG
                      _buildCardSection(
                        icon: Icons.calendar_today_rounded,
                        title: 'Thông tin cơ bản',
                        child: Column(
                          children: [
                            _buildDateSelector(),
                            const SizedBox(height: 12),
                            _buildCustomerSelector(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. CHỌN DỊCH VỤ
                      _buildCardSection(
                        icon: Icons.spa_rounded,
                        title: 'Chọn Tiện ích / Dịch vụ',
                        child: _buildServiceSelector(),
                      ),
                      const SizedBox(height: 16),

                      if (_selectedCustomer != null && _selectedService != null) ...[
                        // 3. LỊCH CỦA KHÁCH
                        _buildCardSection(
                          icon: Icons.event_note_rounded,
                          title: 'Lịch bận hiện tại của khách',
                          color: AppColors.primary.withValues(alpha: 0.05),
                          child: _buildCustomerScheduleSection(),
                        ),
                        const SizedBox(height: 16),

                        // 4. CHỌN GIỜ (CLICK NHANH)
                        _buildCardSection(
                          icon: Icons.access_time_filled_rounded,
                          title: 'Chọn khung giờ trống',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSuggestedSlotsSection(),
                              const SizedBox(height: 16),
                              _buildTimeSelector(),
                              const SizedBox(height: 16),
                              _buildNotesField(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      const SizedBox(height: 8),
                      // 5. TỔNG HỢP & SUBMIT
                      _buildSummaryCard(),
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection({required IconData icon, required String title, required Widget child, Color? color}) {
    final scale = AppResponsive.scaleFactor(context);
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(icon, size: 18 * scale, color: AppColors.primary),
              ),
              SizedBox(width: 12 * scale),
              Text(
                title,
                style: AppTextStyles.arimo(
                  fontSize: 15 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12 * scale),
            child: Divider(color: AppColors.borderLight, height: 1),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCustomerScheduleSection() {
    final scale = AppResponsive.scaleFactor(context);
    final allSchedules = _staffSchedules
        .map((s) => s.familySchedule)
        .whereType<FamilyScheduleEntity>()
        .where((s) =>
            s.customerId == _selectedCustomer!.id ||
            s.customerName == _selectedCustomer!.displayName)
        .toList();

    if (allSchedules.isEmpty) {
      return Text(
        'Khách không có lịch bận nào trong ngày này.',
        style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
      );
    }
    allSchedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    return Column(
      children: allSchedules.map((s) {
        return Padding(
          padding: EdgeInsets.only(bottom: 8 * scale),
          child: Row(
            children: [
              Container(
                width: 85 * scale,
                padding: EdgeInsets.symmetric(vertical: 4 * scale),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  s.timeRange,
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.activity,
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      s.status,
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.circle,
                size: 8 * scale,
                color: _getStatusColor(s.status),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'scheduled' || s == 'confirmed') return Colors.blue;
    if (s == 'done' || s == 'completed') return Colors.green;
    if (s == 'staffdone') return Colors.teal;
    if (s == 'pending') return Colors.orange;
    if (s == 'cancelled' || s == 'rejected') return Colors.red;
    return Colors.grey;
  }

  Widget _buildSuggestedSlotsSection() {
    final scale = AppResponsive.scaleFactor(context);
    final slots = _calculateAvailableStartTimes();
    
    if (slots.isEmpty) {
      return Text(
        'Không tìm thấy khung giờ trống phù hợp.',
        style: AppTextStyles.arimo(fontSize: 13 * scale, color: Colors.orange),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn nhanh giờ bắt đầu (Dịch vụ: ${_selectedService?.duration ?? "30"} phút)',
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8 * scale,
          runSpacing: 8 * scale,
          children: slots.map((time) {
            final isSelected = _selectedTime != null && 
                             _selectedTime!.format(context) == 
                             TimeOfDay(
                               hour: int.parse(time.split(':')[0]), 
                               minute: int.parse(time.split(':')[1])
                             ).format(context);

            return InkWell(
              onTap: () {
                final parts = time.split(':');
                setState(() => _selectedTime = TimeOfDay(
                  hour: int.parse(parts[0]),
                  minute: int.parse(parts[1]),
                ));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3)
                    )
                  ] : null,
                ),
                child: Text(
                  time,
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.white : AppColors.primary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final scale = AppResponsive.scaleFactor(context);
    if (_selectedCustomer == null || _selectedService == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10 * scale,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          _buildSummaryItem(Icons.person, 'Khách hàng: ', _selectedCustomer?.displayName ?? '?', scale),
          const SizedBox(height: 6),
          _buildSummaryItem(Icons.spa, 'Dịch vụ: ', _selectedService?.name ?? '?', scale),
          const SizedBox(height: 6),
          _buildSummaryItem(
            Icons.access_time, 
            'Thời gian: ', 
            '${_selectedTime != null ? _selectedTime!.format(context) : "Chưa chọn"} (Dài ${ _selectedService?.duration ?? 30} phút)', 
            scale
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value, double scale) {
    return Row(
      children: [
        Icon(icon, size: 14 * scale, color: Colors.white.withValues(alpha: 0.7)),
        SizedBox(width: 8 * scale),
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    final scale = AppResponsive.scaleFactor(context);
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: _selectedDate != null ? AppColors.primary : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: AppColors.primary, size: 20 * scale),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Text(
                _selectedDate == null ? 'Chọn ngày' : DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_selectedDate!),
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.edit_calendar, size: 18 * scale, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSelector() {
    final scale = AppResponsive.scaleFactor(context);
    return InkWell(
      onTap: () => _showCustomerSelectionBottomSheet(),
      child: Container(
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: _selectedCustomer != null ? AppColors.primary : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: AppColors.primary, size: 20 * scale),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Text(
                _selectedCustomer?.displayName ?? 'Chọn khách hàng',
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelector() {
    final scale = AppResponsive.scaleFactor(context);
    return BlocBuilder<AmenityServiceBloc, AmenityServiceState>(
      builder: (context, state) {
        if (state is AmenityServiceLoaded) {
          return SizedBox(
            height: 110 * scale,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.services.length,
              itemBuilder: (context, index) {
                final s = state.services[index];
                final isSelected = _selectedService?.id == s.id;
                
                return GestureDetector(
                  onTap: () => _toggleService(s),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 100 * scale,
                    margin: EdgeInsets.only(right: 12 * scale),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4)
                        )
                      ] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (s.imageUrl != null) 
                          ClipRRect(
                            borderRadius: BorderRadius.circular(25 * scale),
                            child: Image.network(s.imageUrl!, width: 45 * scale, height: 45 * scale, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.spa, color: AppColors.primary, size: 30 * scale))
                          )
                        else 
                          Icon(Icons.spa, color: AppColors.primary, size: 30 * scale),
                        SizedBox(height: 8 * scale),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            s.name, 
                            textAlign: TextAlign.center, 
                            style: AppTextStyles.arimo(
                              fontSize: 11 * scale, 
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ), 
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildTimeSelector() {
    final scale = AppResponsive.scaleFactor(context);
    return InkWell(
      onTap: _selectTime,
      child: Container(
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: _selectedTime != null ? AppColors.primary : AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time_filled, color: AppColors.primary, size: 20 * scale),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Text(
                _selectedTime?.format(context) ?? 'Chọn giờ thủ công',
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.edit, size: 16 * scale, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    final scale = AppResponsive.scaleFactor(context);
    return TextField(
      controller: _notesController,
      maxLines: 2,
      style: AppTextStyles.arimo(fontSize: 14 * scale),
      decoration: InputDecoration(
        hintText: 'Ghi chú cho dịch vụ này...',
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.all(12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: BorderSide(color: AppColors.borderLight, width: 0.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12 * scale), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final scale = AppResponsive.scaleFactor(context);
    return BlocBuilder<AmenityTicketBloc, AmenityTicketState>(
      builder: (context, state) {
        final isLoading = state is AmenityTicketLoading;
        return ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary, 
            foregroundColor: Colors.white, 
            padding: EdgeInsets.symmetric(vertical: 16 * scale), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
            elevation: 4,
            shadowColor: AppColors.primary.withValues(alpha: 0.4),
          ),
          child: isLoading 
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('Xác nhận đặt lịch', style: AppTextStyles.arimo(fontSize: 16 * scale, fontWeight: FontWeight.bold)),
                   const SizedBox(width: 8),
                   const Icon(Icons.check_circle_outline),
                ],
              ),
        );
      },
    );
  }

  void _showCustomerSelectionBottomSheet() {
    final scale = AppResponsive.scaleFactor(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20 * scale), 
                  child: Row(
                    children: [
                      Text('Chọn khách hàng', style: AppTextStyles.arimo(fontSize: 18 * scale, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  )
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm khách hàng...', 
                      prefixIcon: const Icon(Icons.search), 
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(20 * scale),
                    itemCount: _filteredCustomers.length,
                    itemBuilder: (context, index) {
                      final c = _filteredCustomers[index];
                      final isSelected = _selectedCustomer?.id == c.id;
                      return ListTile(
                        onTap: () => _selectCustomer(c),
                        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: Text(c.displayName[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))
                        ),
                        title: Text(c.displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(c.phone ?? c.email, style: const TextStyle(fontSize: 12)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : const Icon(Icons.chevron_right),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

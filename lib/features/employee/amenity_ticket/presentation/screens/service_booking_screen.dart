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
  DateTime? _selectedDate;
  DateTime? _selectedDateRangeEnd;
  TimeOfDay? _selectedTime;

  List<AccountModel> _customers = [];
  List<AccountModel> _filteredCustomers = [];
  AmenityServiceEntity? _selectedService;
  List<StaffScheduleEntity> _staffSchedules = [];
  List<FamilyScheduleEntity> _availableFamilySchedules = [];

  bool _isLoadingCustomers = false;
  bool _isLoadingStaffSchedules = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 2));
    _selectedDate = startDate;
    _selectedDateRangeEnd = endDate;
    _loadStaffSchedulesForRange(startDate, endDate);
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
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _formatTimeOnly(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  TimeOfDay _buildScheduleTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.isNotEmpty ? parts[0] : '0') ?? 0;
    final minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final accountDataSource = AccountRemoteDataSource();
      final customers = await accountDataSource.getCustomers();
      
      setState(() {
        _customers = customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      // Silently fail for "system customer list" load as staff might not have permission
      // and it's used primarily for robust ID matching
      setState(() {
        _isLoadingCustomers = false;
        _customers = [];
      });
      debugPrint('Optional load all customers failed: $e');
    }

    // Always ensure staff schedules are loaded for the initial selected date (today)
    if (_selectedDate != null) {
      _loadStaffSchedulesForRange(_selectedDate!, _selectedDate!);
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      final baseList = _customers;

      if (query.isEmpty) {
        _filteredCustomers = baseList;
      } else {
        _filteredCustomers = baseList.where((customer) {
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
      final startDate = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _selectedDate = startDate;
        _selectedDateRangeEnd = startDate; // Same day for staff schedule check
        _selectedTime = null;
        // Don't clear _selectedCustomer here, let _applyAvailableSchedules handle it
        _availableFamilySchedules = [];
        _staffSchedules = [];
      });
      _loadStaffSchedulesForRange(startDate, startDate);
    }
  }

  Future<void> _selectTime() async {
    if (_selectedCustomer == null || _availableFamilySchedules.isEmpty) {
      return;
    }

    final initialTime =
        _selectedTime ??
        _buildScheduleTimeOfDay(_availableFamilySchedules.first.startTime);

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
      _availableFamilySchedules = _staffSchedules
          .map((schedule) => schedule.familySchedule)
          .whereType<FamilyScheduleEntity>()
          .where((schedule) => schedule.customerId == customer.id)
          .toList();
    });
    Navigator.pop(context);
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

  void _applyAvailableSchedules(List<StaffScheduleEntity> schedules) {
    final availableSchedules = schedules
        .map((schedule) => schedule.familySchedule)
        .whereType<FamilyScheduleEntity>()
        .toList();

    // Match schedules with real accounts to get valid IDs
    final List<AccountModel> filteredList = [];
    
    for (final s in availableSchedules) {
      // Try search by ID first in the master account list
      AccountModel matchedAccount = _customers.firstWhere(
        (c) => c.id.toLowerCase() == s.customerId.toLowerCase(),
        orElse: () => _customers.firstWhere(
          (c) => c.displayName.toLowerCase() == (s.customerName?.toLowerCase() ?? ''),
          orElse: () => AccountModel( // Fallback if no account found in system
            id: s.customerId,
            email: '',
            username: s.customerName ?? 'Khách hàng',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            roleName: 'Customer',
            isEmailVerified: true,
          ),
        ),
      );
      
      if (!filteredList.any((c) => c.id == matchedAccount.id)) {
        filteredList.add(matchedAccount);
      }
    }

    setState(() {
      _staffSchedules = schedules;
      _availableFamilySchedules = availableSchedules;
      _filteredCustomers = filteredList;
      
      // If none matched from schedules but we have real customers, show all real customers
      // to avoid 404s when booking for customers who might not have a schedule entry yet
      if (_filteredCustomers.isEmpty) {
        _filteredCustomers = _customers;
      }

      // Keep selected customer if they are still available in the new list
      if (_selectedCustomer != null) {
        final stillAvailable = _filteredCustomers.any((c) => c.id == _selectedCustomer!.id);
        if (!stillAvailable) {
          _selectedCustomer = null;
          _selectedTime = null;
        } else {
          // Update available schedules for the selected customer
          _availableFamilySchedules = _staffSchedules
              .map((schedule) => schedule.familySchedule)
              .whereType<FamilyScheduleEntity>()
              .where((schedule) => schedule.customerId == _selectedCustomer!.id || 
                    (schedule.customerName != null && schedule.customerName == _selectedCustomer!.displayName))
              .toList();
        }
      }
    });
  }

  void _submit() {
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn khách hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một dịch vụ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày và giờ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_availableFamilySchedules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có lịch phân công phù hợp'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculate end time based on service duration (fallback to +30m if not available)
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

    // Combine date and time
    final dateStr = _formatDateOnly(_selectedDate!);
    final startTimeStr = _formatTimeOnly(_selectedTime!);
    
    // Dispatch create booking event
    context.read<AmenityTicketBloc>().add(
      CreateServiceBookingEvent(
        customerId: _selectedCustomer!.id,
        amenityServiceId: _selectedService!.id,
        date: dateStr,
        startTime: startTimeStr,
        endTime: endTimeStr,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return EmployeeScaffold(
        body: SafeArea(
          child: Column(
            children: [
              const EmployeeHeaderBar(
                title: 'Đặt dịch vụ',
                subtitle: 'Đặt dịch vụ tiện ích cho khách hàng',
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
                        } else if (state is StaffScheduleEmpty) {
                          _applyAvailableSchedules([]);
                        } else if (state is StaffScheduleError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
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
                          // Reset form
                          setState(() {
                            _selectedCustomer = null;
                            _selectedService = null;
                            _selectedDate = null;
                            _selectedDateRangeEnd = null;
                            _selectedTime = null;
                            _notesController.clear();
                            _availableFamilySchedules = [];
                            _staffSchedules = [];
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

                        // Tổng quan ngắn gọn booking
                        _buildSummaryCard(),
                        const SizedBox(height: 16),

                        // Customer Selection
                        _buildCardSection(
                          icon: Icons.person_outline,
                          title: 'Khách hàng',
                          child: _buildCustomerSelector(),
                        ),
                        const SizedBox(height: 16),

                        // Service Selection
                        _buildCardSection(
                          icon: Icons.room_service_outlined,
                          title: 'Dịch vụ tiện ích',
                          child: _buildServiceSelector(),
                        ),
                        const SizedBox(height: 16),

                        // Date Selection
                        _buildCardSection(
                          icon: Icons.calendar_today_outlined,
                          title: 'Ngày đặt',
                          child: _buildDateSelector(),
                        ),
                        const SizedBox(height: 16),

                        // Time Selection
                        _buildCardSection(
                          icon: Icons.access_time,
                          title: 'Giờ đặt',
                          child: _buildTimeSelector(),
                        ),
                        const SizedBox(height: 16),

                        // Notes
                        _buildCardSection(
                          icon: Icons.notes_outlined,
                          title: 'Ghi chú (Tùy chọn)',
                          child: TextField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Nhập ghi chú hoặc yêu cầu đặc biệt...',
                              filled: true,
                              fillColor: AppColors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        _buildSubmitButton(),
                        const SizedBox(height: 24),
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

  /// Card wrapper cho từng section để UI đồng nhất, dễ scan thông tin.
  Widget _buildCardSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
                child: Icon(
                  icon,
                  size: 18 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          child,
        ],
      ),
    );
  }

  /// Thẻ tóm tắt nhanh lựa chọn hiện tại (khách hàng, dịch vụ, thời gian).
  Widget _buildSummaryCard() {
    final scale = AppResponsive.scaleFactor(context);

    final hasCustomer = _selectedCustomer != null;
    final hasServices = _selectedService != null;
    final hasDateTime = _selectedDate != null && _selectedTime != null;

    if (!hasCustomer && !hasServices && !hasDateTime) {
      // Hint nhẹ khi chưa có lựa chọn nào
      return Container(
        padding: EdgeInsets.all(14 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14 * scale),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18 * scale,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Text(
                'Chọn khách hàng, dịch vụ và thời gian để đặt dịch vụ tiện ích.',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    String? timeText;
    if (hasDateTime) {
      final dt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      timeText = DateFormat('dd/MM/yyyy HH:mm').format(dt);
    }

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 20 * scale,
                color: AppColors.primary,
              ),
              SizedBox(width: 8 * scale),
              Text(
                'Tóm tắt đặt dịch vụ',
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          if (hasCustomer)
            Text(
              'Khách hàng: ${_selectedCustomer!.displayName} (${_selectedCustomer!.id})',
              style: AppTextStyles.arimo(
                fontSize: 13, // Removed scale variable as it might vary, using standard size
                color: AppColors.textPrimary,
              ),
            ),
          if (hasCustomer) const SizedBox(height: 6),
          if (hasServices)
            Text(
              'Dịch vụ: ${_selectedService!.name}',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textPrimary,
              ),
            ),
          if (hasServices) SizedBox(height: 6 * scale),
          if (timeText != null)
            Text(
              'Thời gian: $timeText',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textPrimary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCustomerSelector() {
    return InkWell(
      onTap: _selectedDate == null ? null : () => _showCustomerSelectionBottomSheet(),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedCustomer != null
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person,
              color: _selectedCustomer != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedCustomer == null
                  ? Text(
                      _selectedDate == null
                          ? 'Chọn ngày trước'
                          : 'Chọn khách hàng',
                      style: AppTextStyles.arimo(
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCustomer!.displayName,
                          style: AppTextStyles.arimo(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (_selectedCustomer!.phone != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _selectedCustomer!.phone!,
                            style: AppTextStyles.arimo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSelector() {
    return BlocBuilder<AmenityServiceBloc, AmenityServiceState>(
      builder: (context, state) {
        if (state is AmenityServiceLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AmenityServiceError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              state.message,
              style: AppTextStyles.arimo(color: Colors.red),
            ),
          );
        }

        if (state is AmenityServiceEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              'Không có dịch vụ nào',
              style: AppTextStyles.arimo(color: AppColors.textSecondary),
            ),
          );
        }

        if (state is AmenityServiceLoaded) {
          final services = state.services;

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedService != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Chip(
                      label: Text(_selectedService!.name),
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      labelStyle: AppTextStyles.arimo(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      onDeleted: () => setState(() => _selectedService = null),
                      deleteIconColor: AppColors.primary,
                    ),
                  ),
                ],
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final service = services[index];
                    final isSelected = _selectedService?.id == service.id;

                    return InkWell(
                      onTap: () => _toggleService(service),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: service.imageUrl != null
                                  ? Image.network(
                                      service.imageUrl!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          _buildPlaceholderImage(),
                                    )
                                  : _buildPlaceholderImage(),
                            ),
                            const SizedBox(width: 12),
                            // Service Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          service.name,
                                          style: AppTextStyles.arimo(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isSelected)
                                        const Icon(
                                          Icons.check_circle,
                                          color: AppColors.primary,
                                          size: 20,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    service.description ?? 'Dịch vụ tiện ích',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.arimo(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.background,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${service.duration ?? '30'} phút',
                                              style: AppTextStyles.arimo(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDate != null
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _selectedDate != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate != null
                    ? DateFormat('dd/MM/yyyy', 'vi').format(_selectedDate!)
                    : 'Chọn ngày',
                style: AppTextStyles.arimo(
                  color: _selectedDate != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (_isLoadingStaffSchedules)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: _selectedCustomer == null || _availableFamilySchedules.isEmpty
          ? null
          : _selectTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedTime != null
                ? AppColors.primary
                : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: _selectedTime != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedTime != null
                    ? _selectedTime!.format(context)
                    : _selectedCustomer == null
                    ? 'Chọn khách hàng trước'
                    : 'Chọn giờ',
                style: AppTextStyles.arimo(
                  color: _selectedTime != null
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AmenityTicketBloc, AmenityTicketState>(
      builder: (context, state) {
        final isLoading = state is AmenityTicketLoading;

        return ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Đặt dịch vụ',
                  style: AppTextStyles.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.background,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textSecondary,
        size: 30,
      ),
    );
  }

  void _showCustomerSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Chọn khách hàng',
                          style: AppTextStyles.arimo(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      _filterCustomers();
                      setModalState(() {});
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên, email, SĐT...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _isLoadingCustomers || _isLoadingStaffSchedules
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredCustomers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.person_search_outlined,
                                    size: 64,
                                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Không tìm thấy khách hàng',
                                    style: AppTextStyles.arimo(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredCustomers.length,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemBuilder: (context, index) {
                                final customer = _filteredCustomers[index];
                                final isSelected =
                                    _selectedCustomer?.id == customer.id;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(alpha: 0.05)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    leading: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      child: Text(
                                        customer.displayName[0].toUpperCase(),
                                        style: AppTextStyles.arimo(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      customer.displayName,
                                      style: AppTextStyles.arimo(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          customer.phone ?? customer.email,
                                          style: AppTextStyles.arimo(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          'ID: ${customer.id}',
                                          style: AppTextStyles.arimo(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ).copyWith(fontStyle: FontStyle.italic),
                                        ),
                                      ],
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle,
                                            color: AppColors.primary,
                                          )
                                        : const Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14,
                                            color: AppColors.borderLight,
                                          ),
                                    onTap: () {
                                      _selectCustomer(customer);
                                    },
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

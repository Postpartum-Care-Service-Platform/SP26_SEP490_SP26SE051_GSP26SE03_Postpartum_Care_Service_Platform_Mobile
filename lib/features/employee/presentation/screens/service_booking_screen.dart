// lib/features/employee/presentation/screens/service_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/models/account_model.dart';
import '../../domain/entities/amenity_service_entity.dart';
import '../bloc/amenity_service/amenity_service_bloc.dart';
import '../bloc/amenity_service/amenity_service_event.dart';
import '../bloc/amenity_service/amenity_service_state.dart';
import '../bloc/amenity_ticket/amenity_ticket_bloc.dart';
import '../bloc/amenity_ticket/amenity_ticket_event.dart';
import '../bloc/amenity_ticket/amenity_ticket_state.dart';
import '../widgets/employee_header_bar.dart';
import '../widgets/employee_scaffold.dart';

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
  TimeOfDay? _selectedTime;

  List<AccountModel> _customers = [];
  List<AccountModel> _filteredCustomers = [];
  List<AmenityServiceEntity> _selectedServices = [];

  bool _isLoadingCustomers = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final dataSource = AccountRemoteDataSource();
      final customers = await dataSource.getCustomers();
      setState(() {
        _customers = customers;
        _filteredCustomers = customers;
        _isLoadingCustomers = false;
      });
    } catch (e) {
      setState(() => _isLoadingCustomers = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách khách hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _selectCustomer(AccountModel customer) {
    setState(() {
      _selectedCustomer = customer;
      _searchController.text = customer.displayName;
    });
    Navigator.pop(context);
  }

  void _toggleService(AmenityServiceEntity service) {
    setState(() {
      if (_selectedServices.any((s) => s.id == service.id)) {
        _selectedServices.removeWhere((s) => s.id == service.id);
      } else {
        _selectedServices.add(service);
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

    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một dịch vụ'),
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

    // Combine date and time
    final startTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // End time: start time + 1 hour (default duration)
    final endTime = startTime.add(const Duration(hours: 1));

    // Get service IDs
    final serviceIds = _selectedServices.map((s) => s.id).toList();

    // Dispatch create booking event
    context.read<AmenityTicketBloc>().add(
      CreateServiceBookingEvent(
        customerId: _selectedCustomer!.id,
        serviceIds: serviceIds,
        startTime: startTime,
        endTime: endTime,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              InjectionContainer.amenityServiceBloc
                ..add(const LoadActiveAmenityServices()),
        ),
        BlocProvider(create: (context) => InjectionContainer.amenityTicketBloc),
      ],
      child: EmployeeScaffold(
        body: SafeArea(
          child: Column(
            children: [
              const EmployeeHeaderBar(
                title: 'Đặt dịch vụ',
                subtitle: 'Đặt dịch vụ tiện ích cho khách hàng',
              ),
              Expanded(
                child: BlocListener<AmenityTicketBloc, AmenityTicketState>(
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
                        _selectedServices = [];
                        _selectedDate = null;
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
    final hasServices = _selectedServices.isNotEmpty;
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
              'Khách hàng: ${_selectedCustomer!.displayName}',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textPrimary,
              ),
            ),
          if (hasCustomer) SizedBox(height: 6 * scale),
          if (hasServices)
            Text(
              'Dịch vụ đã chọn: ${_selectedServices.length}',
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
      onTap: () => _showCustomerSearchDialog(),
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
                      'Chọn khách hàng',
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
                if (_selectedServices.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedServices.map((service) {
                      return Chip(
                        label: Text(service.name),
                        onDeleted: () => _toggleService(service),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        deleteIconColor: AppColors.primary,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: services.map((service) {
                    final isSelected = _selectedServices.any(
                      (s) => s.id == service.id,
                    );
                    return InkWell(
                      onTap: () => _toggleService(service),
                      child: Container(
                        width: 220,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: AppTextStyles.arimo(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    service.description ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.arimo(
                                      fontSize: 11,
                                      color: isSelected
                                          ? AppColors.white.withValues(
                                              alpha: 0.85,
                                            )
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Có thể bổ sung thêm thời lượng / giá dịch vụ nếu BE trả về
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: _selectTime,
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

  void _showCustomerSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Chọn khách hàng',
                        style: AppTextStyles.arimo(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm theo tên, email, số điện thoại...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderLight),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoadingCustomers
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCustomers.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy khách hàng',
                          style: AppTextStyles.arimo(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredCustomers.length,
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                customer.displayName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(customer.displayName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customer.email),
                                if (customer.phone != null)
                                  Text(customer.phone!),
                              ],
                            ),
                            onTap: () => _selectCustomer(customer),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

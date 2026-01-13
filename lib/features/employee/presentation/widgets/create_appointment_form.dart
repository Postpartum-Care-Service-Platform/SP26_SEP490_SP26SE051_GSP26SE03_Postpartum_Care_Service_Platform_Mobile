// lib/features/employee/presentation/widgets/create_appointment_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../data/models/account_model.dart';
import '../../domain/entities/room_entity.dart';
import '../bloc/appointment/appointment_bloc.dart';
import '../bloc/appointment/appointment_event.dart';
import '../bloc/appointment/appointment_state.dart';
import '../bloc/room/room_bloc.dart';
import '../bloc/room/room_event.dart';
import '../bloc/room/room_state.dart';

/// Create Appointment Form Widget
/// Allows staff to create appointment for customer
class CreateAppointmentForm extends StatefulWidget {
  const CreateAppointmentForm({super.key});

  @override
  State<CreateAppointmentForm> createState() => _CreateAppointmentFormState();
}

class _CreateAppointmentFormState extends State<CreateAppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  
  AccountModel? _selectedCustomer;
  RoomEntity? _selectedRoom;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  List<AccountModel> _customers = [];
  List<AccountModel> _filteredCustomers = [];
  List<RoomEntity> _availableRooms = [];
  
  bool _isLoadingCustomers = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _loadRooms();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
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

  void _loadRooms() {
    context.read<RoomBloc>().add(const LoadAvailableRooms());
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
    Navigator.pop(context); // Close search dialog
  }

  void _selectRoom(RoomEntity room) {
    setState(() => _selectedRoom = room);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn khách hàng'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ngày và giờ hẹn'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Combine date and time
    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    setState(() => _isSubmitting = true);

    // Dispatch create appointment event
    context.read<AppointmentBloc>().add(
      CreateAppointmentForCustomerEvent(
        customerId: _selectedCustomer!.id,
        appointmentDate: appointmentDateTime,
        name: _nameController.text.trim().isEmpty 
            ? null 
            : _nameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppointmentBloc, AppointmentState>(
      listener: (context, state) {
        if (state is AppointmentCreated) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context); // Close form
        } else if (state is AppointmentError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Selection
              _buildSectionTitle('Khách hàng'),
              const SizedBox(height: 8),
              _buildCustomerSelector(),
              const SizedBox(height: 16),

              // Date Selection
              _buildSectionTitle('Ngày hẹn'),
              const SizedBox(height: 8),
              _buildDateSelector(),
              const SizedBox(height: 16),

              // Time Selection
              _buildSectionTitle('Giờ hẹn'),
              const SizedBox(height: 8),
              _buildTimeSelector(),
              const SizedBox(height: 16),

              // Room Selection (Optional)
              _buildSectionTitle('Phòng (Tùy chọn)'),
              const SizedBox(height: 8),
              _buildRoomSelector(),
              const SizedBox(height: 16),

              // Name/Notes
              _buildSectionTitle('Ghi chú (Tùy chọn)'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú hoặc tên lịch hẹn...',
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
              const SizedBox(height: 24),

              // Submit Button
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.arimo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
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
            Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
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

  Widget _buildRoomSelector() {
    return BlocBuilder<RoomBloc, RoomState>(
      builder: (context, state) {
        if (state is RoomLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is RoomLoaded) {
          _availableRooms = state.rooms;
        }

        if (_availableRooms.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              'Không có phòng trống',
              style: AppTextStyles.arimo(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableRooms.map((room) {
              final isSelected = _selectedRoom?.id == room.id;
              return InkWell(
                onTap: () => _selectRoom(room),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary 
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected 
                          ? AppColors.primary 
                          : AppColors.borderLight,
                    ),
                  ),
                  child: Text(
                    room.name,
                    style: AppTextStyles.arimo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                          ? AppColors.white 
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final isLoading = state is AppointmentLoading || _isSubmitting;
        
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
                  'Tạo lịch hẹn',
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            children: [
              // Header
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
              // Search field
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
              // Customer list
              Expanded(
                child: _isLoadingCustomers
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
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

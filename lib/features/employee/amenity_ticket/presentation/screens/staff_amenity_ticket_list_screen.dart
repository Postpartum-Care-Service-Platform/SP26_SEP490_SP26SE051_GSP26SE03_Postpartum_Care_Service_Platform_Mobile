// lib/features/employee/presentation/screens/staff_amenity_ticket_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';  
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/employee/account/data/datasources/account_remote_datasource.dart';
import '../../../../../features/employee/account/data/models/account_model.dart';
import '../../../../../features/employee/amenity_ticket/domain/entities/amenity_ticket_entity.dart';
import '../../domain/entities/amenity_ticket_status.dart';
import '../../../../../features/employee/amenity_ticket/presentation/bloc/amenity_ticket/amenity_ticket_bloc.dart';
import '../../../../../features/employee/amenity_ticket/presentation/bloc/amenity_ticket/amenity_ticket_event.dart';
import '../../../../../features/employee/amenity_ticket/presentation/bloc/amenity_ticket/amenity_ticket_state.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_header_bar.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';  
import '../../../../../features/services/data/datasources/staff_schedule_remote_datasource.dart';

/// Màn hình danh sách ticket tiện ích cho staff
/// Cho phép staff xem, cập nhật, hủy ticket
class StaffAmenityTicketListScreen extends StatefulWidget {
  final AccountModel? selectedCustomer;
  final VoidCallback? onBackToDefaultStaffPage;

  const StaffAmenityTicketListScreen({
    super.key,
    this.selectedCustomer,
    this.onBackToDefaultStaffPage,
  });

  @override
  State<StaffAmenityTicketListScreen> createState() =>
      _StaffAmenityTicketListScreenState();
}

class _StaffAmenityTicketListScreenState
    extends State<StaffAmenityTicketListScreen> {
  AccountModel? _selectedCustomer;
  List<AccountModel> _customers = [];
  bool _isLoadingCustomers = false;

  @override
  void initState() {
    super.initState();
    _selectedCustomer = widget.selectedCustomer;
    _loadCustomers();
    if (_selectedCustomer != null) {
      _loadTickets();
    }
  }

  String _formatDateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      // Get customers from staff schedules as requested
      final now = DateTime.now();
      final from = _formatDateOnly(now);
      // "2 ngày" includes today and tomorrow
      final to = _formatDateOnly(now.add(const Duration(days: 1)));
      
      final dataSource = StaffScheduleRemoteDataSourceImpl();
      final schedules = await dataSource.getMySchedulesByDateRange(from: from, to: to);
      
      if (!mounted) return;
      
      final Map<String, AccountModel> customerMap = {};
      final nowTime = DateTime.now();

      for (final schedule in schedules) {
        if (schedule.familySchedule != null) {
          final s = schedule.familySchedule!;
          customerMap[s.customerId] = AccountModel(
            id: s.customerId,
            email: '', 
            username: s.customerName ?? 'Khách hàng',
            isActive: true,
            createdAt: nowTime,
            updatedAt: nowTime,
            roleName: 'Customer',
            isEmailVerified: true,
          );
        }
      }

      setState(() {
        _customers = customerMap.values.toList();
        _isLoadingCustomers = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingCustomers = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải danh sách khách hàng từ lịch phân công: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadTickets() {
    if (_selectedCustomer != null) {
      context.read<AmenityTicketBloc>().add(
        LoadTicketsByCustomer(_selectedCustomer!.id),
      );
    }
  }

  void _selectCustomer(AccountModel customer) {
    setState(() {
      _selectedCustomer = customer;
    });
    _loadTickets();
  }

  void _showCustomerSelectionBottomSheet() {
    bool isSearching = false;
    final TextEditingController searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            
            Future<void> searchCustomerByPhone(String phone) async {
              if (phone.trim().isEmpty) return;
              
              String formattedPhone = phone.trim();
              if (formattedPhone.startsWith('0')) {
                formattedPhone = '+84${formattedPhone.substring(1)}';
              }

              setBottomSheetState(() => isSearching = true);
              
              try {
                final dataSource = AccountRemoteDataSource();
                final account = await dataSource.getAccountByPhone(formattedPhone);
                
                if (!mounted) return;
                
                if (account != null) {
                  // Check if this customer is already in the global _customers list
                  final index = _customers.indexWhere((c) => c.id == account.id);
                  if (index == -1) {
                    setState(() {
                      _customers.insert(0, account);
                    });
                  } else {
                    setState(() {
                      _customers[index] = account; // update in case
                    });
                  }
                  
                  _selectCustomer(account);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không tìm thấy khách hàng với số điện thoại này'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Không tìm thấy khách hàng hoặc có lỗi xảy ra'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setBottomSheetState(() => isSearching = false);
                }
              }
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
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
                        ),
                      ],
                    ),
                  ),
                  
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (value) => searchCustomerByPhone(value),
                      decoration: InputDecoration(
                        hintText: 'Nhập / dán SĐT (vd: 0912345678)',
                        hintStyle: AppTextStyles.arimo(color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primary),
                          onPressed: () => searchCustomerByPhone(searchController.text),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: isSearching || _isLoadingCustomers
                        ? const Center(child: CircularProgressIndicator())
                        : _customers.isEmpty
                            ? Center(
                                child: Text(
                                  'Không có khách hàng',
                                  style: AppTextStyles.arimo(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _customers.length,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                itemBuilder: (context, index) {
                                  final customer = _customers[index];
                                  final isSelected =
                                      _selectedCustomer?.id == customer.id;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary.withValues(alpha: 0.05)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                                        width: isSelected ? 1 : 0.5,
                                      )
                                    ),
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        child: Text(
                                          customer.displayName.isNotEmpty ? customer.displayName[0].toUpperCase() : 'K',
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
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      subtitle: Text(
                                        customer.phone ?? customer.email,
                                        style: AppTextStyles.arimo(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? const Icon(
                                              Icons.check_circle,
                                              color: AppColors.primary,
                                            )
                                          : null,
                                      onTap: () {
                                        _selectCustomer(customer);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return BlocProvider(
      create: (context) => InjectionContainer.amenityTicketBloc,
      child: EmployeeScaffold(
        body: SafeArea(
          child: Column(
            children: [
              EmployeeHeaderBar(
                title: 'Phiếu dịch vụ',
                subtitle: 'Quản lý phiếu dịch vụ tiện ích',
                showBackButton: true,
                onBack: widget.onBackToDefaultStaffPage,
              ),
              // Customer selector
              Container(
                padding: padding,
                child: InkWell(
                  onTap: _showCustomerSelectionBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
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
                ),
              ),
              // Tickets list
              Expanded(
                child: _selectedCustomer == null
                    ? Center(
                        child: Text(
                          'Vui lòng chọn khách hàng để xem phiếu dịch vụ',
                          style: AppTextStyles.arimo(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : BlocListener<AmenityTicketBloc, AmenityTicketState>(
                        listener: (context, state) {
                          if (state is AmenityTicketActionSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                            _loadTickets();
                          } else if (state is AmenityTicketError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child:
                            BlocBuilder<AmenityTicketBloc, AmenityTicketState>(
                              builder: (context, state) {
                                if (state is AmenityTicketLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (state is AmenityTicketError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          state.message,
                                          style: AppTextStyles.arimo(
                                            color: Colors.red,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: _loadTickets,
                                          child: const Text('Thử lại'),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (state is AmenityTicketEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.receipt_long,
                                          size: 64,
                                          color: AppColors.textSecondary,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Không có phiếu dịch vụ',
                                          style: AppTextStyles.arimo(
                                            fontSize: 16,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (state is AmenityTicketLoaded) {
                                  return RefreshIndicator(
                                    onRefresh: () async => _loadTickets(),
                                    child: ListView.builder(
                                      padding: padding,
                                      itemCount: state.tickets.length,
                                      itemBuilder: (context, index) {
                                        final ticket = state.tickets[index];
                                        return _buildTicketCard(ticket);
                                      },
                                    ),
                                  );
                                }

                                return const SizedBox();
                              },
                            ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(AmenityTicketEntity ticket) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'vi');
    final statusColor = _getStatusColor(ticket.status);
    final statusText = _getStatusText(ticket.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.amenityService?.name ??
                          'Dịch vụ #${ticket.amenityServiceId}',
                      style: AppTextStyles.arimo(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: #${ticket.id}',
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${dateFormat.format(ticket.startTime)} - ${dateFormat.format(ticket.endTime)}',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (ticket.customerName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  ticket.customerName!,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (ticket.status != AmenityTicketStatus.cancelled &&
                  ticket.status != AmenityTicketStatus.completed)
                TextButton.icon(
                  onPressed: () => _showUpdateDialog(ticket),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Cập nhật'),
                ),
              if (ticket.status != AmenityTicketStatus.cancelled &&
                  ticket.status != AmenityTicketStatus.completed)
                TextButton.icon(
                  onPressed: () => _showCancelDialog(ticket),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Hủy'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(AmenityTicketEntity ticket) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: Text('Bạn có chắc chắn muốn hủy phiếu dịch vụ #${ticket.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AmenityTicketBloc>().add(
                CancelTicketEvent(ticket.id),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy phiếu'),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(AmenityTicketEntity ticket) {
    // Có thể navigate sang màn hình update hoặc show bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng cập nhật đang được phát triển')),
    );
  }

  Color _getStatusColor(AmenityTicketStatus status) {
    switch (status) {
      case AmenityTicketStatus.booked:
        return Colors.blue;
      case AmenityTicketStatus.completed:
        return Colors.green;
      case AmenityTicketStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(AmenityTicketStatus status) {
    switch (status) {
      case AmenityTicketStatus.booked:
        return 'Đã đặt';
      case AmenityTicketStatus.completed:
        return 'Hoàn thành';
      case AmenityTicketStatus.cancelled:
        return 'Đã hủy';
    }
  }
}

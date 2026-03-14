// lib/features/employee/presentation/screens/staff_amenity_ticket_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../data/models/account_model.dart';
import '../../data/datasources/account_remote_datasource.dart';
import '../../domain/entities/amenity_ticket_entity.dart';
import '../../domain/entities/amenity_ticket_status.dart';
import '../bloc/amenity_ticket/amenity_ticket_bloc.dart';
import '../bloc/amenity_ticket/amenity_ticket_event.dart';
import '../bloc/amenity_ticket/amenity_ticket_state.dart';
import '../widgets/employee_header_bar.dart';
import '../widgets/employee_scaffold.dart';

/// Màn hình danh sách ticket tiện ích cho staff
/// Cho phép staff xem, cập nhật, hủy ticket
class StaffAmenityTicketListScreen extends StatefulWidget {
  final AccountModel? selectedCustomer;

  const StaffAmenityTicketListScreen({super.key, this.selectedCustomer});

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

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    try {
      final dataSource = AccountRemoteDataSource();
      final customers = await dataSource.getCustomers();
      setState(() {
        _customers = customers;
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

  void _showCustomerSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn khách hàng'),
        content: SizedBox(
          width: double.maxFinite,
          child: _isLoadingCustomers
              ? const Center(child: CircularProgressIndicator())
              : _customers.isEmpty
              ? const Text('Không có khách hàng')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _customers.length,
                  itemBuilder: (context, index) {
                    final customer = _customers[index];
                    return ListTile(
                      title: Text(customer.displayName),
                      subtitle: Text(customer.email),
                      onTap: () {
                        _selectCustomer(customer);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
      ),
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
              ),
              // Customer selector
              Container(
                padding: padding,
                child: InkWell(
                  onTap: _showCustomerSelector,
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
    // TODO: Implement update dialog
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

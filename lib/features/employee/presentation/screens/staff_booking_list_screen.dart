import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../../booking/data/models/booking_model.dart';
import 'staff_contract_screen.dart';
import '../../../../core/di/injection_container.dart';
import 'employee_offline_payment_screen.dart';

class StaffBookingListScreen extends StatefulWidget {
  const StaffBookingListScreen({super.key});

  @override
  State<StaffBookingListScreen> createState() => _StaffBookingListScreenState();
}

class _StaffBookingListScreenState extends State<StaffBookingListScreen> {
  final _dataSource = BookingRemoteDataSourceImpl(dio: ApiClient.dio);

  late Future<List<BookingModel>> _futureBookings = _loadBookings();

  String _statusFilter = 'all';
  bool _isActionInProgress = false;
  
  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _packageFilter;
  bool _showFilters = false;

  Future<List<BookingModel>> _loadBookings() async {
    final all = await _dataSource.getAllBookings();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  Future<void> _refresh() async {
    setState(() {
      _futureBookings = _loadBookings();
    });
    await _futureBookings;
  }

  Future<void> _handleConfirm(BookingModel booking) async {
    if (_isActionInProgress) return;
    setState(() => _isActionInProgress = true);
    try {
      final message = await _dataSource.confirmBooking(booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi xác nhận booking: $e',
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isActionInProgress = false);
    }
  }

  Future<void> _handleComplete(BookingModel booking) async {
    if (_isActionInProgress) return;
    setState(() => _isActionInProgress = true);
    try {
      final message = await _dataSource.completeBooking(booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi hoàn thành booking: $e',
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isActionInProgress = false);
    }
  }

  List<BookingModel> _applyFilter(List<BookingModel> bookings) {
    var filtered = bookings;

    // Status filter
    if (_statusFilter != 'all') {
      filtered = filtered
          .where((b) => b.status.toLowerCase() == _statusFilter)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((b) {
        final customerName = b.customer?.username.toLowerCase() ?? '';
        final customerEmail = b.customer?.email.toLowerCase() ?? '';
        final customerPhone = b.customer?.phone.toLowerCase() ?? '';
        final packageName = b.package?.packageName.toLowerCase() ?? '';
        final bookingId = '#${b.id}'.toLowerCase();
        
        return customerName.contains(query) ||
            customerEmail.contains(query) ||
            customerPhone.contains(query) ||
            packageName.contains(query) ||
            bookingId.contains(query);
      }).toList();
    }

    // Date range filter
    if (_dateFrom != null) {
      filtered = filtered.where((b) {
        final bookingDate = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
        return bookingDate.isAfter(_dateFrom!.subtract(const Duration(days: 1))) ||
            bookingDate.isAtSameMomentAs(DateTime(_dateFrom!.year, _dateFrom!.month, _dateFrom!.day));
      }).toList();
    }

    if (_dateTo != null) {
      filtered = filtered.where((b) {
        final bookingDate = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
        return bookingDate.isBefore(_dateTo!.add(const Duration(days: 1))) ||
            bookingDate.isAtSameMomentAs(DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day));
      }).toList();
    }

    // Package filter
    if (_packageFilter != null && _packageFilter!.isNotEmpty) {
      filtered = filtered.where((b) {
        return b.package?.packageName.toLowerCase() == _packageFilter!.toLowerCase();
      }).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = 'all';
      _dateFrom = null;
      _dateTo = null;
      _packageFilter = null;
    });
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_statusFilter != 'all') count++;
    if (_searchQuery.isNotEmpty) count++;
    if (_dateFrom != null) count++;
    if (_dateTo != null) count++;
    if (_packageFilter != null && _packageFilter!.isNotEmpty) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Danh sách Booking',
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                icon: const Icon(Icons.filter_list),
              ),
              if (_getActiveFilterCount() > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_getActiveFilterCount()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            onPressed: _isActionInProgress ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(scale),
            if (_showFilters) _buildAdvancedFilters(scale),
            _buildFilterBar(scale),
            Expanded(
              child: FutureBuilder<List<BookingModel>>(
                future: _futureBookings,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24 * scale),
                        child: Text(
                          'Lỗi tải danh sách booking: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  final all = snapshot.data ?? const [];
                  final bookings = _applyFilter(all);

                  if (bookings.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24 * scale),
                        child: Text(
                          'Không có booking nào.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.separated(
                      padding: EdgeInsets.all(16 * scale),
                      itemCount: bookings.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
                      itemBuilder: (context, index) {
                        final booking = bookings[index];
                        return _BookingItem(
                          booking: booking,
                          onConfirm: booking.status.toLowerCase() == 'pending'
                              ? () => _handleConfirm(booking)
                              : null,
                          onComplete:
                              booking.status.toLowerCase() == 'confirmed'
                              ? () => _handleComplete(booking)
                              : null,
                          onRecordOfflinePayment: () async {
                            final bookingBloc = InjectionContainer.bookingBloc;
                            final entity = booking.toEntity();
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: bookingBloc,
                                  child: EmployeeOfflinePaymentScreen(
                                    booking: entity,
                                  ),
                                ),
                              ),
                            );
                            if (result == true) {
                              await _refresh();
                            }
                          },
                          onViewContract:
                              booking.status.toLowerCase() == 'confirmed' ||
                                  booking.status.toLowerCase() == 'completed'
                              ? () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StaffContractScreen(booking: booking),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        8 * scale,
        16 * scale,
        8 * scale,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên, email, SĐT, gói dịch vụ...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12 * scale),
            borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 12 * scale,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildAdvancedFilters(double scale) {
    return Container(
      margin: EdgeInsets.fromLTRB(16 * scale, 0, 16 * scale, 8 * scale),
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bộ lọc nâng cao',
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: Text(
                  'Xóa bộ lọc',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          // Date range
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateFrom ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _dateFrom = date;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: Text(
                            _dateFrom == null
                                ? 'Từ ngày'
                                : '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: _dateFrom == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_dateFrom != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _dateFrom = null;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 16 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dateTo ?? DateTime.now(),
                      firstDate: _dateFrom ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _dateTo = date;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: Text(
                            _dateTo == null
                                ? 'Đến ngày'
                                : '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: _dateTo == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_dateTo != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _dateTo = null;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              size: 16 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        8 * scale,
        16 * scale,
        4 * scale,
      ),
      child: Row(
        children: [
          Text(
            'Trạng thái:',
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<String>(
              value: _statusFilter,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _statusFilter = value;
                });
              },
            ),
          ),
          if (_getActiveFilterCount() > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8 * scale,
                vertical: 4 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Text(
                '${_getActiveFilterCount()} bộ lọc',
                style: AppTextStyles.arimo(
                  fontSize: 11 * scale,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _BookingItem extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onRecordOfflinePayment;
  final VoidCallback? onViewContract;

  const _BookingItem({
    required this.booking,
    this.onConfirm,
    this.onComplete,
    this.onRecordOfflinePayment,
    this.onViewContract,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    final status = booking.status;
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFF97316); // orange
        break;
      case 'confirmed':
        statusColor = const Color(0xFF2563EB); // blue
        break;
      case 'completed':
        statusColor = const Color(0xFF16A34A); // green
        break;
      case 'cancelled':
        statusColor = const Color(0xFFDC2626); // red
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    final customerName = booking.customer?.username.isNotEmpty == true
        ? booking.customer!.username
        : (booking.customer?.email ?? 'Khách hàng');
    final packageName = booking.package?.packageName ?? 'Gói dịch vụ';

    return Container(
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
      padding: EdgeInsets.all(14 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                '#${booking.id}',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Text(
            packageName,
            style: AppTextStyles.arimo(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            customerName,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14 * scale,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6 * scale),
              Text(
                '${booking.startDate.day}/${booking.startDate.month}/${booking.startDate.year}',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 14 * scale,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6 * scale),
              Text(
                '${booking.finalAmount.toStringAsFixed(0)} đ',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (onConfirm != null ||
              onComplete != null ||
              onRecordOfflinePayment != null ||
              onViewContract != null) ...[
            SizedBox(height: 10 * scale),
            Row(
              children: [
                if (onConfirm != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onConfirm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Xác nhận'),
                    ),
                  ),
                if ((onConfirm != null && onComplete != null) ||
                    (onConfirm != null && onRecordOfflinePayment != null))
                  SizedBox(width: 8 * scale),
                if (onComplete != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onComplete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF16A34A),
                        side: const BorderSide(color: Color(0xFF16A34A)),
                      ),
                      icon: const Icon(Icons.done_all, size: 18),
                      label: const Text('Hoàn thành'),
                    ),
                  ),
                if (onRecordOfflinePayment != null) SizedBox(width: 8 * scale),
                if (onRecordOfflinePayment != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRecordOfflinePayment,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF9333EA),
                        side: const BorderSide(color: Color(0xFF9333EA)),
                      ),
                      icon: const Icon(Icons.payments, size: 18),
                      label: const Text('Thanh toán offline'),
                    ),
                  ),
                if (onViewContract != null) SizedBox(width: 8 * scale),
                if (onViewContract != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewContract,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F766E),
                        side: const BorderSide(color: Color(0xFF0F766E)),
                      ),
                      icon: const Icon(Icons.description_outlined, size: 18),
                      label: const Text('Hợp đồng'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

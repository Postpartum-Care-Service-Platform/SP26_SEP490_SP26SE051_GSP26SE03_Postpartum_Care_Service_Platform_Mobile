import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../../../../features/booking/data/models/booking_model.dart';
import '../../../../../features/employee/contract/presentation/screens/staff_contract_screen.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../features/employee/booking/presentation/screens/employee_offline_payment_screen.dart';

class StaffBookingListScreen extends StatefulWidget {
  final bool useHomeStaffBookings;

  const StaffBookingListScreen({
    super.key,
    this.useHomeStaffBookings = false,
  });

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
    final all = widget.useHomeStaffBookings
        ? await _dataSource.getBookingsByHomeStaff()
        : await _dataSource.getAllBookings();
    all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return all;
  }

  Future<void> _refresh() async {
    setState(() {
      _futureBookings = _loadBookings();
    });
    await _futureBookings;
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required Color color,
    IconData icon = Icons.help_outline_rounded,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arimo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Quay lại',
                            style: AppTextStyles.arimo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Xác nhận',
                            style: AppTextStyles.arimo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  Future<void> _handleConfirm(BookingModel booking) async {
    if (_isActionInProgress) return;
    
    final confirmed = await _showConfirmDialog(
      title: 'Xác nhận Booking',
      message: 'Bạn có chắc chắn muốn xác nhận gói dịch vụ này?',
      color: const Color(0xFF2563EB),
    );
    if (!confirmed) return;

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
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  Future<void> _handleCancel(BookingModel booking) async {
    if (_isActionInProgress) return;

    final confirmed = await _showConfirmDialog(
      title: 'Hủy Booking',
      message: 'Hành động này sẽ hủy hoàn toàn gói dịch vụ. Tiếp tục?',
      color: const Color(0xFFDC2626),
    );
    if (!confirmed) return;

    setState(() => _isActionInProgress = true);
    try {
      final message = await _dataSource.cancelBooking(booking.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      await _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi hủy booking: $e',
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  Future<void> _handleComplete(BookingModel booking) async {
    if (_isActionInProgress) return;

    final confirmed = await _showConfirmDialog(
      title: 'Hoàn thành Gói',
      message: 'Bạn xác nhận khách đã sử dụng hết dịch vụ và muốn kết thúc booking này?',
      color: const Color(0xFF16A34A),
    );
    if (!confirmed) return;

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
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
    }
  }

  Future<void> _handleCheckIn(BookingModel booking) async {
    if (_isActionInProgress) return;

    final confirmed = await _showConfirmDialog(
      title: 'Check-in Khách',
      message: 'Xác nhận khách hàng đã đến trung tâm và bắt đầu sử dụng dịch vụ?',
      color: const Color(0xFF0D9488), // teal color for check-in
    );
    if (!confirmed) return;

    setState(() => _isActionInProgress = true);
    try {
      final message = await _dataSource.checkInBooking(booking.id);
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
            'Lỗi check-in booking: $e',
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isActionInProgress = false);
      }
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
        title: widget.useHomeStaffBookings
            ? 'Booking của tôi'
            : 'Danh sách Booking',
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
                          onCancel: booking.status.toLowerCase() == 'pending'
                              ? () => _handleCancel(booking)
                              : null,
                          onConfirm: booking.status.toLowerCase() == 'pending'
                              ? () => _handleConfirm(booking)
                              : null,
                          onComplete: ['confirmed', 'in_progress', 'active', 'checked_in'].contains(booking.status.toLowerCase()) &&
                                  booking.remainingAmount <= 0
                              ? () => _handleComplete(booking)
                              : null,
                          onCheckIn: booking.status.toLowerCase() == 'confirmed'
                              ? () => _handleCheckIn(booking)
                              : null,
                           onRecordOfflinePayment: !['completed', 'cancelled'].contains(booking.status.toLowerCase())
                              ? () async {
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
                                }
                              : null,
                          onViewContract:
                              ['confirmed', 'in_progress', 'active', 'checked_in', 'completed'].contains(booking.status.toLowerCase())
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
        12 * scale,
        16 * scale,
        8 * scale,
      ),
      child: Container(
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
        child: TextField(
          controller: _searchController,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Tìm theo tên, SĐT, gói dịch vụ...',
            hintStyle: AppTextStyles.arimo(
              fontSize: 14 * scale,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 22 * scale,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.cancel_rounded, size: 20 * scale),
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _searchController.clear();
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 14 * scale,
            ),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
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
    final statusOptions = [
      {'value': 'all', 'label': 'Tất cả'},
      {'value': 'pending', 'label': 'Chờ xử lý'},
      {'value': 'confirmed', 'label': 'Đã xác nhận'},
      {'value': 'in_progress', 'label': 'Đang thực hiện'},
      {'value': 'completed', 'label': 'Đã hoàn thành'},
      {'value': 'cancelled', 'label': 'Đã hủy'},
    ];

    return Container(
      height: 48 * scale,
      margin: EdgeInsets.only(bottom: 8 * scale),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        itemCount: statusOptions.length,
        itemBuilder: (context, index) {
          final option = statusOptions[index];
          final isSelected = _statusFilter == option['value'];
          
          return Padding(
            padding: EdgeInsets.only(right: 8 * scale),
            child: ChoiceChip(
              label: Text(
                option['label']!,
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _statusFilter = option['value']!;
                  });
                }
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              checkmarkColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25 * scale),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              pressElevation: 4,
            ),
          );
        },
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
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onCheckIn;
  final VoidCallback? onRecordOfflinePayment;
  final VoidCallback? onViewContract;

  const _BookingItem({
    required this.booking,
    this.onCancel,
    this.onConfirm,
    this.onComplete,
    this.onCheckIn,
    this.onRecordOfflinePayment,
    this.onViewContract,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    final status = booking.status;
    Color statusColor;
    String statusIcon;
    switch (status.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFF97316); // orange
        statusIcon = 'wait';
        break;
      case 'confirmed':
        statusColor = const Color(0xFF2563EB); // blue
        statusIcon = 'check';
        break;
      case 'in_progress':
        statusColor = const Color(0xFF0D9488); // teal
        statusIcon = 'in_progress';
        break;
      case 'completed':
        statusColor = const Color(0xFF16A34A); // green
        statusIcon = 'done';
        break;
      case 'cancelled':
        statusColor = const Color(0xFFDC2626); // red
        statusIcon = 'cancel';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusIcon = 'info';
    }

    final String customerName = booking.customer?.username.isNotEmpty == true
        ? booking.customer!.username
        : (booking.customer?.email ?? 'Khách hàng');
    final String packageName = booking.package?.packageName ?? 'Gói dịch vụ';
    final String bookingDate = '${booking.startDate.day}/${booking.startDate.month}/${booking.startDate.year}';
    final String price = '${booking.finalAmount.toStringAsFixed(0)} đ';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
        border: Border.all(
          color: statusColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20 * scale),
        child: Column(
          children: [
            // Header Row
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
              color: statusColor.withValues(alpha: 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconForStatus(statusIcon),
                          size: 14 * scale,
                          color: statusColor,
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      Text(
                        '#${booking.id}',
                        style: AppTextStyles.arimo(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      _getStatusDisplayText(status),
                      style: AppTextStyles.arimo(
                        fontSize: 10 * scale,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Body Content
            Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    packageName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Row(
                    children: [
                      _buildInfoItem(
                        icon: Icons.person_outline_rounded,
                        label: customerName,
                        scale: scale,
                      ),
                      SizedBox(width: 16 * scale),
                      _buildInfoItem(
                        icon: Icons.calendar_today_rounded,
                        label: bookingDate,
                        scale: scale,
                      ),
                    ],
                  ),
                  if (booking.customer?.phone != null) ...[
                    SizedBox(height: 8 * scale),
                    _buildInfoItem(
                      icon: Icons.phone_iphone_rounded,
                      label: booking.customer!.phone,
                      scale: scale,
                    ),
                  ],
                  SizedBox(height: 14 * scale),
                  const Divider(height: 1),
                  SizedBox(height: 14 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng cộng',
                            style: AppTextStyles.arimo(
                              fontSize: 11 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            price,
                            style: AppTextStyles.arimo(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      // Collapsed action buttons logic
                      if (onConfirm != null || onComplete != null || onCheckIn != null || onRecordOfflinePayment != null || onViewContract != null)
                        Row(
                          children: [
                            if (onCancel != null)
                              _CircularActionButton(
                                icon: Icons.close_rounded,
                                color: const Color(0xFFDC2626),
                                onTap: onCancel!,
                                scale: scale,
                                tooltip: 'Hủy',
                              ),
                            if (onConfirm != null) ...[
                              SizedBox(width: 10 * scale),
                              _CircularActionButton(
                                icon: Icons.check_rounded,
                                color: const Color(0xFF2563EB),
                                onTap: onConfirm!,
                                scale: scale,
                                tooltip: 'Xác nhận',
                              ),
                            ],
                            if (onCheckIn != null) ...[
                              SizedBox(width: 10 * scale),
                              _CircularActionButton(
                                icon: Icons.login_rounded,
                                color: const Color(0xFF0D9488),
                                onTap: onCheckIn!,
                                scale: scale,
                                tooltip: 'Check-in',
                              ),
                            ],
                            if (onComplete != null) ...[
                              SizedBox(width: 10 * scale),
                              _CircularActionButton(
                                icon: Icons.done_all_rounded,
                                color: const Color(0xFF16A34A),
                                onTap: onComplete!,
                                scale: scale,
                                tooltip: 'Hoàn thành',
                              ),
                            ],
                            if (onRecordOfflinePayment != null || onViewContract != null) ...[
                               SizedBox(width: 10 * scale),
                               _buildMoreActions(context, scale),
                            ]
                          ],
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
  }

  Widget _buildMoreActions(BuildContext context, double scale) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'payment' && onRecordOfflinePayment != null) {
          onRecordOfflinePayment!();
        } else if (value == 'contract' && onViewContract != null) {
          onViewContract!();
        }
      },
      icon: Container(
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_vert_rounded, size: 20 * scale, color: AppColors.textSecondary),
      ),
      itemBuilder: (context) => [
        if (onRecordOfflinePayment != null)
          const PopupMenuItem(
            value: 'payment',
            child: Row(
              children: [
                Icon(Icons.payments_outlined, size: 20),
                SizedBox(width: 8),
                Text('Thanh toán offline'),
              ],
            ),
          ),
        if (onViewContract != null)
          const PopupMenuItem(
            value: 'contract',
            child: Row(
              children: [
                Icon(Icons.description_outlined, size: 20),
                SizedBox(width: 8),
                Text('Hợp đồng'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required double scale,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16 * scale, color: AppColors.textSecondary.withValues(alpha: 0.6)),
        SizedBox(width: 4 * scale),
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getIconForStatus(String iconKey) {
    switch (iconKey) {
      case 'wait': return Icons.hourglass_empty_rounded;
      case 'check': return Icons.check_circle_outline_rounded;
      case 'in_progress': return Icons.directions_run_rounded;
      case 'done': return Icons.done_all_rounded;
      case 'cancel': return Icons.cancel_outlined;
      default: return Icons.info_outline_rounded;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'CHỜ XỬ LÝ';
      case 'confirmed': return 'ĐÃ XÁC NHẬN';
      case 'in_progress': return 'ĐANG THỰC HIỆN';
      case 'completed': return 'HOÀN THÀNH';
      case 'cancelled': return 'ĐÃ HỦY';
      default: return status.toUpperCase();
    }
  }
}

class _CircularActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double scale;
  final String tooltip;

  const _CircularActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.scale,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12 * scale),
        child: Container(
          padding: EdgeInsets.all(10 * scale),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Icon(
            icon,
            size: 20 * scale,
            color: color,
          ),
        ),
      ),
    );
  }
}

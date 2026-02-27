import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../booking/data/datasources/booking_remote_datasource.dart';
import '../../../booking/data/models/booking_model.dart';
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
    if (_statusFilter == 'all') return bookings;
    return bookings
        .where((b) => b.status.toLowerCase() == _statusFilter)
        .toList();
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
          IconButton(
            onPressed: _isActionInProgress ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
          DropdownButton<String>(
            value: _statusFilter,
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
        ],
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onConfirm;
  final VoidCallback? onComplete;
  final VoidCallback? onRecordOfflinePayment;

  const _BookingItem({
    required this.booking,
    this.onConfirm,
    this.onComplete,
    this.onRecordOfflinePayment,
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
              onRecordOfflinePayment != null) ...[
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
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/utils/app_text_styles.dart';

class CustomerProfileBookingsTab extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final double scale;
  final String Function(DateTime) fmtDate;

  const CustomerProfileBookingsTab({
    super.key,
    required this.future,
    required this.scale,
    required this.fmtDate,
  });

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('pending')) return const Color(0xFFEAB308);
    if (s.contains('inprogress') || s.contains('in_progress') || s.contains('active')) {
      return const Color(0xFFF97316); // Orange-500
    }
    if (s.contains('confirm')) return const Color(0xFF3B82F6);
    if (s.contains('complete') || s.contains('done') || s.contains('success')) {
      return const Color(0xFF22C55E);
    }
    if (s.contains('cancel') || s.contains('fail')) return const Color(0xFFEF4444);
    return AppColors.textSecondary;
  }

  String _getStatusLabel(String status) {
    final s = status.toLowerCase();
    if (s.contains('inprogress') || s.contains('in_progress')) return 'Đang thực hiện';
    if (s.contains('pending')) return 'Chờ xử lý';
    if (s.contains('confirm')) return 'Đã xác nhận';
    if (s.contains('complete') || s.contains('done')) return 'Hoàn thành';
    if (s.contains('cancel')) return 'Đã hủy';
    return status;
  }

  IconData _getStatusIcon(String status) {
    final s = status.toLowerCase();
    if (s.contains('inprogress') || s.contains('in_progress') || s.contains('active')) {
      return Icons.hourglass_top_rounded;
    }
    if (s.contains('pending')) return Icons.schedule_rounded;
    if (s.contains('confirm')) return Icons.verified_rounded;
    if (s.contains('complete') || s.contains('done')) return Icons.check_circle_rounded;
    if (s.contains('cancel')) return Icons.cancel_rounded;
    return Icons.bookmark_added_rounded;
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '0 ₫';
    final number = value is num ? value : num.tryParse(value.toString()) ?? 0;
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(number)} ₫';
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final label = _getStatusLabel(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.arimo(
          fontSize: 10 * scale,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Không tải được Booking:\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
            ),
          );
        }
        final records = snapshot.data ?? const [];
        if (records.isEmpty) {
          return Center(
            child: Text(
              'Khách hàng chưa có booking nào.',
              style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16 * scale),
          itemCount: records.length,
          separatorBuilder: (_, __) => SizedBox(height: 16 * scale),
          itemBuilder: (context, index) {
            final item = records[index];

            // --- Extract fields from API response ---
            final status = (item['status'] ?? 'Unknown').toString();
            final bookingId = item['id'];
            final packageData = item['package'] as Map<String, dynamic>?;
            final packageName = packageData?['packageName'] ?? 'Dịch vụ chưa xác định';
            final customerData = item['customer'] as Map<String, dynamic>?;
            final customerName = customerData?['username'] ?? '';
            final customerPhone = customerData?['phone'] ?? '';

            final startDate = item['startDate'] != null
                ? fmtDate(DateTime.parse(item['startDate']))
                : '-';
            final endDate = item['endDate'] != null
                ? fmtDate(DateTime.parse(item['endDate']))
                : '-';

            final totalPrice = item['totalPrice'];
            final paidAmount = item['paidAmount'];
            final remainingAmount = item['remainingAmount'];

            final statusColor = _getStatusColor(status);
            final statusIcon = _getStatusIcon(status);
            return Container(
              margin: EdgeInsets.only(bottom: 4 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24 * scale),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(20 * scale),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(14 * scale),
                                ),
                                child: Icon(
                                  statusIcon,
                                  color: statusColor,
                                  size: 24 * scale,
                                ),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      packageName,
                                      style: AppTextStyles.arimo(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        height: 1.2,
                                      ),
                                    ),
                                    SizedBox(height: 6 * scale),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 2 * scale),
                                          decoration: BoxDecoration(
                                            color: AppColors.background,
                                            borderRadius: BorderRadius.circular(6 * scale),
                                          ),
                                          child: Text(
                                            '#$bookingId',
                                            style: AppTextStyles.arimo(
                                              fontSize: 11 * scale,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8 * scale),
                                        _buildStatusBadge(status),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (customerName.isNotEmpty || customerPhone.isNotEmpty) ...[
                            SizedBox(height: 16 * scale),
                            Row(
                              children: [
                                Icon(Icons.account_circle_outlined, size: 16 * scale, color: AppColors.textSecondary),
                                SizedBox(width: 8 * scale),
                                Expanded(
                                  child: Text(
                                    [customerName, customerPhone].where((e) => e.isNotEmpty).join(' • '),
                                    style: AppTextStyles.arimo(
                                      fontSize: 13 * scale,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          SizedBox(height: 16 * scale),
                          Container(
                            padding: EdgeInsets.all(16 * scale),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16 * scale),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today_rounded, size: 14 * scale, color: AppColors.textSecondary),
                                    SizedBox(width: 8 * scale),
                                    Text(
                                      'Thời gian:',
                                      style: AppTextStyles.arimo(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$startDate → $endDate',
                                      style: AppTextStyles.arimo(
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12 * scale),
                                  child: Divider(height: 1, color: AppColors.borderLight.withValues(alpha: 0.5)),
                                ),
                                _buildPriceRow('Tổng cộng', _formatCurrency(totalPrice), AppColors.textPrimary, isTotal: true),
                                SizedBox(height: 8 * scale),
                                _buildPriceRow('Đã thanh toán', _formatCurrency(paidAmount), const Color(0xFF10B981)),
                                if (remainingAmount != null && remainingAmount > 0) ...[
                                  SizedBox(height: 8 * scale),
                                  _buildPriceRow('Còn lại', _formatCurrency(remainingAmount), const Color(0xFFEF4444)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceRow(String label, String value, Color valueColor, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.arimo(
            fontSize: isTotal ? 16 * scale : 13 * scale,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

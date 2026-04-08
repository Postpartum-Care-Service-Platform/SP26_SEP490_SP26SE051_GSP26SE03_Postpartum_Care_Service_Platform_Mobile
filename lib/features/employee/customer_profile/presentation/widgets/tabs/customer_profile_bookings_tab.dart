import 'package:flutter/material.dart';

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
    if (s.contains('pending')) return const Color(0xFFEAB308); // Yellow-500
    if (s.contains('confirm') || s.contains('active')) return const Color(0xFF3B82F6); // Blue-500
    if (s.contains('complete') || s.contains('done') || s.contains('success')) return const Color(0xFF22C55E); // Green-500
    if (s.contains('cancel') || s.contains('fail')) return const Color(0xFFEF4444); // Red-500
    return AppColors.textSecondary;
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
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
            final status = (item['status'] ?? 'Unknown').toString();
            final packageName = item['packageName'] ?? item['package']?['name'] ?? 'Dịch vụ chưa xác định';
            final startDate = item['startDate'] != null ? fmtDate(DateTime.parse(item['startDate'])) : '-';
            final endDate = item['endDate'] != null ? fmtDate(DateTime.parse(item['endDate'])) : '-';
            final isComplete = status.toLowerCase().contains('complete') || status.toLowerCase().contains('done');

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20 * scale),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20 * scale),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Status Accent Bar
                      Container(
                        width: 4 * scale,
                        color: _getStatusColor(status),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(16 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10 * scale),
                                    decoration: BoxDecoration(
                                      color: isComplete ? Colors.green.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isComplete ? Icons.check_circle_rounded : Icons.bookmark_added_rounded,
                                      color: isComplete ? Colors.green : AppColors.primary,
                                      size: 20 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          packageName,
                                          style: AppTextStyles.arimo(
                                            fontSize: 15 * scale,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                            height: 1.3,
                                          ),
                                        ),
                                        SizedBox(height: 4 * scale),
                                        Text(
                                          'Mã Booking: #${item['id']}',
                                          style: AppTextStyles.arimo(
                                            fontSize: 12 * scale,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8 * scale),
                                  _buildStatusBadge(status),
                                ],
                              ),
                              SizedBox(height: 16 * scale),
                              Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12 * scale),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_month_rounded, size: 16 * scale, color: AppColors.textSecondary),
                                    SizedBox(width: 8 * scale),
                                    Expanded(
                                      child: Text(
                                        'Thời gian diễn ra',
                                        style: AppTextStyles.arimo(
                                          fontSize: 12 * scale,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '$startDate → $endDate',
                                      style: AppTextStyles.arimo(
                                        fontSize: 13 * scale,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

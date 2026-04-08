import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_colors.dart';
import '../../../../../../core/routing/app_router.dart';
import '../../../../../../core/routing/app_routes.dart';
import '../../../../../../core/utils/app_text_styles.dart';

class CustomerProfileTransactionsTab extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> future;
  final double scale;
  final String Function(DateTime) fmtDate;

  const CustomerProfileTransactionsTab({
    super.key,
    required this.future,
    required this.scale,
    required this.fmtDate,
  });

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('success') || s.contains('complete')) return const Color(0xFF22C55E);
    if (s.contains('pending')) return const Color(0xFFEAB308);
    if (s.contains('fail') || s.contains('cancel')) return const Color(0xFFEF4444);
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
              'Không tải được Giao dịch:\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(fontSize: 13 * scale, color: AppColors.textSecondary),
            ),
          );
        }
        final records = snapshot.data ?? const [];
        if (records.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72 * scale,
                  height: 72 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 34 * scale,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 14 * scale),
                Text(
                  'Chưa có giao dịch',
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6 * scale),
                Text(
                  'Khách hàng này chưa phát sinh giao dịch nào.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.arimo(
                    fontSize: 12.5 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 14 * scale),
                FilledButton.icon(
                  onPressed: () {
                    AppRouter.push(context, AppRoutes.staffTransactionList);
                  },
                  icon: const Icon(Icons.add_card_rounded),
                  label: const Text('Tạo giao dịch mới'),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16 * scale),
          itemCount: records.length,
          separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
          itemBuilder: (context, index) {
            final item = records[index];
            final status = (item['status'] ?? item['transactionStatus'] ?? 'Unknown').toString();
            final amount = item['amount']?.toString() ?? '0';
            final title = item['paymentMethod'] ?? 'Giao dịch';
            final dateStr = item['createdAt'];
            final date = dateStr != null ? fmtDate(DateTime.parse(dateStr)) : '-';
            final isSuccess = status.toLowerCase().contains('success') || status.toLowerCase().contains('complete');

            return Container(
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48 * scale,
                    height: 48 * scale,
                    decoration: BoxDecoration(
                      color: isSuccess ? const Color(0xFF22C55E).withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.account_balance_wallet_rounded : Icons.payments_rounded,
                      color: isSuccess ? const Color(0xFF22C55E) : AppColors.primary,
                      size: 24 * scale,
                    ),
                  ),
                  SizedBox(width: 14 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 12 * scale, color: AppColors.textSecondary),
                            SizedBox(width: 4 * scale),
                            Text(
                              date,
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$amount đ',
                        style: AppTextStyles.arimo(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6 * scale),
                      _buildStatusBadge(status),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/models/transaction_with_customer_model.dart';

class StaffTransactionListScreen extends StatefulWidget {
  const StaffTransactionListScreen({super.key});

  @override
  State<StaffTransactionListScreen> createState() =>
      _StaffTransactionListScreenState();
}

class _StaffTransactionListScreenState
    extends State<StaffTransactionListScreen> {
  final _dataSource = TransactionRemoteDataSourceImpl(dio: ApiClient.dio);
  late Future<List<TransactionWithCustomerModel>> _future =
      _loadTransactions();
  String _typeFilter = 'all'; // all, Deposit, Remaining, Full
  String _statusFilter = 'all'; // all, Pending, Paid, Failed

  Future<List<TransactionWithCustomerModel>> _loadTransactions() async {
    final all = await _dataSource.getAllTransactions();
    all.sort(
      (a, b) => b.transactionDate.compareTo(a.transactionDate),
    );
    return all;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadTransactions();
    });
  }

  List<TransactionWithCustomerModel> _applyFilter(
    List<TransactionWithCustomerModel> items,
  ) {
    return items.where((t) {
      final matchType =
          _typeFilter == 'all' || (t.type ?? '').toLowerCase() == _typeFilter;
      final matchStatus = _statusFilter == 'all' ||
          t.status.toLowerCase() == _statusFilter.toLowerCase();
      return matchType && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Danh sách giao dịch'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterBar(scale),
            Expanded(
              child: FutureBuilder<List<TransactionWithCustomerModel>>(
                future: _future,
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
                          'Lỗi tải danh sách giao dịch: ${snapshot.error}',
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
                  final items = _applyFilter(all);

                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24 * scale),
                        child: Text(
                          'Không có giao dịch nào.',
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
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10 * scale),
                      itemBuilder: (context, index) {
                        final t = items[index];
                        return _TransactionItem(transaction: t);
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
      padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 4 * scale),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  'Loại:',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _typeFilter,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                    DropdownMenuItem(value: 'deposit', child: Text('Deposit')),
                    DropdownMenuItem(
                      value: 'remaining',
                      child: Text('Remaining'),
                    ),
                    DropdownMenuItem(value: 'full', child: Text('Full')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _typeFilter = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
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
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'failed', child: Text('Failed')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _statusFilter = value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionWithCustomerModel transaction;

  const _TransactionItem({required this.transaction});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _statusColor(transaction.status);

    final customerName =
        transaction.customerUsername?.isNotEmpty == true
            ? transaction.customerUsername!
            : (transaction.customerEmail ?? 'Khách hàng');

    final date = transaction.transactionDate;
    final dateLabel = '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

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
                  transaction.status,
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              Text(
                '#${transaction.id.substring(0, 8)}',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Text(
            customerName,
            style: AppTextStyles.arimo(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4 * scale),
          if (transaction.bookingId != null)
            Text(
              'Booking #${transaction.bookingId}',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 14 * scale,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6 * scale),
              Text(
                dateLabel,
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
                '${transaction.amount.toStringAsFixed(0)} đ',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * scale),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 14 * scale,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6 * scale),
              Text(
                '${transaction.type ?? '-'} / ${transaction.paymentMethod ?? '-'}',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (transaction.note != null &&
              transaction.note!.trim().isNotEmpty) ...[
            SizedBox(height: 6 * scale),
            Text(
              transaction.note!,
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


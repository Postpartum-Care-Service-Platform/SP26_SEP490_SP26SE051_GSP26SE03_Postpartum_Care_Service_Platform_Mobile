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
  
  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _paymentMethodFilter;
  double? _amountFrom;
  double? _amountTo;
  bool _showFilters = false;

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
    var filtered = items;

    // Type filter
    if (_typeFilter != 'all') {
      filtered = filtered.where((t) {
        return (t.type ?? '').toLowerCase() == _typeFilter.toLowerCase();
      }).toList();
    }

    // Status filter
    if (_statusFilter != 'all') {
      filtered = filtered.where((t) {
        return t.status.toLowerCase() == _statusFilter.toLowerCase();
      }).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((t) {
        final customerName = (t.customerUsername ?? '').toLowerCase();
        final customerEmail = (t.customerEmail ?? '').toLowerCase();
        final transactionId = t.id.toLowerCase();
        final bookingId = t.bookingId?.toString().toLowerCase() ?? '';
        
        return customerName.contains(query) ||
            customerEmail.contains(query) ||
            transactionId.contains(query) ||
            bookingId.contains(query);
      }).toList();
    }

    // Date range filter
    if (_dateFrom != null) {
      filtered = filtered.where((t) {
        final transactionDate = DateTime(
          t.transactionDate.year,
          t.transactionDate.month,
          t.transactionDate.day,
        );
        return transactionDate.isAfter(_dateFrom!.subtract(const Duration(days: 1))) ||
            transactionDate.isAtSameMomentAs(DateTime(_dateFrom!.year, _dateFrom!.month, _dateFrom!.day));
      }).toList();
    }

    if (_dateTo != null) {
      filtered = filtered.where((t) {
        final transactionDate = DateTime(
          t.transactionDate.year,
          t.transactionDate.month,
          t.transactionDate.day,
        );
        return transactionDate.isBefore(_dateTo!.add(const Duration(days: 1))) ||
            transactionDate.isAtSameMomentAs(DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day));
      }).toList();
    }

    // Payment method filter
    if (_paymentMethodFilter != null && _paymentMethodFilter!.isNotEmpty) {
      filtered = filtered.where((t) {
        return (t.paymentMethod ?? '').toLowerCase() == _paymentMethodFilter!.toLowerCase();
      }).toList();
    }

    // Amount range filter
    if (_amountFrom != null) {
      filtered = filtered.where((t) => t.amount >= _amountFrom!).toList();
    }

    if (_amountTo != null) {
      filtered = filtered.where((t) => t.amount <= _amountTo!).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _typeFilter = 'all';
      _statusFilter = 'all';
      _dateFrom = null;
      _dateTo = null;
      _paymentMethodFilter = null;
      _amountFrom = null;
      _amountTo = null;
    });
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_typeFilter != 'all') count++;
    if (_statusFilter != 'all') count++;
    if (_searchQuery.isNotEmpty) count++;
    if (_dateFrom != null) count++;
    if (_dateTo != null) count++;
    if (_paymentMethodFilter != null && _paymentMethodFilter!.isNotEmpty) count++;
    if (_amountFrom != null) count++;
    if (_amountTo != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Danh sách giao dịch'),
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
            onPressed: _refresh,
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
          hintText: 'Tìm kiếm theo tên, email, mã giao dịch, booking...',
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
          SizedBox(height: 12 * scale),
          // Payment method filter
          Text(
            'Phương thức thanh toán:',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          DropdownButton<String>(
            value: _paymentMethodFilter,
            isExpanded: true,
            hint: const Text('Tất cả'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Tất cả')),
              DropdownMenuItem(value: 'PayOS', child: Text('PayOS (Online)')),
              DropdownMenuItem(value: 'Offline', child: Text('Offline (Tiền mặt)')),
            ],
            onChanged: (value) {
              setState(() {
                _paymentMethodFilter = value;
              });
            },
          ),
          SizedBox(height: 12 * scale),
          // Amount range
          Text(
            'Khoảng giá (VNĐ):',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Từ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12 * scale,
                      vertical: 10 * scale,
                    ),
                  ),
                  controller: TextEditingController(
                    text: _amountFrom?.toStringAsFixed(0) ?? '',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _amountFrom = value.isEmpty ? null : double.tryParse(value);
                    });
                  },
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Đến',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8 * scale),
                      borderSide: BorderSide(
                        color: AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12 * scale,
                      vertical: 10 * scale,
                    ),
                  ),
                  controller: TextEditingController(
                    text: _amountTo?.toStringAsFixed(0) ?? '',
                  ),
                  onChanged: (value) {
                    setState(() {
                      _amountTo = value.isEmpty ? null : double.tryParse(value);
                    });
                  },
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
                Expanded(
                  child: DropdownButton<String>(
                    value: _typeFilter,
                    isExpanded: true,
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
                ),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
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
                      DropdownMenuItem(value: 'paid', child: Text('Paid')),
                      DropdownMenuItem(value: 'failed', child: Text('Failed')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _statusFilter = value);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_getActiveFilterCount() > 0) ...[
            SizedBox(width: 8 * scale),
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


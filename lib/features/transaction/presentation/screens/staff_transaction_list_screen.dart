import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/models/transaction_with_customer_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/services/current_account_cache_service.dart';

class StaffTransactionListScreen extends StatefulWidget {
  const StaffTransactionListScreen({super.key});

  @override
  State<StaffTransactionListScreen> createState() =>
      _StaffTransactionListScreenState();
}

class _StaffTransactionListScreenState
    extends State<StaffTransactionListScreen> {
  final _dataSource = TransactionRemoteDataSourceImpl(dio: ApiClient.dio);
  late Future<List<TransactionWithCustomerModel>> _future = _loadTransactions();
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
  String? _cachedRoleName;

  @override
  void initState() {
    super.initState();
    _fetchRoleName();
  }

  Future<void> _fetchRoleName() async {
    final account = await CurrentAccountCacheService.getCurrentAccount();
    if (account != null) {
      if (mounted) {
        setState(() {
          _cachedRoleName = account.roleName;
        });
      }
    }
  }

  Future<List<TransactionWithCustomerModel>> _loadTransactions() async {
    final all = await _dataSource.getAllTransactions();
    all.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return all;
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadTransactions();
    });
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Đã thanh toán';
      case 'pending':
        return 'Chờ xử lý';
      case 'failed':
        return 'Thất bại';
      default:
        return status;
    }
  }

  String _typeLabel(String? type) {
    switch ((type ?? '').toLowerCase()) {
      case 'deposit':
        return 'Đặt cọc';
      case 'remaining':
        return 'Thanh toán còn lại';
      case 'full':
        return 'Thanh toán toàn bộ';
      case 'platformcommission':
        return 'Hoa hồng hệ thống';
      default:
        return type ?? '-';
    }
  }

  String? _getRoleFromBloc() {
    try {
      final state = BlocProvider.of<AuthBloc>(context, listen: false).state;
      if (state is AuthCurrentAccountLoaded) {
        return state.account.roleName;
      }
    } catch (_) {}
    return null;
  }

  List<TransactionWithCustomerModel> _applyFilter(
    List<TransactionWithCustomerModel> items,
  ) {
    var filtered = items;

    // Filter PlatformCommission for centerstaff
    final roleName = (_cachedRoleName ?? _getRoleFromBloc() ?? '')
        .trim()
        .toLowerCase();

    // Logic: If it's Center Staff or generic Staff role, hide PlatformCommission.
    // Home Staff usually has explicit "home" in their role name.
    if (roleName.contains('center') || roleName == 'staff') {
      filtered = filtered
          .where(
            (t) => (t.type ?? '').toLowerCase().trim() != 'platformcommission',
          )
          .toList();
    }

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
        return transactionDate.isAfter(
              _dateFrom!.subtract(const Duration(days: 1)),
            ) ||
            transactionDate.isAtSameMomentAs(
              DateTime(_dateFrom!.year, _dateFrom!.month, _dateFrom!.day),
            );
      }).toList();
    }

    if (_dateTo != null) {
      filtered = filtered.where((t) {
        final transactionDate = DateTime(
          t.transactionDate.year,
          t.transactionDate.month,
          t.transactionDate.day,
        );
        return transactionDate.isBefore(
              _dateTo!.add(const Duration(days: 1)),
            ) ||
            transactionDate.isAtSameMomentAs(
              DateTime(_dateTo!.year, _dateTo!.month, _dateTo!.day),
            );
      }).toList();
    }

    // Payment method filter
    if (_paymentMethodFilter != null && _paymentMethodFilter!.isNotEmpty) {
      filtered = filtered.where((t) {
        return (t.paymentMethod ?? '').toLowerCase() ==
            _paymentMethodFilter!.toLowerCase();
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
    if (_paymentMethodFilter != null && _paymentMethodFilter!.isNotEmpty) {
      count++;
    }
    if (_amountFrom != null) count++;
    if (_amountTo != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return EmployeeScaffold(
      appBar: AppBar(
        title: Text(
          'Giao dịch',
          style: AppTextStyles.arimo(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.primary,
              size: 24 * scale,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(scale),
            _buildFilterChips(scale),
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48 * scale,
                              color: Colors.red.withValues(alpha: 0.5),
                            ),
                            SizedBox(height: 16 * scale),
                            Text(
                              'Lỗi tải danh sách: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64 * scale,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            SizedBox(height: 16 * scale),
                            Text(
                              'Không tìm thấy giao dịch nào',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.arimo(
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (_getActiveFilterCount() > 0) ...[
                              SizedBox(height: 8 * scale),
                              TextButton(
                                onPressed: _clearFilters,
                                child: const Text('Xóa bộ lọc'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        16 * scale,
                        8 * scale,
                        16 * scale,
                        100 * scale,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                      itemBuilder: (context, index) {
                        final t = items[index];
                        return _TransactionItem(
                          transaction: t,
                          statusLabel: _statusLabel(t.status),
                          typeLabel: _typeLabel(t.type),
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

  Widget _buildHeader(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 8 * scale,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                style: AppTextStyles.arimo(fontSize: 14 * scale),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên, mã giao dịch...',
                  hintStyle: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 20 * scale,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.close_rounded, size: 18 * scale),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12 * scale),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          Stack(
            children: [
              IconButton(
                onPressed: () => _showFilterBottomSheet(scale),
                icon: Container(
                  padding: EdgeInsets.all(8 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10 * scale),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: AppColors.primary,
                    size: 20 * scale,
                  ),
                ),
              ),
              if (_getActiveFilterCount() > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      '${_getActiveFilterCount()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(double scale) {
    final statuses = [
      {'key': 'all', 'label': 'Tất cả'},
      {'key': 'paid', 'label': 'Đã thanh toán'},
      {'key': 'pending', 'label': 'Chờ xử lý'},
      {'key': 'failed', 'label': 'Thất bại'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 8 * scale,
          ),
          child: Row(
            children: statuses.map((status) {
              final isSelected = _statusFilter == status['key'];
              return Padding(
                padding: EdgeInsets.only(right: 8 * scale),
                child: FilterChip(
                  label: Text(status['label']!),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() => _statusFilter = status['key']!);
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  backgroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20 * scale),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(double scale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
              20 * scale,
              20 * scale,
              20 * scale,
              40 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24 * scale),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bộ lọc nâng cao',
                      style: AppTextStyles.arimo(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _clearFilters();
                        Navigator.pop(context);
                      },
                      child: const Text('Xóa tất cả'),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'Loại giao dịch',
                  style: AppTextStyles.arimo(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12 * scale),
                Wrap(
                  spacing: 8 * scale,
                  children: ['all', 'deposit', 'remaining', 'full'].map((type) {
                    final isSelected = _typeFilter == type;
                    return ChoiceChip(
                      label: Text(_typeLabel(type == 'all' ? null : type)),
                      selected: isSelected,
                      onSelected: (val) {
                        setModalState(() => _typeFilter = type);
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'Khoảng thời gian',
                  style: AppTextStyles.arimo(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12 * scale),
                Row(
                  children: [
                    Expanded(
                      child: _DateTile(
                        label: 'Từ ngày',
                        date: _dateFrom,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _dateFrom ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) {
                            setModalState(() => _dateFrom = d);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: _DateTile(
                        label: 'Đến ngày',
                        date: _dateTo,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _dateTo ?? DateTime.now(),
                            firstDate: _dateFrom ?? DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (d != null) {
                            setModalState(() => _dateTo = d);
                            setState(() {});
                          }
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                Text(
                  'Phương thức thanh toán',
                  style: AppTextStyles.arimo(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12 * scale),
                Wrap(
                  spacing: 8 * scale,
                  children:
                      [
                        {'val': null, 'label': 'Tất cả'},
                        {'val': 'PayOS', 'label': 'PayOS'},
                        {'val': 'Offline', 'label': 'Tiền mặt'},
                      ].map((method) {
                        final isSelected =
                            _paymentMethodFilter == method['val'];
                        return ChoiceChip(
                          label: Text(method['label'] as String),
                          selected: isSelected,
                          onSelected: (val) {
                            setModalState(
                              () => _paymentMethodFilter = method['val'],
                            );
                            setState(() {});
                          },
                        );
                      }).toList(),
                ),
                SizedBox(height: 32 * scale),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    child: Text(
                      'Áp dụng',
                      style: AppTextStyles.arimo(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
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

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({required this.label, this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12 * scale),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8 * scale),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 16 * scale,
              color: AppColors.primary,
            ),
            SizedBox(width: 8 * scale),
            Text(
              date == null
                  ? label
                  : '${date!.day}/${date!.month}/${date!.year}',
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                color: date == null
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionWithCustomerModel transaction;
  final String statusLabel;
  final String typeLabel;

  const _TransactionItem({
    required this.transaction,
    required this.statusLabel,
    required this.typeLabel,
  });

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

    final customerName = transaction.customerUsername?.isNotEmpty == true
        ? transaction.customerUsername!
        : (transaction.customerEmail ?? 'Khách hàng');

    final date = transaction.transactionDate;
    final dateLabel =
        '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: Text(
                  statusLabel,
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
                  fontSize: 11 * scale,
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Text(
            customerName,
            style: AppTextStyles.arimo(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (transaction.bookingId != null) ...[
            SizedBox(height: 4 * scale),
            Text(
              'Booking #${transaction.bookingId}',
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 12 * scale),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14 * scale,
                color: AppColors.textSecondary.withValues(alpha: 0.6),
              ),
              SizedBox(width: 6 * scale),
              Text(
                dateLabel,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SizedBox(height: 12 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Số tiền',
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    '${transaction.amount.toInt()} đ',
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Loại & Phương thức',
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    '$typeLabel / ${transaction.paymentMethod ?? 'PayOS'}',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (transaction.note != null &&
              transaction.note!.trim().isNotEmpty) ...[
            SizedBox(height: 12 * scale),
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8 * scale),
              ),
              child: Text(
                transaction.note!,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

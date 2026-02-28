import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../contract/data/datasources/contract_remote_datasource.dart';
import '../../../contract/data/models/contract_model.dart';
import 'staff_contract_screen.dart';

/// Danh sách hợp đồng cho staff (tất cả + chưa lên lịch)
class StaffContractListScreen extends StatefulWidget {
  const StaffContractListScreen({super.key});

  @override
  State<StaffContractListScreen> createState() =>
      _StaffContractListScreenState();
}

class _StaffContractListScreenState extends State<StaffContractListScreen> {
  final _remote = ContractRemoteDataSourceImpl(dio: ApiClient.dio);
  String _filter = 'all'; // all, no_schedule
  late Future<List<ContractModel>> _future = _load();
  
  // Search and filter
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all'; // all, draft, sent, signed, cancelled
  DateTime? _contractDateFrom;
  DateTime? _contractDateTo;
  DateTime? _signedDateFrom;
  DateTime? _signedDateTo;
  bool _showFilters = false;

  Future<List<ContractModel>> _load() async {
    if (_filter == 'no_schedule') {
      final list = await _remote.getNoScheduleContracts();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } else {
      final list = await _remote.getAllContracts();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
  }

  List<ContractModel> _applyFilters(List<ContractModel> contracts) {
    var filtered = contracts;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((c) {
        final customerName = (c.customer?.username ?? '').toLowerCase();
        final customerEmail = (c.customer?.email ?? '').toLowerCase();
        final contractCode = c.contractCode.toLowerCase();
        final bookingId = c.bookingId.toString().toLowerCase();
        
        return customerName.contains(query) ||
            customerEmail.contains(query) ||
            contractCode.contains(query) ||
            bookingId.contains(query);
      }).toList();
    }

    // Status filter
    if (_statusFilter != 'all') {
      filtered = filtered.where((c) {
        return c.status.toLowerCase() == _statusFilter.toLowerCase();
      }).toList();
    }

    // Contract date range filter
    if (_contractDateFrom != null) {
      filtered = filtered.where((c) {
        final contractDate = DateTime(
          c.contractDate.year,
          c.contractDate.month,
          c.contractDate.day,
        );
        return contractDate.isAfter(_contractDateFrom!.subtract(const Duration(days: 1))) ||
            contractDate.isAtSameMomentAs(DateTime(_contractDateFrom!.year, _contractDateFrom!.month, _contractDateFrom!.day));
      }).toList();
    }

    if (_contractDateTo != null) {
      filtered = filtered.where((c) {
        final contractDate = DateTime(
          c.contractDate.year,
          c.contractDate.month,
          c.contractDate.day,
        );
        return contractDate.isBefore(_contractDateTo!.add(const Duration(days: 1))) ||
            contractDate.isAtSameMomentAs(DateTime(_contractDateTo!.year, _contractDateTo!.month, _contractDateTo!.day));
      }).toList();
    }

    // Signed date range filter
    if (_signedDateFrom != null) {
      filtered = filtered.where((c) {
        if (c.signedDate == null) return false;
        final signedDate = DateTime(
          c.signedDate!.year,
          c.signedDate!.month,
          c.signedDate!.day,
        );
        return signedDate.isAfter(_signedDateFrom!.subtract(const Duration(days: 1))) ||
            signedDate.isAtSameMomentAs(DateTime(_signedDateFrom!.year, _signedDateFrom!.month, _signedDateFrom!.day));
      }).toList();
    }

    if (_signedDateTo != null) {
      filtered = filtered.where((c) {
        if (c.signedDate == null) return false;
        final signedDate = DateTime(
          c.signedDate!.year,
          c.signedDate!.month,
          c.signedDate!.day,
        );
        return signedDate.isBefore(_signedDateTo!.add(const Duration(days: 1))) ||
            signedDate.isAtSameMomentAs(DateTime(_signedDateTo!.year, _signedDateTo!.month, _signedDateTo!.day));
      }).toList();
    }

    return filtered;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = 'all';
      _contractDateFrom = null;
      _contractDateTo = null;
      _signedDateFrom = null;
      _signedDateTo = null;
    });
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_statusFilter != 'all') count++;
    if (_searchQuery.isNotEmpty) count++;
    if (_contractDateFrom != null) count++;
    if (_contractDateTo != null) count++;
    if (_signedDateFrom != null) count++;
    if (_signedDateTo != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Danh sách hợp đồng',
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
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
      body: Column(
        children: [
          _buildSearchBar(scale),
          if (_showFilters) _buildAdvancedFilters(scale),
          _buildFilterBar(scale),
          Expanded(
            child: FutureBuilder<List<ContractModel>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Text(
                        'Lỗi tải danh sách hợp đồng: ${snapshot.error}',
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
                final items = _applyFilters(all);
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Text(
                        'Không có hợp đồng nào.',
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
                      final c = items[index];
                      return _ContractItem(
                        contract: c,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => StaffContractScreen.fromContract(c),
                            ),
                          );
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
          hintText: 'Tìm kiếm theo tên, email, mã hợp đồng, booking...',
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
          // Status filter
          Text(
            'Trạng thái:',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          DropdownButton<String>(
            value: _statusFilter,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('Tất cả')),
              DropdownMenuItem(value: 'draft', child: Text('Nháp')),
              DropdownMenuItem(value: 'sent', child: Text('Đã gửi')),
              DropdownMenuItem(value: 'signed', child: Text('Đã ký')),
              DropdownMenuItem(value: 'cancelled', child: Text('Đã hủy')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _statusFilter = value;
              });
            },
          ),
          SizedBox(height: 12 * scale),
          // Contract date range
          Text(
            'Ngày ký hợp đồng:',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _contractDateFrom ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _contractDateFrom = date;
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
                            _contractDateFrom == null
                                ? 'Từ ngày'
                                : '${_contractDateFrom!.day}/${_contractDateFrom!.month}/${_contractDateFrom!.year}',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: _contractDateFrom == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_contractDateFrom != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _contractDateFrom = null;
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
                      initialDate: _contractDateTo ?? DateTime.now(),
                      firstDate: _contractDateFrom ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _contractDateTo = date;
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
                            _contractDateTo == null
                                ? 'Đến ngày'
                                : '${_contractDateTo!.day}/${_contractDateTo!.month}/${_contractDateTo!.year}',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: _contractDateTo == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_contractDateTo != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _contractDateTo = null;
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
          // Signed date range
          Text(
            'Ngày đã ký:',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _signedDateFrom ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _signedDateFrom = date;
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
                          Icons.edit_document,
                          size: 16 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: Text(
                            _signedDateFrom == null
                                ? 'Từ ngày'
                                : '${_signedDateFrom!.day}/${_signedDateFrom!.month}/${_signedDateFrom!.year}',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: _signedDateFrom == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_signedDateFrom != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _signedDateFrom = null;
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
                      initialDate: _signedDateTo ?? DateTime.now(),
                      firstDate: _signedDateFrom ?? DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() {
                        _signedDateTo = date;
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
                          Icons.edit_document,
                          size: 16 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 8 * scale),
                        Expanded(
                          child: Text(
                            _signedDateTo == null
                                ? 'Đến ngày'
                                : '${_signedDateTo!.day}/${_signedDateTo!.month}/${_signedDateTo!.year}',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: _signedDateTo == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_signedDateTo != null)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _signedDateTo = null;
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
      padding: EdgeInsets.fromLTRB(16 * scale, 8 * scale, 16 * scale, 4 * scale),
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
              value: _filter,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                DropdownMenuItem(
                  value: 'no_schedule',
                  child: Text('Chưa lên lịch'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _filter = value;
                  _future = _load();
                });
              },
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

class _ContractItem extends StatelessWidget {
  final ContractModel contract;
  final VoidCallback? onTap;

  const _ContractItem({
    required this.contract,
    this.onTap,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Colors.orange;
      case 'sent':
        return Colors.blue;
      case 'signed':
        return AppColors.verified;
      case 'cancelled':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Nháp';
      case 'sent':
        return 'Đã gửi';
      case 'signed':
        return 'Đã ký';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _statusColor(contract.status);
    final customerName =
        contract.customer?.username ?? 
        contract.customer?.email ??
        'Khách hàng';
    final customerEmail = contract.customer?.email;
    final customerPhone = contract.customer?.phone;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16 * scale),
      child: Container(
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
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _statusText(contract.status),
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                Text(
                  contract.contractCode,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                CircleAvatar(
                  radius: 20 * scale,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    customerName.isNotEmpty 
                        ? customerName[0].toUpperCase() 
                        : 'K',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (customerEmail != null) ...[
                        SizedBox(height: 4 * scale),
                        Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              size: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4 * scale),
                            Expanded(
                              child: Text(
                                customerEmail,
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  color: AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (customerPhone != null) ...[
                        SizedBox(height: 4 * scale),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              customerPhone,
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Divider(height: 1, color: AppColors.borderLight),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                Icon(
                  Icons.book_online,
                  size: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  'Booking #${contract.bookingId}',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  '${contract.contractDate.day}/${contract.contractDate.month}/${contract.contractDate.year}',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (contract.signedDate != null) ...[
              SizedBox(height: 8 * scale),
              Row(
                children: [
                  Icon(
                    Icons.edit_document,
                    size: 14 * scale,
                    color: AppColors.verified,
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    'Đã ký: ${contract.signedDate!.day}/${contract.signedDate!.month}/${contract.signedDate!.year}',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.verified,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}


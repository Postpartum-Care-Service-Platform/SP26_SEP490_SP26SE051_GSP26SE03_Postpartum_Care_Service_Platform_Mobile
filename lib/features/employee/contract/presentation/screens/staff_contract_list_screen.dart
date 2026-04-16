import 'package:flutter/material.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../core/widgets/app_app_bar.dart';
import '../../../../../features/contract/data/datasources/contract_remote_datasource.dart';
import '../../../../../features/contract/data/models/contract_model.dart';
import '../../../../../features/contract/data/models/contract_preview_model.dart';
import '../../../../../features/employee/contract/presentation/screens/staff_contract_screen.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';

/// Danh sách hợp đồng cho staff (tất cả + chưa lên lịch)
class StaffContractListScreen extends StatefulWidget {
  final VoidCallback? onBackToDefaultStaffPage;
  const StaffContractListScreen({super.key, this.onBackToDefaultStaffPage});

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
  String _statusFilter = 'all'; // all, draft, sent, signed, printed, cancelled
  DateTime? _contractDateFrom;
  DateTime? _contractDateTo;
  DateTime? _signedDateFrom;
  DateTime? _signedDateTo;
  final Map<int, ContractPreviewModel> _previewByBookingId = {};

  Future<List<ContractModel>> _load() async {
    final list = _filter == 'no_schedule'
        ? await _remote.getNoScheduleContracts()
        : await _remote.getAllContracts();

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await _hydrateMissingCustomerInfo(list);

    return list;
  }

  Future<void> _hydrateMissingCustomerInfo(List<ContractModel> contracts) async {
    final bookingIdsToFetch = contracts
        .where((c) => _needsPreviewFallback(c))
        .map((c) => c.bookingId)
        .where((id) => !_previewByBookingId.containsKey(id))
        .toSet();

    if (bookingIdsToFetch.isEmpty) return;

    final entries = await Future.wait(
      bookingIdsToFetch.map((bookingId) async {
        try {
          final preview = await _remote.previewContractByBooking(bookingId);
          return MapEntry<int, ContractPreviewModel?>(bookingId, preview);
        } catch (_) {
          return MapEntry<int, ContractPreviewModel?>(bookingId, null);
        }
      }),
    );

    for (final entry in entries) {
      final preview = entry.value;
      if (preview == null) continue;
      _previewByBookingId[entry.key] = preview;
    }
  }

  bool _needsPreviewFallback(ContractModel contract) {
    final name = contract.customer?.username.trim() ?? '';
    final email = contract.customer?.email.trim() ?? '';
    return name.isEmpty && email.isEmpty;
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
        final preview = _previewByBookingId[c.bookingId];
        final customerName =
            (c.customer?.username ?? preview?.customerName ?? '').toLowerCase();
        final customerEmail =
            (c.customer?.email ?? preview?.customerEmail ?? '').toLowerCase();
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

    return EmployeeScaffold(
      appBar: AppAppBar(
        title: 'Quản lý hợp đồng',
        centerTitle: true,
        showBackButton: true,
        onBackPressed: widget.onBackToDefaultStaffPage,
        titleFontSize: 18 * scale,
        titleFontWeight: FontWeight.w700,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(Icons.refresh_rounded, color: AppColors.primary, size: 24 * scale),
          ),
          SizedBox(width: 8 * scale),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(scale),
          _buildStatusChips(scale),
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
                      final preview = _previewByBookingId[c.bookingId];

                      return _ContractItem(
                        contract: c,
                        preview: preview,
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

  Widget _buildHeader(double scale) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 8 * scale),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48 * scale,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Tìm khách hàng, mã HĐ...',
                  hintStyle: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.primary, size: 20 * scale),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12 * scale),
                ),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
              height: 48 * scale,
              width: 48 * scale,
              decoration: BoxDecoration(
                color: _getActiveFilterCount() > 0 ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: _getActiveFilterCount() > 0 ? AppColors.white : AppColors.textPrimary,
                    size: 20 * scale,
                  ),
                  if (_getActiveFilterCount() > 0)
                    Positioned(
                      top: 10 * scale,
                      right: 10 * scale,
                      child: Container(
                        width: 8 * scale,
                        height: 8 * scale,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips(double scale) {
    final statuses = [
      {'id': 'all', 'label': 'Tất cả'},
      {'id': 'draft', 'label': 'Bản nháp'},
      {'id': 'sent', 'label': 'Đã gửi'},
      {'id': 'signed', 'label': 'Đã ký'},
      {'id': 'printed', 'label': 'Đã in'},
      {'id': 'cancelled', 'label': 'Đã hủy'},
    ];

    return Container(
      height: 40 * scale,
      margin: EdgeInsets.symmetric(vertical: 8 * scale),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, __) => SizedBox(width: 8 * scale),
        itemBuilder: (context, index) {
          final s = statuses[index];
          final isSelected = _statusFilter == s['id'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _statusFilter = s['id']!;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20 * scale),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  s['label']!,
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        initialFilter: _filter,
        contractDateFrom: _contractDateFrom,
        contractDateTo: _contractDateTo,
        signedDateFrom: _signedDateFrom,
        signedDateTo: _signedDateTo,
        onApply: (type, cFrom, cTo, sFrom, sTo) {
          setState(() {
            _filter = type;
            _contractDateFrom = cFrom;
            _contractDateTo = cTo;
            _signedDateFrom = sFrom;
            _signedDateTo = sTo;
            _future = _load();
          });
        },
        onClear: () {
          _clearFilters();
          _future = _load();
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

class _ContractItem extends StatelessWidget {
  final ContractModel contract;
  final ContractPreviewModel? preview;
  final VoidCallback? onTap;

  const _ContractItem({
    required this.contract,
    required this.preview,
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
      case 'printed':
        return const Color(0xFF2563EB);
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
      case 'printed':
        return 'Đã in';
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
    final customerName = contract.customer?.username.trim();
    final customerEmail = contract.customer?.email.trim();
    final customerPhone = contract.customer?.phone?.trim();

    final fallbackName = preview?.customerName?.trim();
    final fallbackEmail = preview?.customerEmail?.trim();
    final fallbackPhone = preview?.customerPhone?.trim();

    final resolvedName = (customerName?.isNotEmpty == true)
        ? customerName!
        : ((fallbackName?.isNotEmpty == true) ? fallbackName! : null);
    final resolvedEmail = (customerEmail?.isNotEmpty == true)
        ? customerEmail!
        : ((fallbackEmail?.isNotEmpty == true) ? fallbackEmail! : null);
    final resolvedPhone = (customerPhone?.isNotEmpty == true)
        ? customerPhone!
        : ((fallbackPhone?.isNotEmpty == true) ? fallbackPhone! : null);

    final displayName = resolvedName ?? resolvedEmail ?? 'Chưa có khách hàng';
    final hasCustomer = resolvedName != null || resolvedEmail != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15 * scale,
              spreadRadius: 0,
              offset: Offset(0, 8 * scale),
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
                    color: statusColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8 * scale),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6 * scale,
                        height: 6 * scale,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        _statusText(contract.status),
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  contract.contractCode,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                CircleAvatar(
                  radius: 24 * scale,
                  backgroundColor: hasCustomer
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.textSecondary.withValues(alpha: 0.1),
                  child: hasCustomer
                      ? Text(
                          displayName[0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.textSecondary,
                          size: 24 * scale,
                        ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w700,
                          color: hasCustomer
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (resolvedEmail != null) ...[
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
                                resolvedEmail,
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
                      if (resolvedPhone != null) ...[
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
                              resolvedPhone,
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

class _FilterBottomSheet extends StatefulWidget {
  final String initialFilter;
  final DateTime? contractDateFrom;
  final DateTime? contractDateTo;
  final DateTime? signedDateFrom;
  final DateTime? signedDateTo;
  final Function(String type, DateTime? cFrom, DateTime? cTo, DateTime? sFrom, DateTime? sTo) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.initialFilter,
    required this.contractDateFrom,
    required this.contractDateTo,
    required this.signedDateFrom,
    required this.signedDateTo,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _type;
  DateTime? _cFrom;
  DateTime? _cTo;
  DateTime? _sFrom;
  DateTime? _sTo;

  @override
  void initState() {
    super.initState();
    _type = widget.initialFilter;
    _cFrom = widget.contractDateFrom;
    _cTo = widget.contractDateTo;
    _sFrom = widget.signedDateFrom;
    _sTo = widget.signedDateTo;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24 * scale,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40 * scale,
            height: 4 * scale,
            margin: EdgeInsets.symmetric(vertical: 12 * scale),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20 * scale),
            child: Row(
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
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Xóa tất cả',
                    style: AppTextStyles.arimo(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Loại hợp đồng', scale),
                  SizedBox(height: 12 * scale),
                  Row(
                    children: [
                      _buildTypeItem('all', 'Tất cả', scale),
                      SizedBox(width: 12 * scale),
                      _buildTypeItem('no_schedule', 'Chưa lên lịch', scale),
                    ],
                  ),
                  SizedBox(height: 24 * scale),
                  _buildSectionTitle('Ngày tạo hợp đồng', scale),
                  SizedBox(height: 12 * scale),
                  _buildDateRangePicker(
                    from: _cFrom,
                    to: _cTo,
                    onFromChanged: (d) => setState(() => _cFrom = d),
                    onToChanged: (d) => setState(() => _cTo = d),
                    scale: scale,
                  ),
                  SizedBox(height: 24 * scale),
                  _buildSectionTitle('Ngày đã ký', scale),
                  SizedBox(height: 12 * scale),
                  _buildDateRangePicker(
                    from: _sFrom,
                    to: _sTo,
                    onFromChanged: (d) => setState(() => _sFrom = d),
                    onToChanged: (d) => setState(() => _sTo = d),
                    scale: scale,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20 * scale),
            child: SizedBox(
              width: double.infinity,
              height: 50 * scale,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_type, _cFrom, _cTo, _sFrom, _sTo);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Áp dụng',
                  style: AppTextStyles.arimo(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Text(
      title,
      style: AppTextStyles.arimo(
        fontSize: 15 * scale,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTypeItem(String id, String label, double scale) {
    final isSelected = _type == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = id),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12 * scale),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangePicker({
    required DateTime? from,
    required DateTime? to,
    required Function(DateTime?) onFromChanged,
    required Function(DateTime?) onToChanged,
    required double scale,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildDatePicker(
            value: from,
            hint: 'Từ ngày',
            onChanged: onFromChanged,
            scale: scale,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _buildDatePicker(
            value: to,
            hint: 'Đến ngày',
            onChanged: onToChanged,
            scale: scale,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required DateTime? value,
    required String hint,
    required Function(DateTime?) onChanged,
    required double scale,
  }) {
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        onChanged(date);
      },
      child: Container(
        padding: EdgeInsets.all(12 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12 * scale),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 16 * scale, color: AppColors.textSecondary),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Text(
                value == null ? hint : '${value.day}/${value.month}/${value.year}',
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: value == null ? AppColors.textSecondary : AppColors.textPrimary,
                ),
              ),
            ),
            if (value != null)
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.close_rounded, size: 16 * scale, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}



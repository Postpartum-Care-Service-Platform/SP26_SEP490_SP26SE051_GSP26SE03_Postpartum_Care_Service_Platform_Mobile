import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

enum _RequestTab { sent, incoming }

class _ScheduleOption {
  final int id;
  final String label;

  const _ScheduleOption({required this.id, required this.label});

  factory _ScheduleOption.fromJson(Map<String, dynamic> json) {
    final familySchedule = json['familyScheduleResponse'] as Map<String, dynamic>?;
    final session = familySchedule?['session']?.toString() ?? '';
    final name = familySchedule?['name']?.toString() ?? 'Schedule #${json['id']}';

    return _ScheduleOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      label: session.isEmpty ? '$name (#${json['id']})' : '$name - $session (#${json['id']})',
    );
  }
}

class _StaffReceiver {
  final String id;
  final String displayName;

  const _StaffReceiver({required this.id, required this.displayName});

  factory _StaffReceiver.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    final username = (json['username'] ?? '').toString();
    final email = (json['email'] ?? '').toString();

    return _StaffReceiver(
      id: id,
      displayName: username.isNotEmpty ? '$username ($email)' : email,
    );
  }

  static bool isStaff(Map<String, dynamic> json) {
    final role = (json['roleName'] ?? '').toString().toLowerCase();
    return role == 'staff';
  }
}

class _SwapRequest {
  final int id;
  final int fromScheduleId;
  final int toScheduleId;
  final String requesterName;
  final String receiverName;
  final String reason;
  final String status;
  final DateTime? createdAt;

  const _SwapRequest({
    required this.id,
    required this.fromScheduleId,
    required this.toScheduleId,
    required this.requesterName,
    required this.receiverName,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory _SwapRequest.fromJson(Map<String, dynamic> json) {
    return _SwapRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fromScheduleId: (json['fromScheduleId'] as num?)?.toInt() ?? 0,
      toScheduleId: (json['toScheduleId'] as num?)?.toInt() ?? 0,
      requesterName: (json['requesterName'] ?? '').toString(),
      receiverName: (json['receiverName'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? 'Pending').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}

class _RequestsScreenState extends State<RequestsScreen> {
  _RequestTab _tab = _RequestTab.sent;
  bool _loading = true;
  bool _creating = false;
  String? _error;
  DateTime? _selectedDate;
  List<_SwapRequest> _sent = const [];
  List<_SwapRequest> _incoming = const [];
  List<_ScheduleOption> _mySchedules = const [];
  List<_StaffReceiver> _staffReceivers = const [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 30));
      final to = now.add(const Duration(days: 30));

      final responses = await Future.wait([
        ApiClient.dio.get(ApiEndpoints.mySwapRequests),
        ApiClient.dio.get(ApiEndpoints.myIncomingSwapRequests),
        ApiClient.dio.get(
          ApiEndpoints.myStaffSchedules,
          queryParameters: {
            'from': _dateOnly(from),
            'to': _dateOnly(to),
          },
        ),
        ApiClient.dio.get(ApiEndpoints.getAllAccounts),
      ]);

      final sentData = responses[0].data as List<dynamic>;
      final incomingData = responses[1].data as List<dynamic>;
      final scheduleData = responses[2].data as List<dynamic>;
      final accountsData = responses[3].data as List<dynamic>;

      if (!mounted) return;
      setState(() {
        _sent = sentData
            .map((e) => _SwapRequest.fromJson(e as Map<String, dynamic>))
            .toList();
        _incoming = incomingData
            .map((e) => _SwapRequest.fromJson(e as Map<String, dynamic>))
            .toList();
        _mySchedules = scheduleData
            .map((e) => _ScheduleOption.fromJson(e as Map<String, dynamic>))
            .where((e) => e.id > 0)
            .toList();
        _staffReceivers = accountsData
            .whereType<Map<String, dynamic>>()
            .where(_StaffReceiver.isStaff)
            .map(_StaffReceiver.fromJson)
            .where((e) => e.id.isNotEmpty)
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createSwapRequest({
    required int fromScheduleId,
    required int toScheduleId,
    required String receiverId,
    required String reason,
  }) async {
    if (_creating) return;

    setState(() {
      _creating = true;
    });

    try {
      await ApiClient.dio.patch(
        ApiEndpoints.swapStaffSchedule,
        data: {
          'fromScheduleId': fromScheduleId,
          'toScheduleId': toScheduleId,
          'receiverId': receiverId,
          'reason': reason,
        },
      );

      if (!mounted) return;
      setState(() {
        _creating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo yêu cầu đổi ca thành công')),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo yêu cầu thất bại: $e')),
      );
    }
  }

  Future<void> _respond(int requestId, bool accept) async {
    try {
      await ApiClient.dio.patch(ApiEndpoints.respondSwapRequest(requestId, accept));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(accept ? 'Đã chấp nhận yêu cầu' : 'Đã từ chối yêu cầu')),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phản hồi thất bại: $e')),
      );
    }
  }

  Future<void> _pickFilterDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDate: _selectedDate ?? now,
    );
    if (picked == null) return;

    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  void _clearFilterDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateRequestSheet(
        creating: _creating,
        schedules: _mySchedules,
        receivers: _staffReceivers,
        onSubmit: _createSwapRequest,
      ),
    );
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final source = _tab == _RequestTab.sent ? _sent : _incoming;
    final items = _selectedDate == null
        ? source
        : source
            .where((e) => e.createdAt != null && _sameDate(e.createdAt!, _selectedDate!))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                const _HeaderCard(),
                const SizedBox(height: 12),
                _TabBar(tab: _tab, onChanged: (t) => setState(() => _tab = t)),
                const SizedBox(height: 10),
                _DateFilterBar(
                  selectedDate: _selectedDate,
                  onPick: _pickFilterDate,
                  onClear: _clearFilterDate,
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_error != null)
                  _ErrorCard(error: _error!, onRetry: _loadData)
                else if (items.isEmpty)
                  const _EmptyCard(message: 'Không có yêu cầu đổi ca')
                else
                  Column(
                    children: [
                      for (final item in items) ...[
                        _RequestCard(
                          item: item,
                          incoming: _tab == _RequestTab.incoming,
                          onAccept: () => _respond(item.id, true),
                          onReject: () => _respond(item.id, false),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                const SizedBox(height: 8),
                _PrimaryButton(
                  label: _creating ? 'Đang gửi...' : '+ Tạo yêu cầu đổi ca',
                  onPressed: _creating ? null : _openCreateSheet,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yêu cầu đổi ca',
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dùng APIs: swap-schedule, my-swap-requests, incoming, respond',
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final _RequestTab tab;
  final ValueChanged<_RequestTab> onChanged;

  const _TabBar({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'Yêu cầu đã gửi',
            selected: tab == _RequestTab.sent,
            onTap: () => onChanged(_RequestTab.sent),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _TabButton(
            label: 'Yêu cầu nhận',
            selected: tab == _RequestTab.incoming,
            onTap: () => onChanged(_RequestTab.incoming),
          ),
        ),
      ],
    );
  }
}

class _DateFilterBar extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onPick;
  final VoidCallback onClear;

  const _DateFilterBar({
    required this.selectedDate,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final text = selectedDate == null
        ? 'Lọc theo ngày tạo'
        : 'Ngày: ${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}';

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.calendar_month),
            label: Text(text),
          ),
        ),
        if (selectedDate != null) ...[
          const SizedBox(width: 8),
          TextButton(onPressed: onClear, child: const Text('Bỏ lọc')),
        ],
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _SwapRequest item;
  final bool incoming;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _RequestCard({
    required this.item,
    required this.incoming,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final badge = _statusBadge(item.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'From #${item.fromScheduleId} -> To #${item.toScheduleId}',
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badge.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge.label,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badge.fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Người gửi: ${item.requesterName} | Người nhận: ${item.receiverName}',
            style: AppTextStyles.arimo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Lý do: ${item.reason}',
            style: AppTextStyles.arimo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (item.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Tạo lúc: ${item.createdAt}',
              style: AppTextStyles.arimo(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (incoming && item.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Chấp nhận'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Từ chối'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  ({String label, Color bg, Color fg}) _statusBadge(String rawStatus) {
    final status = rawStatus.toLowerCase();

    if (status == 'approved') {
      return (
        label: 'Approved',
        bg: const Color(0xFFE8F7EE),
        fg: const Color(0xFF1B7F3A),
      );
    }

    if (status == 'rejected') {
      return (
        label: 'Rejected',
        bg: const Color(0xFFFEE2E2),
        fg: const Color(0xFFB91C1C),
      );
    }

    return (
      label: 'Pending',
      bg: const Color(0xFFFFF6E5),
      fg: const Color(0xFF9A6B00),
    );
  }
}

class _CreateRequestSheet extends StatefulWidget {
  final bool creating;
  final List<_ScheduleOption> schedules;
  final List<_StaffReceiver> receivers;
  final Future<void> Function({
    required int fromScheduleId,
    required int toScheduleId,
    required String receiverId,
    required String reason,
  }) onSubmit;

  const _CreateRequestSheet({
    required this.creating,
    required this.schedules,
    required this.receivers,
    required this.onSubmit,
  });

  @override
  State<_CreateRequestSheet> createState() => _CreateRequestSheetState();
}

class _CreateRequestSheetState extends State<_CreateRequestSheet> {
  int? _fromId;
  int? _toId;
  String? _receiverId;
  final _reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.schedules.isNotEmpty) {
      _fromId = widget.schedules.first.id;
      _toId = widget.schedules.first.id;
    }
    if (widget.receivers.isNotEmpty) {
      _receiverId = widget.receivers.first.id;
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reasonCtrl.text.trim();

    if (_fromId == null || _toId == null || _receiverId == null || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ dữ liệu hợp lệ')),
      );
      return;
    }

    await widget.onSubmit(
      fromScheduleId: _fromId!,
      toScheduleId: _toId!,
      receiverId: _receiverId!,
      reason: reason,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tạo yêu cầu đổi ca',
              style: AppTextStyles.arimo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _fromId,
              isExpanded: true,
              items: widget.schedules
                  .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.label)))
                  .toList(),
              onChanged: (v) => setState(() => _fromId = v),
              decoration: const InputDecoration(labelText: 'From schedule'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _toId,
              isExpanded: true,
              items: widget.schedules
                  .map((e) => DropdownMenuItem<int>(value: e.id, child: Text(e.label)))
                  .toList(),
              onChanged: (v) => setState(() => _toId = v),
              decoration: const InputDecoration(labelText: 'To schedule'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _receiverId,
              isExpanded: true,
              items: widget.receivers
                  .map((e) => DropdownMenuItem<String>(value: e.id, child: Text(e.displayName)))
                  .toList(),
              onChanged: (v) => setState(() => _receiverId = v),
              decoration: const InputDecoration(labelText: 'Người nhận (staff)'),
            ),
            const SizedBox(height: 8),
            TextField(controller: _reasonCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Reason')),
            const SizedBox(height: 12),
            _PrimaryButton(
              label: widget.creating ? 'Đang gửi...' : 'Gửi yêu cầu',
              onPressed: widget.creating ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(label),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorCard({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lỗi: $error', style: AppTextStyles.arimo(color: Colors.red.shade700)),
          const SizedBox(height: 8),
          TextButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;

  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: AppTextStyles.arimo(color: AppColors.textSecondary)),
    );
  }
}

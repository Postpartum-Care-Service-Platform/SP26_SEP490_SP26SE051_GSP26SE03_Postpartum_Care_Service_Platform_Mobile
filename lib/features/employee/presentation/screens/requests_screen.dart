import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../widgets/employee_scaffold.dart';

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

      final sentFuture = ApiClient.dio.get(
        ApiEndpoints.mySwapRequests,
        queryParameters: {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
      );

      final incomingFuture = ApiClient.dio.get(
        ApiEndpoints.myIncomingSwapRequests,
        queryParameters: {
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        },
      );

      final schedulesFuture = ApiClient.dio.get(
        ApiEndpoints.familyScheduleMySchedules,
      );

      final staffsFuture = ApiClient.dio.get(ApiEndpoints.getAllAccounts);

      final results = await Future.wait([
        sentFuture,
        incomingFuture,
        schedulesFuture,
        staffsFuture,
      ]);

      List<_SwapRequest> toSwapRequests(dynamic raw) {
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) => _SwapRequest.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        return const [];
      }

      List<_ScheduleOption> toSchedules(dynamic raw) {
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) => _ScheduleOption.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
        return const [];
      }

      List<_StaffReceiver> toStaffs(dynamic raw) {
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .where(_StaffReceiver.isStaff)
              .map(_StaffReceiver.fromJson)
              .toList();
        }
        return const [];
      }

      final sent = toSwapRequests(results[0].data);
      final incoming = toSwapRequests(results[1].data);
      final schedules = toSchedules(results[2].data);
      final staffs = toStaffs(results[3].data);

      if (!mounted) return;
      setState(() {
        _sent = sent;
        _incoming = incoming;
        _mySchedules = schedules;
        _staffReceivers = staffs;
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

  Future<void> _createRequest() async {
    final fromSchedule = await _pickSchedule();
    if (fromSchedule == null) return;

    final toSchedule = await _pickSchedule(title: 'Chọn lịch muốn đổi');
    if (toSchedule == null) return;

    final receiver = await _pickReceiver();
    if (receiver == null) return;

    final reasonController = TextEditingController();
    if (!mounted) {
      reasonController.dispose();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo yêu cầu đổi lịch'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Lý do đổi lịch',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _creating = true);
    try {
      await ApiClient.dio.post(
        ApiEndpoints.swapStaffSchedule,
        data: {
          'fromScheduleId': fromSchedule.id,
          'toScheduleId': toSchedule.id,
          'receiverId': receiver.id,
          'reason': reasonController.text.trim(),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi yêu cầu đổi lịch.')),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo yêu cầu thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
      reasonController.dispose();
    }
  }

  Future<_ScheduleOption?> _pickSchedule({String title = 'Chọn lịch hiện tại'}) async {
    if (_mySchedules.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có lịch để chọn.')),
        );
      }
      return null;
    }

    return showModalBottomSheet<_ScheduleOption>(
      context: context,
      builder: (ctx) => _SelectBottomSheet<_ScheduleOption>(
        title: title,
        items: _mySchedules,
        labelBuilder: (x) => x.label,
      ),
    );
  }

  Future<_StaffReceiver?> _pickReceiver() async {
    if (_staffReceivers.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có nhân viên để chọn.')),
        );
      }
      return null;
    }

    return showModalBottomSheet<_StaffReceiver>(
      context: context,
      builder: (ctx) => _SelectBottomSheet<_StaffReceiver>(
        title: 'Chọn người nhận yêu cầu',
        items: _staffReceivers,
        labelBuilder: (x) => x.displayName,
      ),
    );
  }

  Future<void> _respondRequest(int requestId, bool approve) async {
    setState(() => _creating = true);
    try {
      await ApiClient.dio.post(
        ApiEndpoints.respondSwapRequest(requestId, approve),
        data: {'approve': approve},
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'Đã chấp nhận yêu cầu.' : 'Đã từ chối yêu cầu.'),
        ),
      );
      await _loadData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xử lý yêu cầu thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
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

    return EmployeeScaffold(
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
                  selected: _selectedDate,
                  onPick: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: _selectedDate ?? DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                  onClear: _selectedDate == null ? null : () => setState(() => _selectedDate = null),
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const _LoadingCard()
                else if (_error != null)
                  _ErrorCard(
                    message: _error!,
                    onRetry: _loadData,
                  )
                else ...[
                  _ActionRow(
                    creating: _creating,
                    onCreate: _createRequest,
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    const _EmptyCard()
                  else
                    ...items.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _RequestCard(
                          request: e,
                          showActions: _tab == _RequestTab.incoming && e.status.toLowerCase() == 'pending',
                          busy: _creating,
                          onApprove: () => _respondRequest(e.id, true),
                          onReject: () => _respondRequest(e.id, false),
                        ),
                      ),
                    ),
                ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yêu cầu đổi lịch 🔁',
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Gửi / nhận yêu cầu đổi ca giữa nhân viên',
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              active: tab == _RequestTab.sent,
              text: 'Đã gửi',
              onTap: () => onChanged(_RequestTab.sent),
            ),
          ),
          Expanded(
            child: _TabButton(
              active: tab == _RequestTab.incoming,
              text: 'Đã nhận',
              onTap: () => onChanged(_RequestTab.incoming),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final bool active;
  final String text;
  final VoidCallback onTap;

  const _TabButton({required this.active, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTextStyles.arimo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DateFilterBar extends StatelessWidget {
  final DateTime? selected;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _DateFilterBar({required this.selected, required this.onPick, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final label = selected == null
        ? 'Lọc theo ngày (tùy chọn)'
        : 'Ngày: ${selected!.day.toString().padLeft(2, '0')}/${selected!.month.toString().padLeft(2, '0')}/${selected!.year}';

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.borderLight),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        if (selected != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.close),
            tooltip: 'Xóa lọc ngày',
          ),
        ],
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final bool creating;
  final VoidCallback onCreate;

  const _ActionRow({required this.creating, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: creating ? null : onCreate,
      icon: creating
          ? const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
            )
          : const Icon(Icons.swap_horiz),
      label: Text(creating ? 'Đang xử lý...' : 'Tạo yêu cầu đổi lịch'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Không tải được dữ liệu',
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: AppTextStyles.arimo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Chưa có yêu cầu nào trong phạm vi thời gian này.',
        textAlign: TextAlign.center,
        style: AppTextStyles.arimo(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final _SwapRequest request;
  final bool showActions;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _RequestCard({
    required this.request,
    required this.showActions,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final statusLower = request.status.toLowerCase();
    final isPending = statusLower == 'pending';
    final isApproved = statusLower == 'approved';
    final statusColor = isApproved
        ? const Color(0xFF1B7F3A)
        : isPending
            ? const Color(0xFF9A6B00)
            : const Color(0xFFB91C1C);
    final statusBg = isApproved
        ? const Color(0xFFE8F7EE)
        : isPending
            ? const Color(0xFFFFF6E5)
            : const Color(0xFFFEE2E2);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${request.requesterName} → ${request.receiverName}',
                  style: AppTextStyles.arimo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  request.status,
                  style: AppTextStyles.arimo(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lịch hiện tại: #${request.fromScheduleId}  •  Lịch muốn đổi: #${request.toScheduleId}',
            style: AppTextStyles.arimo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Lý do: ${request.reason.isEmpty ? '(Không có)' : request.reason}',
            style: AppTextStyles.arimo(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (request.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Tạo lúc: ${request.createdAt!.day.toString().padLeft(2, '0')}/${request.createdAt!.month.toString().padLeft(2, '0')}/${request.createdAt!.year} ${request.createdAt!.hour.toString().padLeft(2, '0')}:${request.createdAt!.minute.toString().padLeft(2, '0')}',
              style: AppTextStyles.arimo(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (showActions) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: busy ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFB91C1C)),
                      foregroundColor: const Color(0xFFB91C1C),
                    ),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    onPressed: busy ? null : onApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1B7F3A),
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Chấp nhận'),
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

class _SelectBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<T> items;
  final String Function(T) labelBuilder;

  const _SelectBottomSheet({
    required this.title,
    required this.items,
    required this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) {
                final item = items[i];
                return ListTile(
                  title: Text(labelBuilder(item)),
                  onTap: () => Navigator.pop(ctx, item),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

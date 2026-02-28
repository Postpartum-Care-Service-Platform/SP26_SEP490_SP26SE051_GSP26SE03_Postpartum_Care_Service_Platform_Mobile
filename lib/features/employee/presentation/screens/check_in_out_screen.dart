import 'package:flutter/material.dart';

import '../../../../core/apis/api_client.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../widgets/employee_header_bar.dart';
import '../widgets/employee_scaffold.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<_StaffScheduleItem> _schedules = const [];

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(days: 7));
      final to = now.add(const Duration(days: 7));

      final response = await ApiClient.dio.get(
        ApiEndpoints.myStaffSchedules,
        queryParameters: {'from': _dateOnly(from), 'to': _dateOnly(to)},
      );

      final data = response.data as List<dynamic>;
      final schedules = data
          .map((e) => _StaffScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList();

      if (!mounted) return;
      setState(() {
        _schedules = schedules;
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

  Future<void> _check(_StaffScheduleItem item, {String? note}) async {
    if (_submitting) return;

    setState(() {
      _submitting = true;
    });

    try {
      await ApiClient.dio.patch(
        ApiEndpoints.checkStaffSchedule,
        data: {'staffScheduleId': item.id, 'note': note},
      );

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Check thành công')));
      await _loadSchedules();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Check thất bại: $e')));
      setState(() {
        _submitting = false;
      });
    }
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    final current = _schedules.where((e) => !e.isChecked).isNotEmpty
        ? _schedules.firstWhere((e) => !e.isChecked)
        : (_schedules.isNotEmpty ? _schedules.first : null);
    final history = _schedules.where((e) => e.isChecked).toList();

    return EmployeeScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const EmployeeHeaderBar(
              title: 'Portal Nhân viên',
              subtitle: 'Quản lý công việc',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadSchedules,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      const _HeaderCard(),
                      const SizedBox(height: 12),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        _ErrorCard(error: _error!, onRetry: _loadSchedules)
                      else if (current == null)
                        const _EmptyCard(
                          message: 'Không có lịch làm việc để check',
                        )
                      else
                        _CurrentShiftCard(
                          item: current,
                          submitting: _submitting,
                          onCheck: (note) => _check(current, note: note),
                        ),
                      const SizedBox(height: 16),
                      const _SectionTitle(
                        icon: Icons.history,
                        title: 'Lịch sử check',
                      ),
                      const SizedBox(height: 8),
                      if (history.isEmpty)
                        const _EmptyCard(message: 'Chưa có lịch sử check')
                      else
                        Column(
                          children: [
                            for (final item in history)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _HistoryCard(item: item),
                              ),
                          ],
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaffScheduleItem {
  final int id;
  final bool isChecked;
  final DateTime? checkedAt;
  final String familyName;
  final String? shiftLabel;

  const _StaffScheduleItem({
    required this.id,
    required this.isChecked,
    required this.checkedAt,
    required this.familyName,
    required this.shiftLabel,
  });

  factory _StaffScheduleItem.fromJson(Map<String, dynamic> json) {
    final familySchedule =
        json['familyScheduleResponse'] as Map<String, dynamic>?;
    return _StaffScheduleItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      isChecked: json['isChecked'] as bool? ?? false,
      checkedAt: DateTime.tryParse((json['checkedAt'] ?? '').toString()),
      familyName: (familySchedule?['name'] ?? 'Ca làm việc').toString(),
      shiftLabel: familySchedule?['session']?.toString(),
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
            'Check-in / Check-out',
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dùng API StaffSchedule/check',
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

class _CurrentShiftCard extends StatefulWidget {
  final _StaffScheduleItem item;
  final bool submitting;
  final ValueChanged<String?> onCheck;

  const _CurrentShiftCard({
    required this.item,
    required this.submitting,
    required this.onCheck,
  });

  @override
  State<_CurrentShiftCard> createState() => _CurrentShiftCardState();
}

class _CurrentShiftCardState extends State<_CurrentShiftCard> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.item.familyName,
            style: AppTextStyles.arimo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (widget.item.shiftLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              'Ca: ${widget.item.shiftLabel}',
              style: AppTextStyles.arimo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ghi chú check (tuỳ chọn)',
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.submitting
                  ? null
                  : () => widget.onCheck(
                      _noteController.text.trim().isEmpty
                          ? null
                          : _noteController.text.trim(),
                    ),
              child: Text(widget.submitting ? 'Đang gửi...' : 'Check ngay'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final _StaffScheduleItem item;

  const _HistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1B7F3A)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.familyName,
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.checkedAt != null
                      ? 'Checked lúc: ${item.checkedAt}'
                      : 'Đã checked',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Text(
            'Lỗi tải dữ liệu: $error',
            style: AppTextStyles.arimo(color: Colors.red.shade700),
          ),
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
      child: Text(
        message,
        style: AppTextStyles.arimo(color: AppColors.textSecondary),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.arimo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

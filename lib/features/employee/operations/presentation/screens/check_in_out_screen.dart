import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/apis/api_endpoints.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_header_bar.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  bool _loading = true;
  String? _error;
  DateTime _focusedDate = DateTime.now();
  List<_ScheduleSlot> _slots = const [];

  @override
  void initState() {
    super.initState();
    _loadMonthSchedules();
  }

  Future<void> _loadMonthSchedules() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final firstDay = DateTime(_focusedDate.year, _focusedDate.month, 1);
      final lastDay = DateTime(_focusedDate.year, _focusedDate.month + 1, 0);

      final from = _dateOnly(firstDay);
      final to = _dateOnly(lastDay);

      final response = await ApiClient.dio.get(
        ApiEndpoints.staffsNoScheduled(from, to),
      );

      final data = (response.data as List<dynamic>? ?? const []);
      final slots = data
          .map((e) => _ScheduleSlot.fromJson(e as Map<String, dynamic>))
          .where((e) => e.startAt != null)
          .toList()
        ..sort((a, b) => a.startAt!.compareTo(b.startAt!));

      if (!mounted) return;
      setState(() {
        _slots = slots.isEmpty ? _buildDefaultSeed(firstDay) : slots;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không tải được lịch: $e';
        _slots = _buildDefaultSeed(DateTime(_focusedDate.year, _focusedDate.month, 1));
        _loading = false;
      });
    }
  }

  List<_ScheduleSlot> _buildDefaultSeed(DateTime baseDate) {
    final anchor = DateTime(baseDate.year, baseDate.month, 10, 14, 0);
    return [
      _ScheduleSlot(
        id: -1,
        title: 'Lịch mẫu mặc định',
        subtitle: 'Dữ liệu mẫu để staff dễ theo dõi',
        startAt: anchor,
        endAt: anchor.add(const Duration(hours: 2)),
        isChecked: false,
      ),
    ];
  }

  String _dateOnly(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  void _goToToday() {
    setState(() {
      _focusedDate = DateTime.now();
    });
    _loadMonthSchedules();
  }

  void _shiftWeek(int deltaWeek) {
    setState(() {
      _focusedDate = _focusedDate.add(Duration(days: 7 * deltaWeek));
    });
    _loadMonthSchedules();
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return EmployeeScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const EmployeeHeaderBar(
              title: 'Portal Nhân viên',
              subtitle: 'Lịch làm việc kiểu Outlook',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMonthSchedules,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: padding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      _ScheduleToolbar(
                        focusedDate: _focusedDate,
                        onToday: _goToToday,
                        onPreviousWeek: () => _shiftWeek(-1),
                        onNextWeek: () => _shiftWeek(1),
                      ),
                      const SizedBox(height: 12),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_error != null)
                        _ErrorCard(error: _error!)
                      else
                        _OutlookWeekGrid(
                          focusedDate: _focusedDate,
                          allSlots: _slots,
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

class _ScheduleSlot {
  final int id;
  final String title;
  final String subtitle;
  final DateTime? startAt;
  final DateTime? endAt;
  final bool isChecked;

  const _ScheduleSlot({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startAt,
    required this.endAt,
    required this.isChecked,
  });

  factory _ScheduleSlot.fromJson(Map<String, dynamic> json) {
    final familySchedule = json['familyScheduleResponse'] as Map<String, dynamic>?;
    final dateRaw = familySchedule?['date']?.toString() ??
        familySchedule?['scheduleDate']?.toString() ??
        familySchedule?['startDate']?.toString();
    final sessionRaw =
        (familySchedule?['session'] ?? familySchedule?['timeSlot'] ?? '').toString();

    final parsedDate = DateTime.tryParse(dateRaw ?? '');
    final startAt = _composeDateTime(parsedDate, sessionRaw, isEnd: false);
    final endAt = _composeDateTime(parsedDate, sessionRaw, isEnd: true);

    return _ScheduleSlot(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (familySchedule?['name'] ?? familySchedule?['title'] ?? 'Lịch làm việc').toString(),
      subtitle: sessionRaw.isEmpty ? 'Ca làm việc' : sessionRaw,
      startAt: startAt,
      endAt: endAt,
      isChecked: json['isChecked'] as bool? ?? false,
    );
  }

  static DateTime? _composeDateTime(DateTime? date, String session, {required bool isEnd}) {
    if (date == null) return null;

    final normalized = session.toLowerCase();
    int startHour = 8;
    int endHour = 10;

    if (normalized.contains('sáng') || normalized.contains('morning')) {
      startHour = 8;
      endHour = 10;
    } else if (normalized.contains('trưa') || normalized.contains('noon')) {
      startHour = 11;
      endHour = 13;
    } else if (normalized.contains('chiều') || normalized.contains('afternoon')) {
      startHour = 14;
      endHour = 17;
    } else if (normalized.contains('tối') || normalized.contains('evening')) {
      startHour = 18;
      endHour = 20;
    }

    final hour = isEnd ? endHour : startHour;
    return DateTime(date.year, date.month, date.day, hour, 0);
  }
}

class _ScheduleToolbar extends StatelessWidget {
  final DateTime focusedDate;
  final VoidCallback onToday;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const _ScheduleToolbar({
    required this.focusedDate,
    required this.onToday,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 10 * scale),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: onToday,
            icon: const Icon(Icons.today),
            label: const Text('Hôm nay'),
          ),
          IconButton(onPressed: onPreviousWeek, icon: const Icon(Icons.chevron_left)),
          IconButton(onPressed: onNextWeek, icon: const Icon(Icons.chevron_right)),
          const Spacer(),
          Text(
            DateFormat('MM/yyyy').format(focusedDate),
            style: AppTextStyles.arimo(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlookWeekGrid extends StatelessWidget {
  final DateTime focusedDate;
  final List<_ScheduleSlot> allSlots;

  const _OutlookWeekGrid({required this.focusedDate, required this.allSlots});

  List<DateTime> _weekDays(DateTime anchor) {
    final weekday = anchor.weekday;
    final monday = anchor.subtract(Duration(days: weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final days = _weekDays(focusedDate);
    final hours = List.generate(12, (index) => 8 + index);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 860 * scale,
          child: Column(
            children: [
              _WeekHeader(days: days),
              for (final hour in hours)
                _HourRow(
                  hour: hour,
                  days: days,
                  slots: allSlots,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  final List<DateTime> days;

  const _WeekHeader({required this.days});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        Container(
          width: 72 * scale,
          padding: EdgeInsets.all(8 * scale),
          alignment: Alignment.center,
          child: Text(
            'Giờ',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        for (final day in days)
          Container(
            width: 112 * scale,
            padding: EdgeInsets.symmetric(vertical: 8 * scale),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.8)),
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  DateFormat('dd').format(day),
                  style: AppTextStyles.arimo(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0B57D0),
                  ),
                ),
                Text(
                  DateFormat('EEE', 'vi_VN').format(day),
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HourRow extends StatelessWidget {
  final int hour;
  final List<DateTime> days;
  final List<_ScheduleSlot> slots;

  const _HourRow({required this.hour, required this.days, required this.slots});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return SizedBox(
      height: 86 * scale,
      child: Row(
        children: [
          Container(
            width: 72 * scale,
            alignment: Alignment.topCenter,
            padding: EdgeInsets.only(top: 8 * scale),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Text(
              '${hour.toString().padLeft(2, '0')}h',
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          for (final day in days)
            _HourCell(day: day, hour: hour, slots: slots),
        ],
      ),
    );
  }
}

class _HourCell extends StatelessWidget {
  final DateTime day;
  final int hour;
  final List<_ScheduleSlot> slots;

  const _HourCell({required this.day, required this.hour, required this.slots});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    final matched = slots.where((slot) {
      final start = slot.startAt;
      if (start == null) return false;
      final sameDate = start.year == day.year && start.month == day.month && start.day == day.day;
      return sameDate && start.hour == hour;
    }).toList();

    return Container(
      width: 112 * scale,
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.8)),
          top: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: matched.isEmpty
          ? const SizedBox.shrink()
          : Column(
              children: [
                for (final item in matched) _ScheduleEventCard(item: item),
              ],
            ),
    );
  }
}

class _ScheduleEventCard extends StatelessWidget {
  final _ScheduleSlot item;

  const _ScheduleEventCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 4 * scale),
      padding: EdgeInsets.all(6 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: const Color(0xFF8BB8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.arimo(
              fontSize: 10 * scale,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;

  const _ErrorCard({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        error,
        style: AppTextStyles.arimo(color: Colors.red.shade700),
      ),
    );
  }
}

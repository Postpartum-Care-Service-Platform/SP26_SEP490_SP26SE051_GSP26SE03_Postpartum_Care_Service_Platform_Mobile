// lib/features/family/presentation/screens/tabs/care_schedule_tab.dart
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';

class CareScheduleTab extends StatefulWidget {
  const CareScheduleTab({super.key});

  @override
  State<CareScheduleTab> createState() => _CareScheduleTabState();
}

class _CareScheduleTabState extends State<CareScheduleTab> {
  // Selected date in ISO format yyyy-mm-dd.
  late String _selectedDate;

  // Utility services modal visibility.
  bool _showServicesSheet = false;

  // Drag/drop is not applicable in Flutter mobile; we will use "select time slot" instead.
  // We keep the limit rule: max 2 utility services/day.

  // Ported schedule items from CareSchedule.tsx.
  late List<_ScheduleItem> _scheduleItems;

  // Ported available services from CareSchedule.tsx.
  static const List<_ServiceRequest> _availableServices = [
    _ServiceRequest(
      id: 's1',
      name: 'Spa & Massage',
      duration: '60-90 phút',
      price: '500k-1.2tr',
      tone: _ServiceTone.pink,
    ),
    _ServiceRequest(
      id: 's2',
      name: 'Yoga phục hồi',
      duration: '60 phút',
      price: '350k',
      tone: _ServiceTone.green,
    ),
    _ServiceRequest(
      id: 's3',
      name: 'Chụp ảnh kỷ niệm',
      duration: '90-120 phút',
      price: '1.5tr-3tr',
      tone: _ServiceTone.purple,
    ),
    _ServiceRequest(
      id: 's4',
      name: 'Tư vấn dinh dưỡng',
      duration: '30-45 phút',
      price: '400k',
      tone: _ServiceTone.red,
    ),
    _ServiceRequest(
      id: 's5',
      name: 'Phòng Gym',
      duration: '45-60 phút',
      price: '300k-500k',
      tone: _ServiceTone.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _selectedDate = '2024-11-25';

    _scheduleItems = [
      _ScheduleItem(
        id: '1',
        time: '06:00 - 08:00',
        activity: 'Kiểm tra sức khỏe buổi sáng',
        type: 'Chăm sóc mẹ',
        staff: 'Điều dưỡng Mai',
        status: _ScheduleStatus.completed,
        notes: 'Huyết áp: 120/80, Nhiệt độ: 36.5°C, Mạch: 75 nhịp/phút. Sức khỏe tốt.',
        completedAt: '07:45',
      ),
      _ScheduleItem(
        id: '2',
        time: '08:00 - 09:00',
        activity: 'Ăn sáng & Uống thuốc',
        type: 'Dinh dưỡng',
        staff: 'Điều dưỡng Mai',
        status: _ScheduleStatus.completed,
        notes: 'Đã dùng: Cháo gà, bánh mì, sữa. Uống vitamin sau bữa ăn.',
        completedAt: '08:50',
      ),
      _ScheduleItem(
        id: '3',
        time: '09:00 - 10:00',
        activity: 'Chăm sóc bé - Tắm rửa',
        type: 'Chăm sóc bé',
        staff: 'Nữ hộ sinh Lan',
        status: _ScheduleStatus.completed,
        notes: 'Bé tắm xong, da khô ráo. Thay tã mới. Bé ngủ ngoan.',
        completedAt: '09:55',
      ),
      _ScheduleItem(
        id: '4',
        time: '10:00 - 11:00',
        activity: 'Massage phục hồi',
        type: 'Chăm sóc mẹ',
        staff: 'Điều dưỡng Mai',
        status: _ScheduleStatus.inProgress,
      ),
      _ScheduleItem(
        id: '5',
        time: '11:00 - 12:00',
        activity: 'Nghỉ ngơi',
        type: 'Nghỉ ngơi',
        staff: 'N/A',
        status: _ScheduleStatus.pending,
      ),
      _ScheduleItem(
        id: '6',
        time: '12:00 - 13:00',
        activity: 'Bữa trưa',
        type: 'Dinh dưỡng',
        staff: 'Điều dưỡng Hoa',
        status: _ScheduleStatus.pending,
      ),
      _ScheduleItem(
        id: '7',
        time: '14:00 - 15:00',
        activity: 'Nghỉ ngơi',
        type: 'Nghỉ ngơi',
        staff: 'N/A',
        status: _ScheduleStatus.pending,
      ),
      _ScheduleItem(
        id: '8',
        time: '15:00 - 16:00',
        activity: 'Tư vấn chăm sóc bé',
        type: 'Chăm sóc bé',
        staff: 'Nữ hộ sinh Lan',
        status: _ScheduleStatus.pending,
      ),
      _ScheduleItem(
        id: '9',
        time: '18:00 - 19:00',
        activity: 'Bữa tối',
        type: 'Dinh dưỡng',
        staff: 'Điều dưỡng Hoa',
        status: _ScheduleStatus.pending,
      ),
      _ScheduleItem(
        id: '10',
        time: '20:00 - 21:00',
        activity: 'Kiểm tra sức khỏe buổi tối',
        type: 'Chăm sóc mẹ',
        staff: 'Điều dưỡng Hoa',
        status: _ScheduleStatus.pending,
      ),
    ];
  }

  Future<void> _pickDate() async {
    final current = DateTime.tryParse(_selectedDate) ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'Chọn ngày',
    );

    if (picked == null) {
      return;
    }

    final iso = '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';

    setState(() {
      _selectedDate = iso;
    });
  }

  void _setToday() {
    final now = DateTime.now();
    final iso = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    setState(() {
      _selectedDate = iso;
    });
  }

  int _utilityServicesCount() {
    return _scheduleItems.where((e) => e.type == 'Dịch vụ tiện ích').length;
  }

  void _addUtilityService({required _ServiceRequest service, required _ScheduleItem slot}) {
    final utilityCount = _utilityServicesCount();

    if (utilityCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ Chỉ được đặt tối đa 2 dịch vụ tiện ích trong 1 ngày!',
            style: AppTextStyles.arimo(color: AppColors.white),
          ),
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }

    final newItem = _ScheduleItem(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      time: slot.time,
      activity: 'Yêu cầu: ${service.name}',
      type: 'Dịch vụ tiện ích',
      staff: 'Chờ phân công',
      status: _ScheduleStatus.pending,
      notes: 'Thời lượng: ${service.duration}, Chi phí: ${service.price}',
    );

    setState(() {
      _scheduleItems = [..._scheduleItems, newItem];
      _showServicesSheet = false;
    });

    final remaining = 2 - (utilityCount + 1);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Đã tạo yêu cầu ${service.name} vào khung giờ ${slot.time}. Còn lại $remaining dịch vụ tiện ích hôm nay.',
          style: AppTextStyles.arimo(color: AppColors.white),
        ),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  double _progressRatio() {
    if (_scheduleItems.isEmpty) {
      return 0;
    }

    final completed = _scheduleItems.where((e) => e.status == _ScheduleStatus.completed).length;

    return completed / _scheduleItems.length;
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: In TS, background is #fffaf4. In Flutter we already have AppColors.background.
    return Stack(
      children: [
        Column(
          children: [
            // Header.
            _Header(
              selectedDate: _selectedDate,
              onPickDate: _pickDate,
              onToday: _setToday,
              utilityRemaining: 2 - _utilityServicesCount(),
            ),

            // List.
            Expanded(
              child: ListView(
                padding: AppResponsive.pagePadding(context).copyWith(top: 16, bottom: 120),
                children: [
                  for (final item in _scheduleItems) ...[
                    _ScheduleCard(
                      item: item,
                      onTapAddService: () {
                        setState(() {
                          _showServicesSheet = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                  ],

                  _ProgressSummary(
                    completed: _scheduleItems.where((e) => e.status == _ScheduleStatus.completed).length,
                    inProgress: _scheduleItems.where((e) => e.status == _ScheduleStatus.inProgress).length,
                    total: _scheduleItems.length,
                    ratio: _progressRatio(),
                  ),

                  const SizedBox(height: 12),

                  const _InstructionCard(),
                ],
              ),
            ),
          ],
        ),

        // Floating + button (open services).
        Positioned(
          right: 16,
          bottom: 96,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showServicesSheet = true;
              });
            },
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.familyPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: AppColors.white, size: 28),
            ),
          ),
        ),

        // Bottom sheet modal.
        if (_showServicesSheet)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showServicesSheet = false;
                });
              },
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {},
                  child: _ServicesSheet(
                    remaining: 2 - _utilityServicesCount(),
                    services: _availableServices,
                    scheduleSlots: _scheduleItems,
                    onClose: () {
                      setState(() {
                        _showServicesSheet = false;
                      });
                    },
                    onSelect: (service, slot) => _addUtilityService(service: service, slot: slot),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String selectedDate;
  final VoidCallback onPickDate;
  final VoidCallback onToday;
  final int utilityRemaining;

  const _Header({
    required this.selectedDate,
    required this.onPickDate,
    required this.onToday,
    required this.utilityRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lịch chăm sóc hàng ngày',
            style: AppTextStyles.arimo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.white,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, size: 18, color: AppColors.familyPrimary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedDate,
                            style: AppTextStyles.arimo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onToday,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.familyPrimary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Hôm nay',
                  style: AppTextStyles.arimo(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: utilityRemaining > 0 ? const Color(0xFFE8F7EE) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: utilityRemaining > 0 ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
              ),
            ),
            child: Text(
              utilityRemaining > 0
                  ? '📌 Còn $utilityRemaining/2 dịch vụ tiện ích'
                  : '❌ Đã đạt giới hạn 2 dịch vụ/ngày',
              style: AppTextStyles.arimo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: utilityRemaining > 0 ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final _ScheduleItem item;
  final VoidCallback onTapAddService;

  const _ScheduleCard({required this.item, required this.onTapAddService});

  @override
  Widget build(BuildContext context) {
    final config = _StatusConfig.fromStatus(item.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Text(
                  item.time,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.familyPrimary,
                  ),
                ),
              ),
              _StatusChip(config: config),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(config.icon, size: 18, color: config.iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.activity,
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.type,
            style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.familyPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Nhân viên: ${item.staff}',
                  style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
              if (item.completedAt != null) ...[
                const SizedBox(width: 8),
                Text(
                  item.completedAt!,
                  style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ],
          ),
          if (item.notes != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.message_outlined, size: 14, color: AppColors.familyPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ghi chú:', style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(
                          item.notes!,
                          style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (item.type == 'Dịch vụ tiện ích') ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onTapAddService,
              icon: const Icon(Icons.add, size: 16),
              label: Text('Thêm dịch vụ', style: AppTextStyles.arimo(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.familyPrimary,
                side: BorderSide(color: AppColors.borderLight),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _StatusConfig config;

  const _StatusChip({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config.badgeBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: config.badgeBorder),
      ),
      child: Text(
        config.label,
        style: AppTextStyles.arimo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: config.badgeText,
        ),
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int total;
  final double ratio;

  const _ProgressSummary({
    required this.completed,
    required this.inProgress,
    required this.total,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (ratio * 100).clamp(0, 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.familyPrimary, Color(0xFFFFA952)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan hôm nay',
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 10),
          _SummaryRow(label: 'Hoàn thành:', value: '$completed/$total công việc'),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Đang thực hiện:', value: '$inProgress công việc'),
          const SizedBox(height: 6),
          _SummaryRow(label: 'Tiến độ:', value: '$pct%'),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              backgroundColor: AppColors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(fontSize: 12, color: AppColors.white.withValues(alpha: 0.9)),
        ),
        Text(
          value,
          style: AppTextStyles.arimo(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.white),
        ),
      ],
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF2563EB), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hướng dẫn:',
                  style: AppTextStyles.arimo(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 6),
                Text(
                  '• Nhấn nút + để xem dịch vụ tiện ích\n• Tối đa 2 dịch vụ/ngày',
                  style: AppTextStyles.arimo(fontSize: 12, color: const Color(0xFF1E40AF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesSheet extends StatelessWidget {
  final int remaining;
  final List<_ServiceRequest> services;
  final List<_ScheduleItem> scheduleSlots;
  final VoidCallback onClose;
  final void Function(_ServiceRequest service, _ScheduleItem slot) onSelect;

  const _ServicesSheet({
    required this.remaining,
    required this.services,
    required this.scheduleSlots,
    required this.onClose,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Use only base slots (not including any newly added utility items).
    final timeSlots = scheduleSlots.where((e) => !e.id.startsWith('req-')).toList();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 520),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Dịch vụ tiện ích',
                    style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                remaining > 0 ? '📌 Còn $remaining/2 dịch vụ tiện ích' : '❌ Đã đạt giới hạn 2 dịch vụ/ngày',
                style: AppTextStyles.arimo(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: remaining > 0 ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                for (final service in services) ...[
                  _ServiceTile(
                    service: service,
                    onTap: remaining > 0
                        ? () async {
                            final slot = await _pickTimeSlot(context, timeSlots);
                            if (slot == null) {
                              return;
                            }
                            onSelect(service, slot);
                          }
                        : null,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<_ScheduleItem?> _pickTimeSlot(BuildContext context, List<_ScheduleItem> slots) async {
    return showModalBottomSheet<_ScheduleItem>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Chọn khung giờ',
                style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              for (final slot in slots)
                ListTile(
                  title: Text(slot.time, style: AppTextStyles.arimo(fontWeight: FontWeight.w700)),
                  subtitle: Text(slot.activity, style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary)),
                  onTap: () => Navigator.of(context).pop(slot),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final _ServiceRequest service;
  final VoidCallback? onTap;

  const _ServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tone = _ServiceToneConfig.fromTone(service.tone);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tone.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tone.border, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service.name,
              style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w700, color: tone.text),
            ),
            const SizedBox(height: 10),
            Text('⏱️ ${service.duration}', style: AppTextStyles.arimo(fontSize: 12, color: tone.text.withValues(alpha: 0.9))),
            const SizedBox(height: 6),
            Text('💰 ${service.price}', style: AppTextStyles.arimo(fontSize: 12, color: tone.text.withValues(alpha: 0.9))),
          ],
        ),
      ),
    );
  }
}

enum _ScheduleStatus {
  completed,
  inProgress,
  pending,
  cancelled,
}

class _ScheduleItem {
  final String id;
  final String time;
  final String activity;
  final String type;
  final String staff;
  final _ScheduleStatus status;
  final String? notes;
  final String? completedAt;

  const _ScheduleItem({
    required this.id,
    required this.time,
    required this.activity,
    required this.type,
    required this.staff,
    required this.status,
    this.notes,
    this.completedAt,
  });
}

class _StatusConfig {
  final Color badgeBackground;
  final Color badgeBorder;
  final Color badgeText;
  final Color background;
  final IconData icon;
  final Color iconColor;
  final String label;

  const _StatusConfig({
    required this.badgeBackground,
    required this.badgeBorder,
    required this.badgeText,
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  factory _StatusConfig.fromStatus(_ScheduleStatus status) {
    switch (status) {
      case _ScheduleStatus.completed:
        return const _StatusConfig(
          badgeBackground: Color(0xFFDCFCE7),
          badgeBorder: Color(0xFFBBF7D0),
          badgeText: Color(0xFF15803D),
          background: Color(0xFFF0FDF4),
          icon: Icons.check_circle,
          iconColor: Color(0xFF16A34A),
          label: 'Hoàn thành',
        );
      case _ScheduleStatus.inProgress:
        return const _StatusConfig(
          badgeBackground: Color(0xFFDBEAFE),
          badgeBorder: Color(0xFFBFDBFE),
          badgeText: Color(0xFF1D4ED8),
          background: Color(0xFFEFF6FF),
          icon: Icons.access_time,
          iconColor: Color(0xFF2563EB),
          label: 'Đang thực hiện',
        );
      case _ScheduleStatus.pending:
        return _StatusConfig(
          badgeBackground: const Color(0xFFF3F4F6),
          badgeBorder: AppColors.borderLight,
          badgeText: const Color(0xFF374151),
          background: AppColors.white,
          icon: Icons.error_outline,
          iconColor: const Color(0xFF9CA3AF),
          label: 'Chưa thực hiện',
        );
      case _ScheduleStatus.cancelled:
        return const _StatusConfig(
          badgeBackground: Color(0xFFFEE2E2),
          badgeBorder: Color(0xFFFECACA),
          badgeText: Color(0xFFB91C1C),
          background: Color(0xFFFFF1F2),
          icon: Icons.cancel,
          iconColor: Color(0xFFDC2626),
          label: 'Đã hủy',
        );
    }
  }
}

enum _ServiceTone { pink, green, purple, red, blue }

class _ServiceRequest {
  final String id;
  final String name;
  final String duration;
  final String price;
  final _ServiceTone tone;

  const _ServiceRequest({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.tone,
  });
}

class _ServiceToneConfig {
  final Color background;
  final Color border;
  final Color text;

  const _ServiceToneConfig({required this.background, required this.border, required this.text});

  factory _ServiceToneConfig.fromTone(_ServiceTone tone) {
    switch (tone) {
      case _ServiceTone.pink:
        return const _ServiceToneConfig(
          background: Color(0xFFFDF2F8),
          border: Color(0xFFFBCFE8),
          text: Color(0xFFBE185D),
        );
      case _ServiceTone.green:
        return const _ServiceToneConfig(
          background: Color(0xFFECFDF5),
          border: Color(0xFFBBF7D0),
          text: Color(0xFF15803D),
        );
      case _ServiceTone.purple:
        return const _ServiceToneConfig(
          background: Color(0xFFFAF5FF),
          border: Color(0xFFE9D5FF),
          text: Color(0xFF7E22CE),
        );
      case _ServiceTone.red:
        return const _ServiceToneConfig(
          background: Color(0xFFFEF2F2),
          border: Color(0xFFFECACA),
          text: Color(0xFFB91C1C),
        );
      case _ServiceTone.blue:
        return const _ServiceToneConfig(
          background: Color(0xFFEFF6FF),
          border: Color(0xFFBFDBFE),
          text: Color(0xFF1D4ED8),
        );
    }
  }
}

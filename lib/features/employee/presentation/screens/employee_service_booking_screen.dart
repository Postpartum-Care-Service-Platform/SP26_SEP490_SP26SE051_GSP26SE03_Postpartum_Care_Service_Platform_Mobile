// lib/features/employee/presentation/screens/employee_service_booking_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class EmployeeServiceBookingScreen extends StatefulWidget {
  const EmployeeServiceBookingScreen({super.key});

  @override
  State<EmployeeServiceBookingScreen> createState() =>
      _EmployeeServiceBookingScreenState();
}

enum _ServiceTab { services, myBookings }

class _ServiceModel {
  final String name;
  final String description;
  final String duration;
  final String price;
  final List<Color> gradient;
  final Color bg;
  final IconData icon;

  const _ServiceModel({
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.gradient,
    required this.bg,
    required this.icon,
  });
}

class _BookingModel {
  final String service;
  final DateTime date;
  final String time;
  final String family;
  final String room;
  final _BookingStatus status;
  final String createdBy;

  const _BookingModel({
    required this.service,
    required this.date,
    required this.time,
    required this.family,
    required this.room,
    required this.status,
    required this.createdBy,
  });
}

enum _BookingStatus { confirmed, pending }

extension _BookingStatusX on _BookingStatus {
  String get label => this == _BookingStatus.confirmed ? 'Đã xác nhận' : 'Chờ xác nhận';

  Color get bg => this == _BookingStatus.confirmed
      ? const Color(0xFFE8F7EE)
      : const Color(0xFFFFF6E5);

  Color get fg => this == _BookingStatus.confirmed
      ? const Color(0xFF1B7F3A)
      : const Color(0xFF9A6B00);
}

class _EmployeeServiceBookingScreenState extends State<EmployeeServiceBookingScreen> {
  _ServiceTab _tab = _ServiceTab.services;

  static const _services = <_ServiceModel>[
    _ServiceModel(
      name: 'Spa & Massage',
      description: 'Massage thư giãn, chăm sóc da mặt, điều trị sau sinh',
      duration: '60-90 phút',
      price: '500.000 - 1.200.000đ',
      gradient: [Color(0xFFEC4899), Color(0xFFDB2777)],
      bg: Color(0xFFFDF2F8),
      icon: Icons.auto_awesome,
    ),
    _ServiceModel(
      name: 'Phòng Gym',
      description: 'Tập luyện phục hồi, yoga sau sinh có huấn luyện viên',
      duration: '45-60 phút',
      price: '300.000 - 500.000đ',
      gradient: [Color(0xFF60A5FA), Color(0xFF2563EB)],
      bg: Color(0xFFEFF6FF),
      icon: Icons.fitness_center,
    ),
    _ServiceModel(
      name: 'Tư vấn dinh dưỡng',
      description: 'Tư vấn chế độ ăn cho mẹ sau sinh và bé',
      duration: '30-45 phút',
      price: '400.000đ',
      gradient: [Color(0xFFF87171), Color(0xFFDC2626)],
      bg: Color(0xFFFEF2F2),
      icon: Icons.favorite,
    ),
    _ServiceModel(
      name: 'Chụp ảnh kỷ niệm',
      description: 'Chụp ảnh newborn, ảnh gia đình tại studio chuyên nghiệp',
      duration: '90-120 phút',
      price: '1.500.000 - 3.000.000đ',
      gradient: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
      bg: Color(0xFFFAF5FF),
      icon: Icons.camera_alt,
    ),
    _ServiceModel(
      name: 'Yoga phục hồi',
      description: 'Lớp yoga nhẹ nhàng cho mẹ sau sinh',
      duration: '60 phút',
      price: '350.000đ',
      gradient: [Color(0xFF34D399), Color(0xFF059669)],
      bg: Color(0xFFECFDF5),
      icon: Icons.self_improvement,
    ),
    _ServiceModel(
      name: 'Cafe & Thư giãn',
      description: 'Khu vực cafe yên tĩnh, đồ uống miễn phí',
      duration: 'Linh hoạt',
      price: 'Miễn phí',
      gradient: [Color(0xFFFBBF24), Color(0xFFD97706)],
      bg: Color(0xFFFFFBEB),
      icon: Icons.coffee,
    ),
    _ServiceModel(
      name: 'Lớp học chăm sóc bé',
      description: 'Workshop về chăm sóc trẻ sơ sinh, cho bú, tắm bé',
      duration: '90 phút',
      price: '200.000đ',
      gradient: [Color(0xFF818CF8), Color(0xFF4F46E5)],
      bg: Color(0xFFEEF2FF),
      icon: Icons.menu_book,
    ),
  ];

  static final _myBookings = <_BookingModel>[
    _BookingModel(
      service: 'Spa & Massage',
      date: DateTime(2024, 11, 26),
      time: '14:00',
      family: 'Gia đình Trần Thị B',
      room: 'Phòng 101',
      status: _BookingStatus.confirmed,
      createdBy: 'Trần Thị Mai',
    ),
    _BookingModel(
      service: 'Yoga phục hồi',
      date: DateTime(2024, 11, 27),
      time: '09:00',
      family: 'Gia đình Nguyễn Văn C',
      room: 'Phòng 203',
      status: _BookingStatus.pending,
      createdBy: 'Trần Thị Mai',
    ),
  ];

  void _openBookingForm(_ServiceModel service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BookingFormScreen(service: service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            _TopTabs(
              tab: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: padding,
                child: _tab == _ServiceTab.services
                    ? _ServicesView(
                        onServiceTap: _openBookingForm,
                      )
                    : const _MyBookingsView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final _ServiceTab tab;
  final ValueChanged<_ServiceTab> onChanged;

  const _TopTabs({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'Dịch vụ',
                selected: tab == _ServiceTab.services,
                onTap: () => onChanged(_ServiceTab.services),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _TabButton(
                label: 'Lịch đã đặt',
                selected: tab == _ServiceTab.myBookings,
                onTap: () => onChanged(_ServiceTab.myBookings),
              ),
            ),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ServicesView extends StatelessWidget {
  final void Function(_ServiceModel service) onServiceTap;

  const _ServicesView({required this.onServiceTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        _HeaderCard(
          title: 'Đặt lịch cho gia đình',
          subtitle: 'Hỗ trợ gia đình đặt lịch dịch vụ',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final scale = AppResponsive.scaleFactor(context);
            final gap = 12.0 * scale;
            final itemWidth = (constraints.maxWidth - gap) / 2;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final s in _EmployeeServiceBookingScreenState._services)
                  SizedBox(
                    width: itemWidth,
                    child: _ServiceCard(service: s, onTap: () => onServiceTap(s)),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

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
            title,
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
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

class _ServiceCard extends StatelessWidget {
  final _ServiceModel service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: service.bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: service.gradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: service.gradient.last.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(service.icon, color: AppColors.white),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F7EE),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Có sẵn',
                      style: AppTextStyles.arimo(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1B7F3A),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                service.name,
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                service.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.arimo(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      service.duration,
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.payments_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      service.price,
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyBookingsView extends StatelessWidget {
  const _MyBookingsView();

  @override
  Widget build(BuildContext context) {
    final items = _EmployeeServiceBookingScreenState._myBookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        _HeaderCard(
          title: 'Lịch đã đặt cho gia đình',
          subtitle: '${items.length} lịch hẹn',
        ),
        const SizedBox(height: 12),
        for (final b in items) ...[
          _BookingCard(item: b),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final _BookingModel item;

  const _BookingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item.status;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: status.bg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.label,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: status.fg,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Hủy lịch',
                style: AppTextStyles.arimo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEF4444),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.service,
            style: AppTextStyles.arimo(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _Line(icon: Icons.calendar_month, text: _formatDateVi(item.date)),
          const SizedBox(height: 8),
          _Line(icon: Icons.access_time, text: item.time),
          const SizedBox(height: 8),
          _Line(icon: Icons.people_alt_outlined, text: item.family),
          const SizedBox(height: 8),
          _Line(icon: Icons.location_on_outlined, text: item.room),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
            ),
            child: Text(
              'Đặt bởi: ${item.createdBy}',
              style: AppTextStyles.arimo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Line({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

String _formatDateVi(DateTime date) {
  // Format ngắn gọn giống design (không hardcode weekday).
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year;
  return '$d/$m/$y';
}

class _BookingFormScreen extends StatefulWidget {
  final _ServiceModel service;

  const _BookingFormScreen({required this.service});

  @override
  State<_BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<_BookingFormScreen> {
  int? _selectedFamilyId;
  DateTime? _selectedDate;
  String? _selectedTime;
  final _notesCtrl = TextEditingController();

  static const _families = [
    {'id': 1, 'name': 'Gia đình Trần Thị B', 'room': 'Phòng 101'},
    {'id': 2, 'name': 'Gia đình Nguyễn Văn C', 'room': 'Phòng 203'},
    {'id': 3, 'name': 'Gia đình Lê Thị D', 'room': 'Phòng 305'},
  ];

  static const _timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30'
  ];

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      initialDate: now,
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  bool get _canSubmit => _selectedFamilyId != null && _selectedDate != null && _selectedTime != null;

  void _submit() {
    if (!_canSubmit) return;

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã gửi yêu cầu đặt lịch thành công! (mock)',
          style: AppTextStyles.arimo(color: AppColors.white),
        ),
        backgroundColor: AppColors.textPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.service;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Đặt lịch dịch vụ',
          style: AppTextStyles.arimo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppResponsive.pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: s.bg,
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
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: s.gradient,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(s.icon, color: AppColors.white),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.name,
                                      style: AppTextStyles.arimo(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      s.description,
                                      style: AppTextStyles.arimo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _Meta(icon: Icons.access_time, text: s.duration),
                              const SizedBox(width: 12),
                              _Meta(icon: Icons.payments_outlined, text: s.price),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      children: [
                        Text(
                          'Chọn gia đình',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedFamilyId,
                          items: [
                            for (final f in _families)
                              DropdownMenuItem<int>(
                                value: f['id'] as int,
                                child: Text(
                                  '${f['name']} - ${f['room']}',
                                  style: AppTextStyles.arimo(),
                                ),
                              ),
                          ],
                          onChanged: (v) => setState(() => _selectedFamilyId = v),
                          decoration: _inputDecoration('— Chọn gia đình —'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      children: [
                        Text(
                          'Chọn ngày',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: _inputDecoration('Chọn ngày'),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedDate == null
                                        ? '—'
                                        : _formatDateVi(_selectedDate!),
                                    style: AppTextStyles.arimo(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(Icons.calendar_month, color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      children: [
                        Text(
                          'Chọn khung giờ',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final scale = AppResponsive.scaleFactor(context);
                            final gap = 8.0 * scale;
                            final itemWidth = (constraints.maxWidth - gap * 3) / 4;

                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: [
                                for (final t in _timeSlots)
                                  SizedBox(
                                    width: itemWidth,
                                    child: _TimeSlotButton(
                                      time: t,
                                      selected: _selectedTime == t,
                                      onTap: () => setState(() => _selectedTime = t),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      children: [
                        Text(
                          'Ghi chú (tùy chọn)',
                          style: AppTextStyles.arimo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _notesCtrl,
                          maxLines: 3,
                          decoration: _inputDecoration('Ghi chú thêm về yêu cầu đặc biệt...'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _GradientButton(
                    label: 'Xác nhận đặt lịch',
                    enabled: _canSubmit,
                    onTap: _submit,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Hủy', style: AppTextStyles.arimo(fontWeight: FontWeight.w700)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.arimo(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;

  const _FormCard({required this.children});

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.arimo(color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.background,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}

class _TimeSlotButton extends StatelessWidget {
  final String time;
  final bool selected;
  final VoidCallback onTap;

  const _TimeSlotButton({
    required this.time,
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          time,
          style: AppTextStyles.arimo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _GradientButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFFFFA952)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

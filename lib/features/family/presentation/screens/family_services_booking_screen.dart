// lib/features/family/presentation/screens/family_services_booking_screen.dart
// NOTE: Ported from Familystay-main/src/mobile/services/ServiceBooking.tsx
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Representing the 2 tabs in ServiceBooking.tsx.
enum _ServiceBookingTab {
  services,
  myBookings,
}

class FamilyServicesBookingScreen extends StatefulWidget {
  const FamilyServicesBookingScreen({super.key});

  @override
  State<FamilyServicesBookingScreen> createState() => _FamilyServicesBookingScreenState();
}

class _FamilyServicesBookingScreenState extends State<FamilyServicesBookingScreen> {
  // Active tab.
  _ServiceBookingTab _activeTab = _ServiceBookingTab.services;

  // Fake "my bookings" list (ported from TS).
  final List<_Booking> _myBookings = const [
    _Booking(
      id: '1',
      service: 'Spa & Massage',
      dateIso: '2024-11-26',
      time: '14:00',
      status: _BookingStatus.confirmed,
    ),
    _Booking(
      id: '2',
      service: 'Yoga phục hồi',
      dateIso: '2024-11-27',
      time: '09:00',
      status: _BookingStatus.pending,
    ),
  ];

  // Services list (ported from TS).
  final List<_Service> _services = const [
    _Service(
      id: '1',
      name: 'Spa & Massage',
      description: 'Massage thư giãn, chăm sóc da mặt, điều trị sau sinh',
      duration: '60-90 phút',
      price: '500.000 - 1.200.000đ',
      tone: _ServiceTone.pink,
      icon: Icons.auto_awesome,
    ),
    _Service(
      id: '2',
      name: 'Phòng Gym',
      description: 'Tập luyện phục hồi, yoga sau sinh có huấn luyện viên',
      duration: '45-60 phút',
      price: '300.000 - 500.000đ',
      tone: _ServiceTone.blue,
      icon: Icons.fitness_center,
    ),
    _Service(
      id: '3',
      name: 'Tư vấn dinh dưỡng',
      description: 'Tư vấn chế độ ăn cho mẹ sau sinh và bé',
      duration: '30-45 phút',
      price: '400.000đ',
      tone: _ServiceTone.red,
      icon: Icons.favorite_border,
    ),
    _Service(
      id: '4',
      name: 'Chụp ảnh kỷ niệm',
      description: 'Chụp ảnh newborn, ảnh gia đình tại studio chuyên nghiệp',
      duration: '90-120 phút',
      price: '1.500.000 - 3.000.000đ',
      tone: _ServiceTone.purple,
      icon: Icons.photo_camera,
    ),
    _Service(
      id: '5',
      name: 'Yoga phục hồi',
      description: 'Lớp yoga nhẹ nhàng cho mẹ sau sinh',
      duration: '60 phút',
      price: '350.000đ',
      tone: _ServiceTone.green,
      icon: Icons.group,
    ),
    _Service(
      id: '6',
      name: 'Cafe & Thư giãn',
      description: 'Khu vực cafe yên tĩnh, đồ uống miễn phí',
      duration: 'Linh hoạt',
      price: 'Miễn phí',
      tone: _ServiceTone.yellow,
      icon: Icons.coffee,
    ),
    _Service(
      id: '7',
      name: 'Lớp học chăm sóc bé',
      description: 'Workshop về chăm sóc trẻ sơ sinh, cho bú, tắm bé',
      duration: '90 phút',
      price: '200.000đ',
      tone: _ServiceTone.indigo,
      icon: Icons.menu_book,
    ),
  ];

  // Time slots (ported from TS).
  static const List<String> _timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30',
  ];

  void _openBookingForm(_Service service) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ServiceBookingFormScreen(
          service: service,
          timeSlots: _timeSlots,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.familyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Dịch vụ',
          style: AppTextStyles.arimo(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs segment.
          Padding(
            padding: EdgeInsets.fromLTRB(padding.left, 12, padding.right, 12),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentButton(
                      label: 'Dịch vụ',
                      isActive: _activeTab == _ServiceBookingTab.services,
                      onTap: () {
                        setState(() {
                          _activeTab = _ServiceBookingTab.services;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: _SegmentButton(
                      label: 'Lịch đã đặt',
                      isActive: _activeTab == _ServiceBookingTab.myBookings,
                      onTap: () {
                        setState(() {
                          _activeTab = _ServiceBookingTab.myBookings;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content.
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding.left, 0, padding.right, 16),
              child: _activeTab == _ServiceBookingTab.services
                  ? _ServicesTab(
                      services: _services,
                      onSelectService: _openBookingForm,
                    )
                  : _MyBookingsTab(bookings: _myBookings),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  final List<_Service> services;
  final ValueChanged<_Service> onSelectService;

  const _ServicesTab({required this.services, required this.onSelectService});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),

        // Header.
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dịch vụ tiện ích',
                style: AppTextStyles.arimo(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Đặt lịch sử dụng các dịch vụ',
                style: AppTextStyles.arimo(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Grid 2 columns.
        LayoutBuilder(
          builder: (context, constraints) {
            // Simple grid without external deps.
            final width = constraints.maxWidth;
            final itemWidth = (width - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final service in services)
                  SizedBox(
                    width: itemWidth,
                    child: _ServiceCard(
                      service: service,
                      onTap: () => onSelectService(service),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final _Service service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tone = _ServiceToneConfig.fromTone(service.tone);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tone.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 6),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: tone.gradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(service.icon, color: AppColors.white, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Có sẵn',
                    style: AppTextStyles.arimo(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.familyPrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    service.duration,
                    style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.payments_outlined, size: 14, color: AppColors.familyPrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    service.price,
                    style: AppTextStyles.arimo(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.familyPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MyBookingsTab extends StatelessWidget {
  final List<_Booking> bookings;

  const _MyBookingsTab({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),

        // Header.
        Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lịch đã đặt',
                style: AppTextStyles.arimo(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                '${bookings.length} lịch hẹn',
                style: AppTextStyles.arimo(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        for (final booking in bookings) ...[
          _BookingCard(booking: booking),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  final _Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = _BookingStatusConfig.fromStatus(booking.status);

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: status.badgeBackground,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.label,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: status.badgeText,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Hủy lịch (sẽ tích hợp sau).',
                        style: AppTextStyles.arimo(color: AppColors.white),
                      ),
                      backgroundColor: AppColors.textPrimary,
                    ),
                  );
                },
                child: Text(
                  'Hủy lịch',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking.service,
            style: AppTextStyles.arimo(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _BookingInfoLine(icon: Icons.calendar_month, text: _formatDateShort(booking.dateIso)),
          const SizedBox(height: 8),
          _BookingInfoLine(icon: Icons.access_time, text: booking.time),
        ],
      ),
    );
  }

  String _formatDateShort(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) {
      return iso;
    }

    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    final wd = weekdays[dt.weekday % 7];

    return '$wd, ${dt.day} thg ${dt.month}';
  }
}

class _BookingInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BookingInfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.familyPrimary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.arimo(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ServiceBookingFormScreen extends StatefulWidget {
  final _Service service;
  final List<String> timeSlots;

  const _ServiceBookingFormScreen({
    required this.service,
    required this.timeSlots,
  });

  @override
  State<_ServiceBookingFormScreen> createState() => _ServiceBookingFormScreenState();
}

class _ServiceBookingFormScreenState extends State<_ServiceBookingFormScreen> {
  // Selected date in ISO format.
  String _selectedDate = '';

  // Selected time.
  String _selectedTime = '';

  // Notes.
  // ignore: unused_field
  String _notes = '';

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final tone = _ServiceToneConfig.fromTone(widget.service.tone);

    final isValid = _selectedDate.isNotEmpty && _selectedTime.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.familyBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white.withValues(alpha: 0.95),
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Đặt lịch dịch vụ',
          style: AppTextStyles.arimo(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Service info.
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: tone.background,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: tone.gradient,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 14,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Icon(widget.service.icon, color: AppColors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.service.name,
                                    style: AppTextStyles.arimo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    widget.service.description,
                                    style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: AppColors.familyPrimary),
                            const SizedBox(width: 8),
                            Text(
                              widget.service.duration,
                              style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.payments_outlined, size: 16, color: AppColors.familyPrimary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.service.price,
                                style: AppTextStyles.arimo(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Form.
                  Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _FormSection(
                          title: 'Chọn ngày',
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
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
                            },
                            child: _PickerField(
                              value: _selectedDate.isEmpty ? 'Chọn ngày' : _selectedDate,
                              icon: Icons.calendar_month,
                            ),
                          ),
                        ),
                        _DividerLine(),
                        _FormSection(
                          title: 'Chọn khung giờ',
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final t in widget.timeSlots)
                                _TimeChip(
                                  time: t,
                                  isSelected: _selectedTime == t,
                                  onTap: () {
                                    setState(() {
                                      _selectedTime = t;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                        _DividerLine(),
                        _FormSection(
                          title: 'Ghi chú (tùy chọn)',
                          child: TextField(
                            minLines: 4,
                            maxLines: 6,
                            onChanged: (v) {
                              setState(() {
                                _notes = v;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Ghi chú thêm về yêu cầu đặc biệt...',
                              filled: true,
                              fillColor: const Color(0xFFF3F4F6),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom actions.
          Container(
            padding: EdgeInsets.fromLTRB(padding.left, 12, padding.right, 12),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.95),
              border: Border(top: BorderSide(color: AppColors.borderLight)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isValid
                        ? () {
                            // NOTE: No backend yet, show success toast.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã gửi yêu cầu đặt lịch thành công!',
                                  style: AppTextStyles.arimo(color: AppColors.white),
                                ),
                                backgroundColor: AppColors.textPrimary,
                              ),
                            );

                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.familyPrimary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Xác nhận đặt lịch',
                      style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: const Color(0xFFF3F4F6),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      'Hủy',
                      style: AppTextStyles.arimo(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
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

class _FormSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FormSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: Colors.black.withValues(alpha: 0.06));
  }
}

class _PickerField extends StatelessWidget {
  final String value;
  final IconData icon;

  const _PickerField({required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.familyPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.arimo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: value == 'Chọn ngày' ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeChip({required this.time, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.familyPrimary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          time,
          style: AppTextStyles.arimo(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

enum _ServiceTone { pink, blue, red, purple, green, yellow, indigo }

class _Service {
  final String id;
  final String name;
  final String description;
  final String duration;
  final String price;
  final _ServiceTone tone;
  final IconData icon;

  const _Service({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.tone,
    required this.icon,
  });
}

class _ServiceToneConfig {
  final Color background;
  final Gradient gradient;

  const _ServiceToneConfig({required this.background, required this.gradient});

  factory _ServiceToneConfig.fromTone(_ServiceTone tone) {
    switch (tone) {
      case _ServiceTone.pink:
        return const _ServiceToneConfig(
          background: Color(0xFFFDF2F8),
          gradient: LinearGradient(colors: [Color(0xFFF472B6), Color(0xFFDB2777)]),
        );
      case _ServiceTone.blue:
        return const _ServiceToneConfig(
          background: Color(0xFFEFF6FF),
          gradient: LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF2563EB)]),
        );
      case _ServiceTone.red:
        return const _ServiceToneConfig(
          background: Color(0xFFFEF2F2),
          gradient: LinearGradient(colors: [Color(0xFFF87171), Color(0xFFDC2626)]),
        );
      case _ServiceTone.purple:
        return const _ServiceToneConfig(
          background: Color(0xFFFAF5FF),
          gradient: LinearGradient(colors: [Color(0xFFC084FC), Color(0xFF7C3AED)]),
        );
      case _ServiceTone.green:
        return const _ServiceToneConfig(
          background: Color(0xFFECFDF5),
          gradient: LinearGradient(colors: [Color(0xFF4ADE80), Color(0xFF16A34A)]),
        );
      case _ServiceTone.yellow:
        return const _ServiceToneConfig(
          background: Color(0xFFFFFBEB),
          gradient: LinearGradient(colors: [Color(0xFFFACC15), Color(0xFFCA8A04)]),
        );
      case _ServiceTone.indigo:
        return const _ServiceToneConfig(
          background: Color(0xFFEEF2FF),
          gradient: LinearGradient(colors: [Color(0xFF818CF8), Color(0xFF4F46E5)]),
        );
    }
  }
}

enum _BookingStatus { confirmed, pending }

class _Booking {
  final String id;
  final String service;
  final String dateIso;
  final String time;
  final _BookingStatus status;

  const _Booking({
    required this.id,
    required this.service,
    required this.dateIso,
    required this.time,
    required this.status,
  });
}

class _BookingStatusConfig {
  final Color badgeBackground;
  final Color badgeText;
  final String label;

  const _BookingStatusConfig({
    required this.badgeBackground,
    required this.badgeText,
    required this.label,
  });

  factory _BookingStatusConfig.fromStatus(_BookingStatus status) {
    switch (status) {
      case _BookingStatus.confirmed:
        return const _BookingStatusConfig(
          badgeBackground: Color(0xFFDCFCE7),
          badgeText: Color(0xFF15803D),
          label: 'Đã xác nhận',
        );
      case _BookingStatus.pending:
        return const _BookingStatusConfig(
          badgeBackground: Color(0xFFFEF3C7),
          badgeText: Color(0xFFB45309),
          label: 'Chờ xác nhận',
        );
    }
  }
}

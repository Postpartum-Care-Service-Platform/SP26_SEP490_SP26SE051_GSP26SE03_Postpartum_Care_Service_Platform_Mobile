// lib/features/employee/presentation/screens/employee_schedule_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../widgets/employee_header_bar.dart';

class EmployeeScheduleScreen extends StatelessWidget {
  const EmployeeScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const EmployeeHeaderBar(
              title: 'Portal Nhân viên',
              subtitle: 'Quản lý công việc',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    _HeaderCard(),
                    const SizedBox(height: 12),
                    _StatsGrid(),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      icon: Icons.calendar_month,
                      title: 'Lịch sắp tới',
                    ),
                    const SizedBox(height: 8),
                    const _UpcomingShiftList(),
                    const SizedBox(height: 16),
                    _SectionTitle(
                      icon: Icons.access_time,
                      title: 'Ca đã hoàn thành',
                      iconColor: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 8),
                    const _CompletedShiftList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
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
            'Lịch làm việc của tôi',
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Quản lý và theo dõi lịch làm việc',
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

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final gap = 12.0 * scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - gap) / 2;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: const [
            _StatCard(
              title: 'Ca làm tuần này',
              value: '12',
              valueColor: AppColors.primary,
            ),
            _StatCard(
              title: 'Giờ làm tháng',
              value: '156h',
              valueColor: AppColors.primary,
            ),
            _StatCard(
              title: 'Đánh giá TB',
              value: '4.9 ⭐',
              valueColor: Color(0xFFF5C518),
            ),
            _StatCard(
              title: 'Gia đình',
              value: '8',
              valueColor: AppColors.primary,
            ),
          ].map((w) => SizedBox(width: itemWidth, child: w)).toList(),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.arimo(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? AppColors.primary),
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

class _ShiftModel {
  final String date;
  final String shift;
  final String time;
  final String family;
  final String room;
  final String address;
  final String phone;
  final _ShiftStatus status;
  final List<String> tasks;

  const _ShiftModel({
    required this.date,
    required this.shift,
    required this.time,
    required this.family,
    required this.room,
    required this.address,
    required this.phone,
    required this.status,
    required this.tasks,
  });
}

enum _ShiftStatus { confirmed, pending, completed }

extension _ShiftStatusX on _ShiftStatus {
  String get label {
    switch (this) {
      case _ShiftStatus.confirmed:
        return 'Đã xác nhận';
      case _ShiftStatus.pending:
        return 'Chờ xác nhận';
      case _ShiftStatus.completed:
        return 'Hoàn thành';
    }
  }

  Color get background {
    switch (this) {
      case _ShiftStatus.confirmed:
        return const Color(0xFFE8F7EE);
      case _ShiftStatus.pending:
        return const Color(0xFFFFF6E5);
      case _ShiftStatus.completed:
        return const Color(0xFFF3F4F6);
    }
  }

  Color get foreground {
    switch (this) {
      case _ShiftStatus.confirmed:
        return const Color(0xFF1B7F3A);
      case _ShiftStatus.pending:
        return const Color(0xFF9A6B00);
      case _ShiftStatus.completed:
        return const Color(0xFF374151);
    }
  }

  Color get border {
    switch (this) {
      case _ShiftStatus.confirmed:
        return const Color(0xFFBFE7CC);
      case _ShiftStatus.pending:
        return const Color(0xFFFFE2A7);
      case _ShiftStatus.completed:
        return const Color(0xFFE5E7EB);
    }
  }
}

class _UpcomingShiftList extends StatelessWidget {
  const _UpcomingShiftList();

  static const _items = <_ShiftModel>[
    _ShiftModel(
      date: 'Thứ 2, 25/11',
      shift: 'Ca sáng',
      time: '6:00 - 14:00',
      family: 'Gia đình Trần Thị B',
      room: 'Phòng 101',
      address: '123 Nguyễn Văn Linh, Q7',
      phone: '0901234567',
      status: _ShiftStatus.confirmed,
      tasks: ['Kiểm tra sức khỏe', 'Massage phục hồi', 'Tư vấn chăm sóc'],
    ),
    _ShiftModel(
      date: 'Thứ 2, 25/11',
      shift: 'Ca chiều',
      time: '14:00 - 22:00',
      family: 'Gia đình Nguyễn Văn C',
      room: 'Phòng 203',
      address: '456 Lê Văn Việt, Q9',
      phone: '0907654321',
      status: _ShiftStatus.confirmed,
      tasks: ['Chăm sóc vết mổ', 'Hỗ trợ cho bú'],
    ),
    _ShiftModel(
      date: 'Thứ 3, 26/11',
      shift: 'Ca sáng',
      time: '6:00 - 14:00',
      family: 'Gia đình Lê Thị D',
      room: 'Phòng 305',
      address: '789 Võ Văn Ngân, Thủ Đức',
      phone: '0912345678',
      status: _ShiftStatus.pending,
      tasks: ['Kiểm tra sức khỏe', 'Tắm cho bé'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in _items) ...[
          _ShiftCard(item: item),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final _ShiftModel item;

  const _ShiftCard({required this.item});

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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusBadge(status: item.status),
              const SizedBox(width: 8),
              Text(
                item.date,
                style: AppTextStyles.arimo(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.family,
            style: AppTextStyles.arimo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.access_time,
            text: '${item.shift} (${item.time})',
          ),
          const SizedBox(height: 6),
          _InfoRow(icon: Icons.location_on, text: item.room),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Địa chỉ',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.address,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      item.phone,
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Nhiệm vụ:',
            style: AppTextStyles.arimo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final t in item.tasks) _Chip(text: t)],
          ),
        ],
      ),
    );
  }
}

class _CompletedShiftList extends StatelessWidget {
  const _CompletedShiftList();

  @override
  Widget build(BuildContext context) {
    const completed = <Map<String, Object>>[
      {
        'date': 'Chủ nhật, 24/11',
        'shift': 'Ca sáng',
        'family': 'Gia đình Trần Thị B',
        'room': 'Phòng 101',
        'rating': 5,
      },
      {
        'date': 'Thứ 7, 23/11',
        'shift': 'Ca chiều',
        'family': 'Gia đình Nguyễn Văn C',
        'room': 'Phòng 203',
        'rating': 5,
      },
    ];

    return Column(
      children: [
        for (final item in completed) ...[
          _CompletedShiftCard(
            date: item['date'] as String,
            shift: item['shift'] as String,
            family: item['family'] as String,
            room: item['room'] as String,
            rating: item['rating'] as int,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _CompletedShiftCard extends StatelessWidget {
  final String date;
  final String shift;
  final String family;
  final String room;
  final int rating;

  const _CompletedShiftCard({
    required this.date,
    required this.shift,
    required this.family,
    required this.room,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.75,
      child: Container(
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
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _StatusBadge(status: _ShiftStatus.completed),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: AppTextStyles.arimo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    family,
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        shift,
                        style: AppTextStyles.arimo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        room,
                        style: AppTextStyles.arimo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              List.filled(rating, '⭐').join(),
              style: AppTextStyles.arimo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF5C518),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _ShiftStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: status.background,
        border: Border.all(color: status.border),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        status.label,
        style: AppTextStyles.arimo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: status.foreground,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;

  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: AppTextStyles.arimo(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

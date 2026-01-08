// lib/features/employee/presentation/screens/check_in_out_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../widgets/employee_header_bar.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  String? checkInTime;
  String? checkOutTime;
  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;

  void _handleCheckIn() {
    final now = TimeOfDay.now();
    setState(() {
      checkInTime = now.format(context);
    });
  }

  void _handleCheckOut() {
    final now = TimeOfDay.now();
    setState(() {
      checkOutTime = now.format(context);
    });
  }

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
                    const _HeaderCard(),
                    const SizedBox(height: 12),
                    _CurrentShiftCard(
                      checkInTime: checkInTime,
                      checkOutTime: checkOutTime,
                      onCheckIn: _handleCheckIn,
                      onCheckOut: _handleCheckOut,
                    ),
                    const SizedBox(height: 16),
                    const _SectionTitle(icon: Icons.history, title: 'Lịch sử'),
                    const SizedBox(height: 8),
                    const _RecentHistoryList(),
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
            'Check-in / Check-out ⏰',
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Điểm danh và ghi nhận công việc',
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

class _CurrentShiftCard extends StatelessWidget {
  final String? checkInTime;
  final String? checkOutTime;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  bool get isCheckedIn => checkInTime != null;
  bool get isCheckedOut => checkOutTime != null;

  const _CurrentShiftCard({
    this.checkInTime,
    this.checkOutTime,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _buildShiftInfo(),
          const SizedBox(height: 16),
          _buildCheckInSection(),
          const SizedBox(height: 12),
          _buildCheckOutSection(),
          if (isCheckedIn && !isCheckedOut) ...[
            const SizedBox(height: 12),
            _buildNotesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'Ca hiện tại',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gia đình Trần Thị B',
                style: AppTextStyles.arimo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.access_time, text: 'Ca sáng (6:00 - 14:00)'),
              const SizedBox(height: 4),
              _InfoRow(icon: Icons.location_on, text: 'Phòng 101'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StreamBuilder(
              stream: Stream.periodic(const Duration(seconds: 1)),
              builder: (context, snapshot) {
                final now = TimeOfDay.now();
                return Text(
                  now.format(context),
                  style: AppTextStyles.arimo(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
            Text(
              'Giờ hiện tại',
              style: AppTextStyles.arimo(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckInSection() {
    return _ActionSection(
      title: 'Check-in',
      icon: Icons.check_circle,
      time: checkInTime,
      color: const Color(0xFF1B7F3A),
      child: isCheckedIn
          ? const _StatusMessage(
              message: 'Đã điểm danh thành công',
              color: Color(0xFF1B7F3A),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: onCheckIn,
                  icon: const Icon(Icons.access_time, size: 16),
                  label: const Text('Điểm danh vào ca'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const _FileUploadButton(),
              ],
            ),
    );
  }

  Widget _buildCheckOutSection() {
    return _ActionSection(
      title: 'Check-out',
      icon: Icons.cancel,
      time: checkOutTime,
      color: const Color(0xFFD32F2F),
      child: isCheckedOut
          ? const _StatusMessage(
              message: 'Đã kết thúc ca làm việc',
              color: Color(0xFFD32F2F),
            )
          : (isCheckedIn
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onCheckOut,
                        icon: const Icon(Icons.access_time, size: 16),
                        label: const Text('Điểm danh ra ca'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _FileUploadButton(),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'Vui lòng check-in trước',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.arimo(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )),
    );
  }

  Widget _buildNotesSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon: Icons.description,
            text: 'Ghi chú',
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 8),
          TextField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ghi chú công việc...',
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
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? time;
  final Color color;
  final Widget child;

  const _ActionSection({
    required this.title,
    required this.icon,
    this.time,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: time != null ? color : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (time != null)
                Text(
                  time!,
                  style: AppTextStyles.arimo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FileUploadButton extends StatelessWidget {
  const _FileUploadButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        // NOTE: Placeholder hành động upload/chụp ảnh.
        // Hiện tại dự án chưa tích hợp image_picker/camera.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chức năng chụp ảnh sẽ được tích hợp sau.',
              style: AppTextStyles.arimo(color: AppColors.white),
            ),
            backgroundColor: AppColors.textPrimary,
          ),
        );
      },
      icon: Icon(Icons.camera_alt, size: 16, color: AppColors.primary),
      label: Text(
        'Chụp ảnh',
        style: AppTextStyles.arimo(color: AppColors.textPrimary),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final Color color;

  const _StatusMessage({required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          message,
          style: AppTextStyles.arimo(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _RecentHistoryList extends StatelessWidget {
  const _RecentHistoryList();

  static const _history = [
    {
      'date': 'Chủ nhật, 24/11',
      'shift': 'Ca sáng',
      'family': 'Gia đình Trần Thị B',
      'checkIn': '06:05',
      'checkOut': '14:10',
    },
    {
      'date': 'Thứ 7, 23/11',
      'shift': 'Ca chiều',
      'family': 'Gia đình Nguyễn Văn C',
      'checkIn': '14:02',
      'checkOut': '22:15',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in _history)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _HistoryCard(item: item),
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, String> item;

  const _HistoryCard({required this.item});

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['date']} • ${item['shift']}',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['family']!,
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _TimeChip(isCheckIn: true, time: item['checkIn']!),
                    const SizedBox(width: 8),
                    _TimeChip(isCheckIn: false, time: item['checkOut']!),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7EE),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              'Hoàn thành',
              style: AppTextStyles.arimo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B7F3A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  final bool isCheckIn;
  final String time;

  const _TimeChip({required this.isCheckIn, required this.time});

  @override
  Widget build(BuildContext context) {
    final color = isCheckIn ? const Color(0xFF1B7F3A) : const Color(0xFFD32F2F);
    final icon = isCheckIn ? Icons.check_circle : Icons.cancel;

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          time,
          style: AppTextStyles.arimo(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const _InfoRow({required this.icon, required this.text, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor ?? AppColors.primary),
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

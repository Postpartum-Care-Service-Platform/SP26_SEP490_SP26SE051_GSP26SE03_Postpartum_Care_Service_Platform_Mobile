// lib/features/employee/presentation/widgets/employee_notifications_sheet.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_text_styles.dart';

class EmployeeNotificationsSheet {
  EmployeeNotificationsSheet._();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _NotificationsContent();
      },
    );
  }
}

class _NotificationModel {
  final String message;
  final String time;
  final bool unread;

  const _NotificationModel({
    required this.message,
    required this.time,
    required this.unread,
  });
}

class _NotificationsContent extends StatelessWidget {
  const _NotificationsContent();

  static const _items = <_NotificationModel>[
    _NotificationModel(
      message: 'Ca sáng ngày mai đã được xác nhận - Gia đình Trần Thị B',
      time: '10 phút trước',
      unread: true,
    ),
    _NotificationModel(
      message: 'Lịch làm việc tuần sau đã được cập nhật',
      time: '1 giờ trước',
      unread: true,
    ),
    _NotificationModel(
      message: 'Gia đình Nguyễn Văn C đã đánh giá 5 sao cho ca làm việc của bạn',
      time: '3 giờ trước',
      unread: false,
    ),
    _NotificationModel(
      message: 'Nhắc nhở: Check-in ca sáng lúc 6:00',
      time: '1 ngày trước',
      unread: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Container(
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Container(
        constraints: BoxConstraints(maxHeight: height * 0.7),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Thông báo',
                      style: AppTextStyles.arimo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final n = _items[index];
                  return Container(
                    color: n.unread
                        ? const Color(0xFFEFF6FF).withValues(alpha: 0.5)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            color: n.unread ? AppColors.primary : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.message,
                                style: AppTextStyles.arimo(
                                  fontSize: 13,
                                  fontWeight: n.unread ? FontWeight.w700 : FontWeight.w500,
                                  color: n.unread
                                      ? AppColors.textPrimary
                                      : const Color(0xFF4B5563),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                n.time,
                                style: AppTextStyles.arimo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

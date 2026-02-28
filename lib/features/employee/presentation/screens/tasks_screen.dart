// lib/features/employee/presentation/screens/tasks_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../widgets/employee_header_bar.dart';
import '../widgets/employee_scaffold.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return EmployeeScaffold(
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
                  children: const [
                    SizedBox(height: 12),
                    _HeaderCard(),
                    SizedBox(height: 12),
                    _StatsRow(),
                    SizedBox(height: 12),
                    _TaskList(),
                    SizedBox(height: 24),
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
            'Công việc hôm nay 📋',
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Danh sách nhiệm vụ của bạn',
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

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final gap = 12.0 * scale;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Hoàn thành',
            value: '2',
            valueColor: const Color(0xFF1B7F3A),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(
            title: 'Đang làm',
            value: '1',
            valueColor: const Color(0xFF2563EB),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(
            title: 'Sắp tới',
            value: '1',
            valueColor: const Color(0xFF6B7280),
          ),
        ),
      ],
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

class _TaskModel {
  final String time;
  final String title;
  final String family;
  final _TaskStatus status;
  final String? notes;

  const _TaskModel({
    required this.time,
    required this.title,
    required this.family,
    required this.status,
    this.notes,
  });
}

enum _TaskStatus { completed, inProgress, pending }

extension _TaskStatusX on _TaskStatus {
  String get label {
    switch (this) {
      case _TaskStatus.completed:
        return 'Hoàn thành';
      case _TaskStatus.inProgress:
        return 'Đang thực hiện';
      case _TaskStatus.pending:
        return 'Sắp tới';
    }
  }

  String get iconText {
    switch (this) {
      case _TaskStatus.completed:
        return '✅';
      case _TaskStatus.inProgress:
        return '🔄';
      case _TaskStatus.pending:
        return '⏰';
    }
  }

  Color get foreground {
    switch (this) {
      case _TaskStatus.completed:
        return const Color(0xFF1B7F3A);
      case _TaskStatus.inProgress:
        return const Color(0xFF2563EB);
      case _TaskStatus.pending:
        return const Color(0xFF6B7280);
    }
  }

  Color get background {
    switch (this) {
      case _TaskStatus.completed:
        return const Color(0xFFE8F7EE);
      case _TaskStatus.inProgress:
        return const Color(0xFFDBEAFE);
      case _TaskStatus.pending:
        return const Color(0xFFF3F4F6);
    }
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList();

  static const _tasks = <_TaskModel>[
    _TaskModel(
      time: '08:00 - 08:30',
      title: 'Kiểm tra sức khỏe mẹ',
      family: 'Gia đình Trần Thị B',
      status: _TaskStatus.completed,
      notes: 'Đã hoàn thành, mẹ khỏe mạnh',
    ),
    _TaskModel(
      time: '09:00 - 09:30',
      title: 'Chăm sóc bé - Tắm rửa',
      family: 'Gia đình Trần Thị B',
      status: _TaskStatus.completed,
      notes: 'Bé rất ngoan',
    ),
    _TaskModel(
      time: '11:00 - 11:45',
      title: 'Massage phục hồi',
      family: 'Gia đình Trần Thị B',
      status: _TaskStatus.inProgress,
    ),
    _TaskModel(
      time: '14:00 - 14:30',
      title: 'Kiểm tra sức khỏe định kỳ',
      family: 'Gia đình Nguyễn Văn C',
      status: _TaskStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final task in _tasks) ...[
          _TaskCard(task: task),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final _TaskModel task;

  const _TaskCard({required this.task});

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.status.iconText, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.time,
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.family,
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _StatusBadge(status: task.status),
                  ],
                ),
              ),
            ],
          ),
          if (task.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Text(
                '💬 ${task.notes}',
                style: AppTextStyles.arimo(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _TaskStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
      ),
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

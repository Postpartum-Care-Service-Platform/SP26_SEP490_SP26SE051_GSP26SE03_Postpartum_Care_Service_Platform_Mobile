// lib/features/employee/presentation/screens/tasks_screen_new.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_status.dart';
import '../bloc/appointment/appointment_bloc.dart';
import '../bloc/appointment/appointment_event.dart';
import '../bloc/appointment/appointment_state.dart';
import '../widgets/employee_header_bar.dart';

/// Tasks Screen with BLoC integration
/// Shows today's appointments as tasks
class TasksScreenNew extends StatelessWidget {
  const TasksScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.appointmentBloc
        ..add(const LoadMyAssignedAppointments()),
      child: const _TasksScreenContent(),
    );
  }
}

class _TasksScreenContent extends StatelessWidget {
  const _TasksScreenContent();

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
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<AppointmentBloc>().add(const LoadMyAssignedAppointments());
                },
                child: BlocConsumer<AppointmentBloc, AppointmentState>(
                  listener: (context, state) {
                    if (state is AppointmentError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else if (state is AppointmentActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AppointmentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is AppointmentLoaded) {
                      // Filter only today's appointments
                      final todayTasks = _filterTodayTasks(state.appointments);
                      
                      if (todayTasks.isEmpty) {
                        return _EmptyState();
                      }
                      
                      return _TasksContent(tasks: todayTasks);
                    }

                    if (state is AppointmentEmpty) {
                      return _EmptyState();
                    }

                    if (state is AppointmentError) {
                      return _ErrorState(message: state.message);
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter appointments for today only
  List<AppointmentEntity> _filterTodayTasks(List<AppointmentEntity> appointments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );
      
      // Only include appointments for today
      return appointmentDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
             appointmentDate.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }
}

/// Tasks content with statistics and list
class _TasksContent extends StatelessWidget {
  final List<AppointmentEntity> tasks;

  const _TasksContent({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    // Calculate statistics
    final completed = tasks.where((t) => t.status == AppointmentStatus.completed).length;
    final inProgress = tasks.where((t) => 
      t.status == AppointmentStatus.scheduled || 
      t.status == AppointmentStatus.rescheduled
    ).length;
    final pending = tasks.where((t) => t.status == AppointmentStatus.pending).length;

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const _HeaderCard(),
          const SizedBox(height: 12),
          _StatsRow(
            completed: completed,
            inProgress: inProgress,
            pending: pending,
          ),
          const SizedBox(height: 12),
          const _TaskList(),
        ],
      ),
    );
  }
}

/// Header card
class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, dd/MM/yyyy', 'vi');
    
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
            dateFormat.format(now),
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

/// Statistics row
class _StatsRow extends StatelessWidget {
  final int completed;
  final int inProgress;
  final int pending;

  const _StatsRow({
    required this.completed,
    required this.inProgress,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final gap = 12.0 * scale;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Hoàn thành',
            value: '$completed',
            valueColor: const Color(0xFF1B7F3A),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(
            title: 'Đang làm',
            value: '$inProgress',
            valueColor: const Color(0xFF2563EB),
          ),
        ),
        SizedBox(width: gap),
        Expanded(
          child: _StatCard(
            title: 'Sắp tới',
            value: '$pending',
            valueColor: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}

/// Stat card
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

/// Task list with BLoC data
class _TaskList extends StatelessWidget {
  const _TaskList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoaded) {
          final todayTasks = _filterTodayTasks(state.appointments);
          
          return Column(
            children: [
              for (final task in todayTasks) ...[
                _TaskCard(task: task),
                const SizedBox(height: 12),
              ],
            ],
          );
        }
        return const SizedBox();
      },
    );
  }

  List<AppointmentEntity> _filterTodayTasks(List<AppointmentEntity> appointments) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );
      
      return appointmentDate.isAfter(today.subtract(const Duration(seconds: 1))) &&
             appointmentDate.isBefore(tomorrow);
    }).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }
}

/// Task card
class _TaskCard extends StatelessWidget {
  final AppointmentEntity task;

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
              Text(_getStatusIcon(task.status), style: const TextStyle(fontSize: 20)),
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
                            task.name ?? 'Công việc',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(task.appointmentDate),
                          style: AppTextStyles.arimo(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (task.customer != null)
                      Text(
                        task.customer!.username ?? task.customer!.email,
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
          if (task.customer?.phone != null) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    task.customer!.phone!,
                    style: AppTextStyles.arimo(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (task.status != AppointmentStatus.completed &&
              task.status != AppointmentStatus.cancelled) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (task.status == AppointmentStatus.pending)
                  Expanded(
                    child: _ActionButton(
                      label: 'Xác nhận',
                      icon: Icons.check_circle,
                      color: const Color(0xFF1B7F3A),
                      onTap: () => _confirmTask(context),
                    ),
                  ),
                if (task.status == AppointmentStatus.pending)
                  const SizedBox(width: 8),
                if (task.status == AppointmentStatus.scheduled)
                  Expanded(
                    child: _ActionButton(
                      label: 'Hoàn thành',
                      icon: Icons.done_all,
                      color: AppColors.primary,
                      onTap: () => _completeTask(context),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusIcon(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return '✅';
      case AppointmentStatus.scheduled:
      case AppointmentStatus.rescheduled:
        return '🔄';
      case AppointmentStatus.pending:
        return '⏰';
      case AppointmentStatus.cancelled:
        return '❌';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _confirmTask(BuildContext context) {
    context.read<AppointmentBloc>().add(ConfirmAppointmentEvent(task.id));
  }

  void _completeTask(BuildContext context) {
    context.read<AppointmentBloc>().add(CompleteAppointmentEvent(task.id));
  }
}

/// Status badge
class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.displayText,
        style: AppTextStyles.arimo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: config.foreground,
        ),
      ),
    );
  }

  _StatusConfig _getConfig(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return _StatusConfig(
          background: const Color(0xFFE8F7EE),
          foreground: const Color(0xFF1B7F3A),
        );
      case AppointmentStatus.scheduled:
      case AppointmentStatus.rescheduled:
        return _StatusConfig(
          background: const Color(0xFFDBEAFE),
          foreground: const Color(0xFF2563EB),
        );
      case AppointmentStatus.pending:
        return _StatusConfig(
          background: const Color(0xFFFFF6E5),
          foreground: const Color(0xFF9A6B00),
        );
      case AppointmentStatus.cancelled:
        return _StatusConfig(
          background: const Color(0xFFFEE2E2),
          foreground: const Color(0xFFB91C1C),
        );
    }
  }
}

class _StatusConfig {
  final Color background;
  final Color foreground;

  _StatusConfig({required this.background, required this.foreground});
}

/// Action button
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.arimo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Không có công việc hôm nay',
            style: AppTextStyles.arimo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn không có lịch hẹn nào trong ngày hôm nay',
            style: AppTextStyles.arimo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error state
class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<AppointmentBloc>().add(const LoadMyAssignedAppointments());
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

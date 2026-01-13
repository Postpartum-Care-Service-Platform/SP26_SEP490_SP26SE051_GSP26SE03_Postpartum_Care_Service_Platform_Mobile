// lib/features/employee/presentation/screens/employee_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

/// Employee Schedule Screen with BLoC integration
/// Shows appointments assigned to the staff
class EmployeeScheduleScreenNew extends StatelessWidget {
  const EmployeeScheduleScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.employeeAppointmentBloc
            ..add(const LoadMyAssignedAppointments()),
      child: const _EmployeeScheduleContent(),
    );
  }
}

class _EmployeeScheduleContent extends StatelessWidget {
  const _EmployeeScheduleContent();

  @override
  Widget build(BuildContext context) {
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
                  context.read<AppointmentBloc>().add(
                    const LoadMyAssignedAppointments(),
                  );
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
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AppointmentEmpty) {
                      return _EmptyState();
                    }

                    if (state is AppointmentLoaded) {
                      return _LoadedContent(appointments: state.appointments);
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
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 80,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch hẹn nào',
            style: AppTextStyles.arimo(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kéo xuống để làm mới',
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

/// Error state widget
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
            color: Colors.red.withValues(alpha: 0.7),
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
              context.read<AppointmentBloc>().add(
                const LoadMyAssignedAppointments(),
              );
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

/// Loaded content with appointments
class _LoadedContent extends StatelessWidget {
  final List<AppointmentEntity> appointments;

  const _LoadedContent({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    // Separate upcoming and completed appointments
    final upcomingAppointments = appointments
        .where(
          (a) =>
              a.status != AppointmentStatus.completed &&
              a.status != AppointmentStatus.cancelled,
        )
        .toList();

    final completedAppointments = appointments
        .where((a) => a.status == AppointmentStatus.completed)
        .toList();

    // Calculate stats
    final totalAssigned = appointments.length;
    final completed = completedAppointments.length;
    final pending = upcomingAppointments.length;

    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          const _HeaderCard(),
          const SizedBox(height: 12),
          _StatsGrid(
            totalAssigned: totalAssigned,
            completed: completed,
            pending: pending,
          ),
          const SizedBox(height: 16),
          if (upcomingAppointments.isNotEmpty) ...[
            _SectionTitle(
              icon: Icons.calendar_month,
              title: 'Lịch sắp tới (${upcomingAppointments.length})',
            ),
            const SizedBox(height: 8),
            ...upcomingAppointments.map(
              (appointment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AppointmentCard(appointment: appointment),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (completedAppointments.isNotEmpty) ...[
            _SectionTitle(
              icon: Icons.check_circle_outline,
              title: 'Đã hoàn thành (${completedAppointments.length})',
              iconColor: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            ...completedAppointments.map(
              (appointment) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CompletedAppointmentCard(appointment: appointment),
              ),
            ),
          ],
          const SizedBox(height: 24),
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
            'Lịch làm việc của tôi 📅',
            style: AppTextStyles.arimo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Quản lý và theo dõi lịch hẹn được giao',
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

/// Stats grid showing key metrics
class _StatsGrid extends StatelessWidget {
  final int totalAssigned;
  final int completed;
  final int pending;

  const _StatsGrid({
    required this.totalAssigned,
    required this.completed,
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
            title: 'Tổng số',
            value: '$totalAssigned',
            valueColor: AppColors.primary,
          ),
        ),
        SizedBox(width: gap),
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
            title: 'Đang xử lý',
            value: '$pending',
            valueColor: const Color(0xFF2563EB),
          ),
        ),
      ],
    );
  }
}

/// Stat card widget
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

/// Section title widget
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

/// Appointment card for upcoming appointments
class _AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;

  const _AppointmentCard({required this.appointment});

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
              _StatusBadge(status: appointment.status),
              const Spacer(),
              Text(
                _formatDate(appointment.appointmentDate),
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
            appointment.name ?? 'Lịch hẹn',
            style: AppTextStyles.arimo(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (appointment.customer != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.person,
              text:
                  appointment.customer!.username ?? appointment.customer!.email,
            ),
          ],
          if (appointment.customer?.phone != null) ...[
            const SizedBox(height: 4),
            _InfoRow(icon: Icons.phone, text: appointment.customer!.phone!),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (appointment.status == AppointmentStatus.scheduled ||
                  appointment.status == AppointmentStatus.pending)
                Expanded(
                  child: _ActionButton(
                    label: 'Xác nhận',
                    icon: Icons.check_circle,
                    color: const Color(0xFF1B7F3A),
                    onTap: () => _confirmAppointment(context),
                  ),
                ),
              if (appointment.status == AppointmentStatus.scheduled ||
                  appointment.status == AppointmentStatus.pending)
                const SizedBox(width: 8),
              if (appointment.status == AppointmentStatus.scheduled)
                Expanded(
                  child: _ActionButton(
                    label: 'Hoàn thành',
                    icon: Icons.done_all,
                    color: AppColors.primary,
                    onTap: () => _completeAppointment(context),
                  ),
                ),
              if (appointment.status != AppointmentStatus.cancelled)
                Expanded(
                  child: _ActionButton(
                    label: 'Hủy',
                    icon: Icons.cancel,
                    color: Colors.red,
                    onTap: () => _cancelAppointment(context),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmAppointment(BuildContext context) {
    context.read<AppointmentBloc>().add(
      ConfirmAppointmentEvent(appointment.id),
    );
  }

  void _completeAppointment(BuildContext context) {
    context.read<AppointmentBloc>().add(
      CompleteAppointmentEvent(appointment.id),
    );
  }

  void _cancelAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy'),
        content: const Text('Bạn có chắc muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AppointmentBloc>().add(
                CancelAppointmentEvent(appointment.id),
              );
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

/// Completed appointment card
class _CompletedAppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;

  const _CompletedAppointmentCard({required this.appointment});

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
                      _StatusBadge(status: appointment.status),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(appointment.appointmentDate),
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
                    appointment.name ?? 'Lịch hẹn',
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (appointment.customer != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      appointment.customer!.username ??
                          appointment.customer!.email,
                      style: AppTextStyles.arimo(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Color(0xFF1B7F3A), size: 32),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Status badge
class _StatusBadge extends StatelessWidget {
  final AppointmentStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(status);

    return Container(
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  _StatusConfig _getStatusConfig(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return _StatusConfig(
          background: const Color(0xFFE8F7EE),
          foreground: const Color(0xFF1B7F3A),
        );
      case AppointmentStatus.scheduled:
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
      default:
        return _StatusConfig(
          background: const Color(0xFFF3F4F6),
          foreground: const Color(0xFF6B7280),
        );
    }
  }
}

class _StatusConfig {
  final Color background;
  final Color foreground;

  _StatusConfig({required this.background, required this.foreground});
}

/// Info row widget
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

/// Action button widget
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
          color: color.withValues(alpha: 0.1),
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

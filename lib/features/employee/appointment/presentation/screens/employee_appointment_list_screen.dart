// lib/features/employee/presentation/screens/employee_appointment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_colors.dart';  
import '../../../../../core/di/injection_container.dart'; 
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_header_bar.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';  
import '../../../../../features/employee/appointment/domain/entities/appointment_entity.dart';   
import '../../../../../features/employee/appointment/domain/entities/appointment_status.dart';
import '../../../../../features/employee/appointment/presentation/bloc/appointment/appointment_bloc.dart';
import '../../../../../features/employee/appointment/presentation/bloc/appointment/appointment_event.dart';
import '../../../../../features/employee/appointment/presentation/bloc/appointment/appointment_state.dart';

/// Screen riêng để quản lý danh sách lịch hẹn của staff
class EmployeeAppointmentListScreen extends StatelessWidget {
  const EmployeeAppointmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.employeeAppointmentBloc
            ..add(const LoadAllAppointments()),
      child: const _EmployeeAppointmentListContent(),
    );
  }
}

class _EmployeeAppointmentListContent extends StatelessWidget {
  const _EmployeeAppointmentListContent();

  @override
  Widget build(BuildContext context) {
    return EmployeeScaffold(
      body: SafeArea(
        child: Column(
          children: [
            const EmployeeHeaderBar(
              title: 'Danh sách Lịch hẹn',
              subtitle: 'Quản lý và theo dõi tất cả lịch hẹn trên hệ thống',
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<AppointmentBloc>().add(
                    const LoadAllAppointments(),
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
                      return const _AppointmentsLoadingSkeleton();
                    }

                    if (state is AppointmentLoaded) {
                      return _LoadedContent(appointments: state.appointments);
                    }

                    if (state is AppointmentEmpty) {
                      return const _EmptyState();
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

/// Error state widget
class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: AppTextStyles.arimo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<AppointmentBloc>().add(
                  const LoadAllAppointments(),
                );
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có lịch hẹn nào',
              style: AppTextStyles.arimo(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kéo xuống để làm mới',
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loaded content với filter và search
class _LoadedContent extends StatefulWidget {
  final List<AppointmentEntity> appointments;

  const _LoadedContent({required this.appointments});

  @override
  State<_LoadedContent> createState() => _LoadedContentState();
}

class _LoadedContentState extends State<_LoadedContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _statusFilter = 'all';
  DateTime? _dateFilter;

  int _getActiveFilterCount() {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_statusFilter != 'all') count++;
    if (_dateFilter != null) count++;
    return count;
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _statusFilter = 'all';
      _dateFilter = null;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AppointmentEntity> _applyFilters(List<AppointmentEntity> appointments) {
    var filtered = appointments;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((a) {
        final customerName = (a.customer?.username ?? '').toLowerCase();
        final customerEmail = (a.customer?.email ?? '').toLowerCase();
        final customerPhone = (a.customer?.phone ?? '').toLowerCase();
        final appointmentName = (a.name ?? '').toLowerCase();

        return customerName.contains(query) ||
            customerEmail.contains(query) ||
            customerPhone.contains(query) ||
            appointmentName.contains(query);
      }).toList();
    }

    // Status filter
    if (_statusFilter != 'all') {
      filtered = filtered.where((a) {
        switch (_statusFilter) {
          case 'pending':
            return a.status == AppointmentStatus.pending;
          case 'scheduled':
            return a.status == AppointmentStatus.scheduled;
          case 'completed':
            return a.status == AppointmentStatus.completed;
          case 'cancelled':
            return a.status == AppointmentStatus.cancelled;
          default:
            return true;
        }
      }).toList();
    }

    // Date filter
    if (_dateFilter != null) {
      filtered = filtered.where((a) {
        final appointmentDate = DateTime(
          a.appointmentDate.year,
          a.appointmentDate.month,
          a.appointmentDate.day,
        );
        final filterDate = DateTime(
          _dateFilter!.year,
          _dateFilter!.month,
          _dateFilter!.day,
        );
        return appointmentDate.isAtSameMomentAs(filterDate);
      }).toList();
    }

    return filtered;
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required Color color,
    IconData icon = Icons.help_outline_rounded,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arimo(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.arimo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Quay lại',
                            style: AppTextStyles.arimo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'Xác nhận',
                            style: AppTextStyles.arimo(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final scale = AppResponsive.scaleFactor(context);

    // Apply filters
    final filteredAppointments = _applyFilters(widget.appointments);

    // Separate upcoming and completed appointments
    final upcomingAppointments = filteredAppointments
        .where(
          (a) =>
              a.status != AppointmentStatus.completed &&
              a.status != AppointmentStatus.cancelled,
        )
        .toList();

    final completedAppointments = filteredAppointments
        .where((a) => a.status == AppointmentStatus.completed)
        .toList();

    return Column(
      children: [
        _buildSearchBar(scale),
        _buildFilterBar(scale),
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (filteredAppointments.isEmpty)
                SliverFillRemaining(
                  child: _buildNoFilteredAppointmentsState(scale),
                )
              else ...[
                if (upcomingAppointments.isNotEmpty)
                  SliverPadding(
                    padding: padding.copyWith(top: 16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const _SectionTitle(
                          icon: Icons.calendar_today_rounded,
                          title: 'Lịch hẹn sắp tới',
                        ),
                        const SizedBox(height: 12),
                        ...upcomingAppointments.map(
                          (appointment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _AppointmentCard(
                              appointment: appointment,
                              onConfirm: () => _handleConfirm(appointment),
                              onComplete: () => _handleComplete(appointment),
                              onCancel: () => _handleCancel(appointment),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                if (completedAppointments.isNotEmpty)
                  SliverPadding(
                    padding: padding.copyWith(top: 24, bottom: 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                         _SectionTitle(
                          icon: Icons.check_circle_outline_rounded,
                          title: 'Đã hoàn thành',
                          iconColor: AppColors.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        ...completedAppointments.map(
                          (appointment) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CompletedAppointmentCard(
                              appointment: appointment,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleConfirm(AppointmentEntity appointment) async {
    final confirmed = await _showConfirmDialog(
      title: 'Xác nhận Lịch hẹn',
      message: 'Bạn xác nhận sẽ tham gia lịch hẹn này?',
      color: const Color(0xFF2563EB),
      icon: Icons.check_circle_outline_rounded,
    );
    if (confirmed && mounted) {
      context.read<AppointmentBloc>().add(
        ConfirmAppointmentEvent(appointment.id),
      );
    }
  }

  Future<void> _handleComplete(AppointmentEntity appointment) async {
    final confirmed = await _showConfirmDialog(
      title: 'Hoàn thành Lịch hẹn',
      message: 'Bạn xác nhận đã hoàn thành lịch hẹn này?',
      color: const Color(0xFF16A34A),
      icon: Icons.done_all_rounded,
    );
    if (confirmed && mounted) {
      context.read<AppointmentBloc>().add(
        CompleteAppointmentEvent(appointment.id),
      );
    }
  }

  Future<void> _handleCancel(AppointmentEntity appointment) async {
    final confirmed = await _showConfirmDialog(
      title: 'Hủy Lịch hẹn',
      message: 'Bạn có chắc chắn muốn hủy lịch hẹn này? Thao tác này không thể hoàn tác.',
      color: const Color(0xFFDC2626),
      icon: Icons.close_rounded,
    );
    if (confirmed && mounted) {
      context.read<AppointmentBloc>().add(
        CancelAppointmentEvent(appointment.id),
      );
    }
  }

  Widget _buildSearchBar(double scale) {
    final padding = AppResponsive.pagePadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 8),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Tìm theo tên khách, SĐT, email...',
            hintStyle: AppTextStyles.arimo(
              fontSize: 14,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(double scale) {
    final padding = AppResponsive.pagePadding(context);
    final filters = [
      {'id': 'all', 'label': 'Tất cả'},
      {'id': 'pending', 'label': 'Chờ xác nhận'},
      {'id': 'scheduled', 'label': 'Đã xác nhận'},
      {'id': 'completed', 'label': 'Hoàn thành'},
      {'id': 'cancelled', 'label': 'Đã hủy'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: padding.left),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _statusFilter == filter['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: ChoiceChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) setState(() => _statusFilter = filter['id']!);
              },
              labelStyle: AppTextStyles.arimo(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.white,
              elevation: isSelected ? 2 : 0,
              pressElevation: 4,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  width: 1,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoFilteredAppointmentsState(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy_rounded,
              size: 60,
              color: AppColors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Không tìm thấy lịch hẹn',
            style: AppTextStyles.arimo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
            style: AppTextStyles.arimo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Đặt lại bộ lọc'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.arimo(fontWeight: FontWeight.w700),
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
        Icon(icon, size: 18, color: iconColor ?? AppColors.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTextStyles.arimo(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

/// Main appointment card for active appointments
class _AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;
  final VoidCallback onConfirm;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.onConfirm,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusAccentColor(appointment.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                _StatusBadge(status: appointment.status),
                const Spacer(),
                Text(
                  '#${appointment.id}',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.appointmentTypeName ?? appointment.name ?? 'Lịch hẹn',
                            style: AppTextStyles.arimo(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(appointment.appointmentDate),
                            style: AppTextStyles.arimo(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                
                // Customer Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.background,
                      child: Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.customer?.username ?? 'Khách lẻ',
                            style: AppTextStyles.arimo(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            appointment.customer?.phone ?? appointment.customer?.email ?? 'Không có thông tin liên hệ',
                            style: AppTextStyles.arimo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    if (appointment.status == AppointmentStatus.pending)
                      Expanded(
                        child: _ActionIconButton(
                          onTap: onConfirm,
                          icon: Icons.check_rounded,
                          label: 'Xác nhận',
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    if (appointment.status == AppointmentStatus.scheduled)
                      Expanded(
                        child: _ActionIconButton(
                          onTap: onComplete,
                          icon: Icons.done_all_rounded,
                          label: 'Hoàn thành',
                          color: const Color(0xFF16A34A),
                        ),
                      ),
                    if (appointment.status == AppointmentStatus.pending || 
                        appointment.status == AppointmentStatus.scheduled)
                      const SizedBox(width: 10),
                    
                    Expanded(
                      child: _ActionIconButton(
                        onTap: onCancel,
                        icon: Icons.close_rounded,
                        label: 'Hủy lịch',
                        color: const Color(0xFFDC2626),
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} | ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _statusAccentColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed: return const Color(0xFF16A34A);
      case AppointmentStatus.scheduled: return const Color(0xFF2563EB);
      case AppointmentStatus.pending: return const Color(0xFFCA8A04);
      case AppointmentStatus.cancelled: return const Color(0xFFDC2626);
      default: return const Color(0xFF64748B);
    }
  }
}

/// Completed appointment card
class _CompletedAppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;

  const _CompletedAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.background, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.appointmentTypeName ?? appointment.name ?? 'Lịch hẹn',
                  style: AppTextStyles.arimo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${appointment.customer?.username ?? 'Khách khách'} • ${_formatDate(appointment.appointmentDate)}',
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withValues(alpha: 0.3)),
        ],
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
          fontWeight: FontWeight.w700,
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
          foreground: const Color(0xFF16A34A),
        );
      case AppointmentStatus.scheduled:
        return _StatusConfig(
          background: const Color(0xFFEFF6FF),
          foreground: const Color(0xFF2563EB),
        );
      case AppointmentStatus.pending:
        return _StatusConfig(
          background: const Color(0xFFFFFBEB),
          foreground: const Color(0xFFCA8A04),
        );
      case AppointmentStatus.cancelled:
        return _StatusConfig(
          background: const Color(0xFFFEF2F2),
          foreground: const Color(0xFFDC2626),
        );
      default:
        return _StatusConfig(
          background: const Color(0xFFF8FAFC),
          foreground: const Color(0xFF64748B),
        );
    }
  }
}

class _StatusConfig {
  final Color background;
  final Color foreground;

  _StatusConfig({required this.background, required this.foreground});
}

class _ActionIconButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final bool isOutlined;

  const _ActionIconButton({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isOutlined ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(12),
            border: isOutlined ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isOutlined ? color : AppColors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.arimo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isOutlined ? color : AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading skeleton when appointments are being fetched
class _AppointmentsLoadingSkeleton extends StatelessWidget {
  const _AppointmentsLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);

    return ListView.builder(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const SizedBox(height: 12);
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AppointmentSkeletonCard(),
        );
      },
    );
  }
}

class _AppointmentSkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonBar(width: 120, height: 10),
          const SizedBox(height: 10),
          _buildSkeletonBar(width: 180, height: 14),
          const SizedBox(height: 8),
          _buildSkeletonBar(width: double.infinity, height: 10),
          const SizedBox(height: 4),
          _buildSkeletonBar(width: 140, height: 10),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildSkeletonBar(height: 32)),
              const SizedBox(width: 8),
              Expanded(child: _buildSkeletonBar(height: 32)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBar({
    double width = double.infinity,
    double height = 12,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

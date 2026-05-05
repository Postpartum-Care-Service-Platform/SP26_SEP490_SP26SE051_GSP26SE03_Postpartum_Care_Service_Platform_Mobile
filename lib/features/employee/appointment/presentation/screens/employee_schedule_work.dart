// lib/features/employee/presentation/screens/employee_schedule_work.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/apis/api_client.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/routing/app_routes.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../features/booking/data/models/booking_model.dart';
import '../../data/datasources/appointment_employee_remote_datasource.dart';
import '../../../../../features/employee/account/presentation/screens/employee_profile_screen.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_quick_menu.dart';
import '../../../../../features/employee/appointment/domain/entities/appointment_entity.dart';
import '../../../../../features/employee/appointment/domain/entities/appointment_status.dart';
import '../../../../../features/employee/appointment/presentation/bloc/appointment/appointment_bloc.dart';
import '../../../../../features/employee/appointment/presentation/bloc/appointment/appointment_event.dart';
import '../../../../../features/employee/appointment/presentation/bloc/appointment/appointment_state.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_header_bar.dart';
import '../../../../../features/employee/shell/presentation/widgets/employee_scaffold.dart';
import '../../../../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../../../../features/wallet/presentation/bloc/wallet_cubit.dart';
import '../../../../../features/wallet/presentation/bloc/wallet_state.dart';
import '../../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../services/presentation/widgets/create_home_staff_withdraw_sheet.dart';

/// Employee Dashboard Screen - Trang chính sau khi staff đăng nhập
/// Hiển thị tổng quan thống kê, quick menu và danh sách appointment gần nhất
class EmployeeScheduleScreenNew extends StatelessWidget {
  final ValueChanged<AppBottomTab>? onBottomTabSelected;

  const EmployeeScheduleScreenNew({super.key, this.onBottomTabSelected});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.employeeAppointmentBloc
            ..add(const LoadMyAssignedAppointments()),
      child: _EmployeeScheduleContent(onBottomTabSelected: onBottomTabSelected),
    );
  }
}

class _EmployeeScheduleContent extends StatelessWidget {
  final ValueChanged<AppBottomTab>? onBottomTabSelected;

  const _EmployeeScheduleContent({this.onBottomTabSelected});

  @override
  Widget build(BuildContext context) {
    return EmployeeScaffold(
      body: Column(
        children: [
          const EmployeeHeaderBar(
            title: 'Portal Nhân viên',
            subtitle: 'Quản lý công việc',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Reload appointments
                context.read<AppointmentBloc>().add(
                  const LoadMyAssignedAppointments(),
                );
                // Reload current account silently
                context.read<AuthBloc>().add(const AuthLoadCurrentAccount());
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
                    return _LoadedContent(
                      appointments: state.appointments,
                      onBottomTabSelected: onBottomTabSelected,
                    );
                  }

                  if (state is AppointmentEmpty) {
                    return _LoadedContent(
                      appointments: const [],
                      onBottomTabSelected: onBottomTabSelected,
                    );
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
class _LoadedContent extends StatefulWidget {
  final List<AppointmentEntity> appointments;
  final ValueChanged<AppBottomTab>? onBottomTabSelected;

  const _LoadedContent({required this.appointments, this.onBottomTabSelected});

  @override
  State<_LoadedContent> createState() => _LoadedContentState();
}

class _LoadedContentState extends State<_LoadedContent> {
  late final AppointmentEmployeeRemoteDataSource _appointmentRemote;
  Future<_DashboardSummary>? _summaryFuture;

  @override
  void initState() {
    super.initState();
    final dio = ApiClient.dio;
    _appointmentRemote = AppointmentEmployeeRemoteDataSource(dio: dio);
    _summaryFuture = _loadSummary();
  }


  Future<_DashboardSummary> _loadSummary() async {
    try {
      final stats = await _appointmentRemote.getDashboardStats();

      return _DashboardSummary(
        mySupportRequests: 0, // Not provided by the new API
        pendingSupportRequests: stats.pendingSupportRequestsCount,
        unscheduledContracts: stats.draftContractsCount,
        todaysBookings: stats.pendingBookingsCount,
        pendingAppointments: stats.pendingAppointmentsCount,
        myWorkBookings: 0, // Not provided by the new API
      );
    } catch (e) {
      debugPrint('Dashboard: Global summary error: $e');
      return const _DashboardSummary.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final padding = AppResponsive.pagePadding(context);
    final authState = context.watch<AuthBloc>().state;
    String? memberType;
    bool isHomeStaff = false;
    if (authState is AuthCurrentAccountLoaded) {
      final account = authState.account;
      memberType = (account as dynamic).memberType;

      // Resilience: check ownerProfile if memberType is null at root
      if (memberType == null) {
        try {
          memberType = (account as dynamic).ownerProfile?.memberTypeName;
        } catch (_) {}
      }

      final typeLower = memberType?.toLowerCase().trim() ?? '';
      isHomeStaff =
          typeLower == 'home-staff' ||
          typeLower == 'homestaff' ||
          typeLower == 'home nurse';
    }

    // Tính toán stats
    final pendingCount = widget.appointments
        .where((a) => a.status == AppointmentStatus.pending)
        .length;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: padding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 12),
              const _HeaderCard(),
              if (isHomeStaff) ...[
                const SizedBox(height: 16),
                const _HomeStaffWalletSection(),
              ] else ...[
                // User requested to remove Stats cho Appointment section here
              ],
              const SizedBox(height: 16),

              _DashboardSummaryRow(
                summaryFuture: _summaryFuture,
                isHomeStaff: isHomeStaff,
                pendingAppointmentsCount: pendingCount,
                onSupportRequestsTap: () {
                  // Điều hướng đến quản lý yêu cầu chat riêng biệt
                  AppRouter.push(context, AppRoutes.employeeSupportRequests);
                },
                onContractsTap: () {
                  AppRouter.push(context, AppRoutes.staffContractList);
                },
                onBookingsTap: () {
                  AppRouter.push(context, AppRoutes.staffBookingList);
                },
                onPendingAppointmentsTap: () {
                  AppRouter.push(context, AppRoutes.employeeAppointmentList);
                },
                onMyBookingsTap: () {
                  AppRouter.push(context, AppRoutes.employeeMyBookings);
                },
              ),
              const SizedBox(height: 16),
              EmployeeQuickMenuSection(
                primaryItems: EmployeeQuickMenuPresets.primaryItems(memberType),
                allItems: EmployeeQuickMenuPresets.allItems(memberType),
                currentTab: AppBottomTab.appointment,
                onBottomTabSelected: (tab) {
                  if (widget.onBottomTabSelected != null) {
                    widget.onBottomTabSelected!(tab);
                    return;
                  }

                  switch (tab) {
                    case AppBottomTab.services:
                      AppRouter.push(context, AppRoutes.employeePackageBooking);
                      break;
                    case AppBottomTab.chat:
                      AppRouter.push(context, AppRoutes.employeeChat);
                      break;
                    case AppBottomTab.supportRequests:
                      AppRouter.push(
                        context,
                        AppRoutes.employeeSupportRequests,
                      );
                      break;
                    case AppBottomTab.appointment:
                    case AppBottomTab.home:
                    case AppBottomTab.profile:
                    case AppBottomTab.family:
                    case AppBottomTab.contracts:
                    case AppBottomTab.amenities:
                    case AppBottomTab.myBookings:
                    case AppBottomTab.wallet:
                    case AppBottomTab.feedback:
                      break;
                  }
                },
                onExtraActionSelected: (action) {
                  switch (action) {
                    case EmployeeQuickMenuExtraAction.amenityService:
                      AppRouter.push(context, AppRoutes.serviceBooking);
                      break;
                    case EmployeeQuickMenuExtraAction.amenityTicket:
                      AppRouter.push(context, AppRoutes.staffAmenityTicketList);
                      break;
                    case EmployeeQuickMenuExtraAction.room:
                      AppRouter.push(context, AppRoutes.employeeRooms);
                      break;
                    case EmployeeQuickMenuExtraAction.requests:
                      AppRouter.push(context, AppRoutes.employeeRequests);
                      break;
                    case EmployeeQuickMenuExtraAction.tasks:
                      AppRouter.push(context, AppRoutes.employeeTasks);
                      break;
                    case EmployeeQuickMenuExtraAction.familyProfile:
                      AppRouter.push(
                        context,
                        AppRoutes.employeeAssignedFamilies,
                      );
                      break;
                    case EmployeeQuickMenuExtraAction.createCustomer:
                      AppRouter.push(context, AppRoutes.employeeCreateCustomer);
                      break;
                    case EmployeeQuickMenuExtraAction.transactions:
                      AppRouter.push(context, AppRoutes.staffTransactionList);
                      break;
                    case EmployeeQuickMenuExtraAction.contracts:
                      AppRouter.push(context, AppRoutes.staffContractList);
                      break;
                    case EmployeeQuickMenuExtraAction.bookings:
                      AppRouter.push(context, AppRoutes.staffBookingList);
                      break;
                    case EmployeeQuickMenuExtraAction.appointments:
                      AppRouter.push(
                        context,
                        AppRoutes.employeeAppointmentList,
                      );
                      break;
                    case EmployeeQuickMenuExtraAction.wallet:
                      AppRouter.push(context, AppRoutes.employeeWallet);
                      break;
                    case EmployeeQuickMenuExtraAction.staffProfile:
                      final authBloc = context.read<AuthBloc>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider<AuthBloc>.value(
                            value: authBloc,
                            child: const EmployeeProfileScreen(),
                          ),
                        ),
                      );
                      break;
                    case EmployeeQuickMenuExtraAction.myBookings:
                      AppRouter.push(context, AppRoutes.employeeMyBookings);
                      break;
                    case EmployeeQuickMenuExtraAction.supportRequests:
                      AppRouter.push(
                        context,
                        AppRoutes.employeeSupportRequests,
                      );
                      break;
                    case EmployeeQuickMenuExtraAction.feedbacks:
                      AppRouter.push(context, AppRoutes.staffFeedbackList);
                      break;
                    case EmployeeQuickMenuExtraAction.withdrawRequest:
                      CreateHomeStaffWithdrawSheet.show(context);
                      break;
                  }
                },
              ),
              SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }
}

/// Header card với chào nhân viên
class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, d MMMM', 'vi').format(now);

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String staffName = 'Nhân viên';
        String? avatarUrl;
        int? experience;
        if (authState is AuthCurrentAccountLoaded) {
          final account = authState.account;
          staffName = account.username.isNotEmpty
              ? account.username
              : account.email.split('@').first;
          avatarUrl = account.avatarUrl;
          experience = account.experience;
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 8 * scale),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
            border: Border.all(
              color: AppColors.borderLight.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(20 * scale),
                child: Row(
                  children: [
                    Container(
                      width: 64 * scale,
                      height: 64 * scale,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(20 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.2),
                            blurRadius: 12 * scale,
                            offset: Offset(0, 4 * scale),
                          ),
                        ],
                      ),
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(20 * scale),
                              child: Image.network(
                                avatarUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 32 * scale,
                            ),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            staffName,
                            style: AppTextStyles.arimo(
                              fontSize: 22 * scale,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8 * scale,
                              vertical: 2 * scale,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF8B5CF6,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: Text(
                              '${experience ?? 0} năm kinh nghiệm',
                              style: AppTextStyles.arimo(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF8B5CF6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 20 * scale,
                  vertical: 12 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.5),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.borderLight.withValues(alpha: 0.05),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14 * scale,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      dateStr,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 4 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Text(
                        'Online',
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Section title với nút xem tất cả
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onViewAll;

  const _SectionTitle({
    required this.title,
    required this.icon,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20 * scale, color: AppColors.primary),
            SizedBox(width: 8 * scale),
            Text(
              title,
              style: AppTextStyles.arimo(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xem tất cả',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4 * scale),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12 * scale,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// _StatsGrid was removed because it was no longer used in the dashboard layout.

class _DashboardSummary {
  final int mySupportRequests;
  final int pendingSupportRequests;
  final int unscheduledContracts;
  final int todaysBookings;
  final int pendingAppointments;
  final int myWorkBookings;

  const _DashboardSummary({
    required this.mySupportRequests,
    required this.pendingSupportRequests,
    required this.unscheduledContracts,
    required this.todaysBookings,
    required this.pendingAppointments,
    required this.myWorkBookings,
  });

  const _DashboardSummary.empty()
    : mySupportRequests = 0,
      pendingSupportRequests = 0,
      unscheduledContracts = 0,
      todaysBookings = 0,
      pendingAppointments = 0,
      myWorkBookings = 0;

  bool get isAllZero =>
      mySupportRequests == 0 &&
      pendingSupportRequests == 0 &&
      unscheduledContracts == 0 &&
      todaysBookings == 0 &&
      pendingAppointments == 0 &&
      myWorkBookings == 0;
}

class _DashboardSummaryRow extends StatelessWidget {
  final Future<_DashboardSummary>? summaryFuture;
  final bool isHomeStaff;
  final int pendingAppointmentsCount;
  final VoidCallback? onSupportRequestsTap;
  final VoidCallback? onContractsTap;
  final VoidCallback? onBookingsTap;
  final VoidCallback? onPendingAppointmentsTap;
  final VoidCallback? onMyBookingsTap;

  const _DashboardSummaryRow({
    required this.summaryFuture,
    this.isHomeStaff = false,
    required this.pendingAppointmentsCount,
    this.onSupportRequestsTap,
    this.onContractsTap,
    this.onBookingsTap,
    this.onPendingAppointmentsTap,
    this.onMyBookingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (summaryFuture == null) {
      return const SizedBox.shrink();
    }

    // Luôn hiển thị layout card, chỉ giá trị bên trong mới cần chờ load
    return FutureBuilder<_DashboardSummary>(
      future: summaryFuture,
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final summary = snapshot.data;


        if (isHomeStaff) {
          return Row(
            children: [
              Expanded(
                child: _DashboardMiniCard(
                  icon: Icons.support_agent,
                  title: 'Hỗ trợ',
                  value: isLoading
                      ? null
                      : '${summary?.pendingSupportRequests ?? 0}',
                  color: const Color(0xFF2563EB),
                  scale: scale,
                  onTap: onSupportRequestsTap,
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _DashboardMiniCard(
                  icon: Icons.book_online,
                  title: 'Booking của tôi',
                  value: isLoading ? null : '${summary?.myWorkBookings ?? 0}',
                  color: const Color(0xFFF97316),
                  scale: scale,
                  onTap: onMyBookingsTap,
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.support_agent,
                    title: 'Yêu cầu hỗ trợ',
                    value: isLoading
                        ? null
                        : '${summary?.pendingSupportRequests ?? 0}',
                    color: const Color(0xFF2563EB),
                    scale: scale,
                    onTap: onSupportRequestsTap,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.article_outlined,
                    title: 'Hợp đồng bản nháp',
                    value: isLoading
                        ? null
                        : '${summary?.unscheduledContracts ?? 0}',
                    color: const Color(0xFF9333EA),
                    scale: scale,
                    onTap: onContractsTap,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8 * scale),
            Row(
              children: [
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.book_online,
                    title: 'Booking cần xử lý',
                    value: isLoading ? null : '${summary?.todaysBookings ?? 0}',
                    color: const Color(0xFF0EA5E9),
                    scale: scale,
                    onTap: onBookingsTap,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.event_note,
                    title: 'Lịch hẹn cần xử lý',
                    value: isLoading
                        ? null
                        : '${summary?.pendingAppointments ?? 0}',
                    color: const Color(0xFFF97316),
                    scale: scale,
                    onTap: onPendingAppointmentsTap,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _DashboardMiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Color color;
  final double scale;
  final VoidCallback? onTap;

  const _DashboardMiniCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.scale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      height: 80 * scale,
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 32 * scale,
            height: 32 * scale,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10 * scale),
            ),
            child: Icon(icon, size: 18 * scale, color: color),
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4 * scale),
                if (value != null)
                  Center(
                    child: Text(
                      value!,
                      style: AppTextStyles.arimo(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  )
                else
                  Center(
                    child: SizedBox(
                      width: 16 * scale,
                      height: 16 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 2 * scale,
                        color: color.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.arrow_forward_ios,
              size: 14 * scale,
              color: color.withValues(alpha: 0.5),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16 * scale),
        child: card,
      );
    }

    return card;
  }
}

// _StatCard was removed because it was only used by the now-deleted _StatsGrid.

// Removed: _SectionTitle, _AppointmentCard, _CompletedAppointmentCard, _StatusBadge, _InfoRow, _ActionButton moved to EmployeeAppointmentListScreen

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


/// Wallet summary section for home-staff - Premium iOS style
class _HomeStaffWalletSection extends StatefulWidget {
  const _HomeStaffWalletSection();

  @override
  State<_HomeStaffWalletSection> createState() =>
      _HomeStaffWalletSectionState();
}

class _HomeStaffWalletSectionState extends State<_HomeStaffWalletSection> {
  late WalletCubit _walletCubit;

  @override
  void initState() {
    super.initState();
    _walletCubit = WalletCubit(
      remoteDataSource: WalletRemoteDataSourceImpl(dio: ApiClient.dio),
    )..loadWallet();
  }

  @override
  void dispose() {
    _walletCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _walletCubit,
      child: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          double balance = 0;
          bool isLoading = state is WalletLoading || state is WalletInitial;

          if (state is WalletLoaded) {
            balance = state.wallet.balance.toDouble();
          }

          final formattedBalance = NumberFormat.currency(
            locale: 'vi_VN',
            symbol: 'đ',
          ).format(balance);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () {
                AppRouter.push(context, AppRoutes.employeeWallet).then((_) {
                  if (mounted) _walletCubit.loadWallet();
                });
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      // Decorative Element 1: Glass Circle
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      // Decorative Element 2: Soft Light highlight
                      Positioned(
                        left: -20,
                        bottom: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.wallet_outlined,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Số dư Ví',
                                      style: AppTextStyles.arimo(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (isLoading)
                                      _buildSkeletonLoader()
                                    else
                                      Text(
                                        formattedBalance,
                                        style: AppTextStyles.arimo(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Cập nhật lúc: ${DateFormat('HH:mm').format(DateTime.now())}',
                                      style: AppTextStyles.arimo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                Material(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    onTap: () {
                                      CreateHomeStaffWithdrawSheet.show(context);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.account_balance_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Rút tiền',
                                            style: AppTextStyles.arimo(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return Container(
      height: 42,
      width: 180,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}

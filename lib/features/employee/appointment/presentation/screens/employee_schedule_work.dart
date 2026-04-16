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
import '../../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../../../../features/booking/data/models/booking_model.dart';
import '../../../../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../../../../features/contract/data/datasources/contract_remote_datasource.dart';
import '../../../../../features/notification/data/datasources/notification_remote_datasource.dart';
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
  late final ChatRemoteDataSource _chatRemote;
  late final ContractRemoteDataSource _contractRemote;
  late final BookingRemoteDataSource _bookingRemote;
  late final NotificationRemoteDataSource _notificationRemote;
  Future<_DashboardSummary>? _summaryFuture;
  Future<List<BookingModel>>? _recentBookingsFuture;

  @override
  void initState() {
    super.initState();
    final dio = ApiClient.dio;
    _chatRemote = ChatRemoteDataSourceImpl(dio: dio);
    _contractRemote = ContractRemoteDataSourceImpl(dio: dio);
    _bookingRemote = BookingRemoteDataSourceImpl(dio: dio);
    _notificationRemote = NotificationRemoteDataSourceImpl(dio: dio);
    _summaryFuture = _loadSummary();
    _recentBookingsFuture = _loadRecentBookings();
  }

  Future<List<BookingModel>> _loadRecentBookings() async {
    try {
      final bookings = await _bookingRemote.getAllBookings();
      // Lấy danh sách booking gần nhất, sắp xếp theo ngày tạo để phân trang ở UI
      bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return bookings;
    } catch (_) {
      return [];
    }
  }

  Future<_DashboardSummary> _loadSummary() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Load both my requests and all pending requests
      final mySupportList = await _chatRemote.getMySupportRequests();
      final allSupportList = await _chatRemote.getSupportRequests();
      
      final noScheduleContracts = await _contractRemote.getNoScheduleContracts();
      final bookings = await _bookingRemote.getAllBookings();
      final notifications = await _notificationRemote.getNotifications();
      final unreadNotificationCount = notifications.where((n) => !n.isRead).length;

      final mySupportCount = mySupportList.length;
      final pendingSupportCount = allSupportList.length;
      final unscheduledContracts = noScheduleContracts.length;
      
      // Đếm booking cần xử lý (status Pending)
      final pendingBookingsCount = bookings.where((b) {
        return b.status.toLowerCase() == 'pending';
      }).length;
      final unreadNotifications = unreadNotificationCount;

      return _DashboardSummary(
        mySupportRequests: mySupportCount,
        pendingSupportRequests: pendingSupportCount,
        unscheduledContracts: unscheduledContracts,
        todaysBookings: pendingBookingsCount,
        unreadNotifications: unreadNotifications,
      );
    } catch (_) {
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
    final totalAssigned = widget.appointments.length;
    final completed = widget.appointments
        .where((a) => a.status == AppointmentStatus.completed)
        .length;
    final pending = widget.appointments
        .where(
          (a) =>
              a.status != AppointmentStatus.completed &&
              a.status != AppointmentStatus.cancelled,
        )
        .length;

    // Lấy 5 appointment gần nhất (chưa hoàn thành, sắp xếp theo thời gian)
    final upcomingAppointments =
        widget.appointments
            .where(
              (a) =>
                  a.status != AppointmentStatus.completed &&
                  a.status != AppointmentStatus.cancelled,
            )
            .toList()
          ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    final recentAppointments = upcomingAppointments.take(5).toList();

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
                const SizedBox(height: 16),
                // Stats cho Appointment
                _SectionTitle(
                  title: 'Lịch hẹn',
                  icon: Icons.event_note,
                  onViewAll: () {
                    AppRouter.push(context, AppRoutes.employeeAppointmentList);
                  },
                ),
                const SizedBox(height: 12),
                _StatsGrid(
                  totalAssigned: totalAssigned,
                  completed: completed,
                  pending: pending,
                  onTap: () {
                    AppRouter.push(context, AppRoutes.employeeAppointmentList);
                  },
                ),
              ],
              const SizedBox(height: 16),

              _DashboardSummaryRow(
                summaryFuture: _summaryFuture,
                isHomeStaff: isHomeStaff,
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
                onNotificationsTap: () {
                  AppRouter.push(context, AppRoutes.notifications);
                },
              ),
              const SizedBox(height: 20),
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
                    case EmployeeQuickMenuExtraAction.mealPlan:
                      AppRouter.push(context, AppRoutes.employeeMealPlan);
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
                      AppRouter.push(
                        context,
                        AppRoutes.staffFeedbackList,
                      );
                      break;
                  }
                },
              ),
              if (!isHomeStaff) ...[
                if (recentAppointments.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _RecentAppointmentsSection(
                    appointments: recentAppointments,
                    totalCount: totalAssigned,
                  ),
                ],
                // Section Booking
                const SizedBox(height: 24),
                _RecentBookingsSection(bookingsFuture: _recentBookingsFuture),
              ],
              const SizedBox(height: 24),
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
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        String staffName = 'Nhân viên';
        if (authState is AuthCurrentAccountLoaded) {
          final account = authState.account;
          // Ưu tiên username cho staff, fallback sang email prefix
          staffName = account.username.isNotEmpty
              ? account.username
              : account.email.split('@').first;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.primary.withValues(alpha: 0.05),
                AppColors.white,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTextStyles.arimo(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      staffName,
                      style: AppTextStyles.arimo(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Portal Nhân viên • Quản lý công việc',
                      style: AppTextStyles.arimo(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: AppColors.white,
                  size: 28,
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

/// Stats grid showing key metrics
class _StatsGrid extends StatelessWidget {
  final int totalAssigned;
  final int completed;
  final int pending;
  final VoidCallback? onTap;

  const _StatsGrid({
    required this.totalAssigned,
    required this.completed,
    required this.pending,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final gap = 12.0 * scale;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Tổng số',
              value: '$totalAssigned',
              valueColor: AppColors.primary,
              icon: Icons.event_note,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _StatCard(
              title: 'Hoàn thành',
              value: '$completed',
              valueColor: const Color(0xFF1B7F3A),
              icon: Icons.check_circle_outline,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _StatCard(
              title: 'Đang xử lý',
              value: '$pending',
              valueColor: const Color(0xFF2563EB),
              icon: Icons.pending_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardSummary {
  final int mySupportRequests;
  final int pendingSupportRequests;
  final int unscheduledContracts;
  final int todaysBookings;
  final int unreadNotifications;

  const _DashboardSummary({
    required this.mySupportRequests,
    required this.pendingSupportRequests,
    required this.unscheduledContracts,
    required this.todaysBookings,
    required this.unreadNotifications,
  });

  const _DashboardSummary.empty()
    : mySupportRequests = 0,
      pendingSupportRequests = 0,
      unscheduledContracts = 0,
      todaysBookings = 0,
      unreadNotifications = 0;

  bool get isAllZero =>
      mySupportRequests == 0 &&
      pendingSupportRequests == 0 &&
      unscheduledContracts == 0 &&
      todaysBookings == 0 &&
      unreadNotifications == 0;
}

class _DashboardSummaryRow extends StatelessWidget {
  final Future<_DashboardSummary>? summaryFuture;
  final bool isHomeStaff;
  final VoidCallback? onSupportRequestsTap;
  final VoidCallback? onContractsTap;
  final VoidCallback? onBookingsTap;
  final VoidCallback? onNotificationsTap;

  const _DashboardSummaryRow({
    required this.summaryFuture,
    this.isHomeStaff = false,
    this.onSupportRequestsTap,
    this.onContractsTap,
    this.onBookingsTap,
    this.onNotificationsTap,
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

        // Sau khi load xong, nếu tất cả đều 0 thì ẩn
        if (!isLoading && summary != null && summary.isAllZero) {
          return const SizedBox.shrink();
        }

        if (isHomeStaff) {
          return Row(
            children: [
              Expanded(
                child: _DashboardMiniCard(
                  icon: Icons.support_agent,
                  title: 'Hỗ trợ',
                  value: isLoading ? null : '${summary?.pendingSupportRequests ?? 0}',
                  color: const Color(0xFF2563EB),
                  scale: scale,
                  onTap: onSupportRequestsTap,
                ),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                child: _DashboardMiniCard(
                  icon: Icons.notifications_active_outlined,
                  title: 'Thông báo',
                  value: isLoading ? null : '${summary?.unreadNotifications ?? 0}',
                  color: const Color(0xFFF97316),
                  scale: scale,
                  onTap: onNotificationsTap,
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
                    value: isLoading ? null : '${summary?.pendingSupportRequests ?? 0}',
                    color: const Color(0xFF2563EB),
                    scale: scale,
                    onTap: onSupportRequestsTap,
                  ),
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: _DashboardMiniCard(
                    icon: Icons.article_outlined,
                    title: 'HĐ chưa lên lịch',
                    value: isLoading ? null : '${summary?.unscheduledContracts ?? 0}',
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
                    icon: Icons.notifications_active_outlined,
                    title: 'Thông báo chưa đọc',
                    value: isLoading ? null : '${summary?.unreadNotifications ?? 0}',
                    color: const Color(0xFFF97316),
                    scale: scale,
                    onTap: onNotificationsTap,
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
      height: 72 * scale,
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

/// Stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;
  final IconData? icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: valueColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.arimo(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 16, color: valueColor.withValues(alpha: 0.6)),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              value,
              style: AppTextStyles.arimo(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

/// Section hiển thị danh sách appointment gần nhất
class _RecentAppointmentsSection extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  final int totalCount;

  const _RecentAppointmentsSection({
    required this.appointments,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4 * scale),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch hẹn sắp tới',
                style: AppTextStyles.arimo(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (totalCount > appointments.length)
                TextButton(
                  onPressed: () {
                    AppRouter.push(context, AppRoutes.employeeAppointmentList);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Xem tất cả ($totalCount)',
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
          ),
        ),
        SizedBox(height: 12 * scale),
        ...appointments.map(
          (appointment) => Padding(
            padding: EdgeInsets.only(bottom: 12 * scale),
            child: _AppointmentCard(appointment: appointment),
          ),
        ),
      ],
    );
  }
}

/// Card hiển thị thông tin appointment
class _AppointmentCard extends StatelessWidget {
  final AppointmentEntity appointment;

  const _AppointmentCard({required this.appointment});

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return const Color(0xFFF59E0B);
      case AppointmentStatus.scheduled:
        return const Color(0xFF2563EB);
      case AppointmentStatus.rescheduled:
        return const Color(0xFF9333EA);
      case AppointmentStatus.completed:
        return const Color(0xFF1B7F3A);
      case AppointmentStatus.cancelled:
        return const Color(0xFFDC2626);
    }
  }

  String _getStatusText(AppointmentStatus status) {
    return status.displayText;
  }

  String _getCustomerDisplayName(CustomerInfo? customer) {
    if (customer == null) return 'Khách hàng';
    if (customer.username != null && customer.username!.isNotEmpty) {
      return customer.username!;
    }
    return customer.email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _getStatusColor(appointment.status);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  _getStatusText(appointment.status),
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.access_time,
                size: 16 * scale,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 4 * scale),
              Text(
                timeFormat.format(appointment.appointmentDate),
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Text(
            appointment.name ?? _getCustomerDisplayName(appointment.customer),
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (appointment.customer != null) ...[
            SizedBox(height: 4 * scale),
            Text(
              appointment.customer!.email,
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: 8 * scale),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14 * scale,
                color: AppColors.textSecondary,
              ),
              SizedBox(width: 6 * scale),
              Text(
                dateFormat.format(appointment.appointmentDate),
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              if (appointment.customer?.phone != null) ...[
                SizedBox(width: 16 * scale),
                Icon(
                  Icons.phone,
                  size: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6 * scale),
                Text(
                  appointment.customer!.phone!,
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Section hiển thị Booking gần nhất
class _RecentBookingsSection extends StatefulWidget {
  final Future<List<BookingModel>>? bookingsFuture;

  const _RecentBookingsSection({required this.bookingsFuture});

  @override
  State<_RecentBookingsSection> createState() => _RecentBookingsSectionState();
}

class _RecentBookingsSectionState extends State<_RecentBookingsSection> {
  static const int _pageSize = 5;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (widget.bookingsFuture == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<BookingModel>>(
      future: widget.bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Booking',
                icon: Icons.book_online,
                onViewAll: () {
                  AppRouter.push(context, AppRoutes.staffBookingList);
                },
              ),
              const SizedBox(height: 12),
              ...List.generate(
                2,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 12 * scale),
                  child: _BookingCardSkeleton(scale: scale),
                ),
              ),
            ],
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final bookings = snapshot.data!;
        final totalPages = (bookings.length / _pageSize).ceil();
        final safeCurrentPage = _currentPage >= totalPages
            ? totalPages - 1
            : _currentPage;
        final start = safeCurrentPage * _pageSize;
        final end = (start + _pageSize) > bookings.length
            ? bookings.length
            : (start + _pageSize);
        final visibleBookings = bookings.sublist(start, end);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: 'Booking gần nhất',
              icon: Icons.book_online,
              onViewAll: () {
                AppRouter.push(context, AppRoutes.staffBookingList);
              },
            ),
            const SizedBox(height: 12),
            ...visibleBookings.map(
              (booking) => Padding(
                padding: EdgeInsets.only(bottom: 12 * scale),
                child: _BookingCard(booking: booking),
              ),
            ),
            if (bookings.length >= _pageSize) ...[
              SizedBox(height: 4 * scale),
              Align(
                alignment: Alignment.centerLeft,
                child: _BookingPaginationControls(
                  currentPage: safeCurrentPage,
                  totalPages: totalPages,
                  onPrevious: safeCurrentPage > 0
                      ? () {
                          setState(() {
                            _currentPage = safeCurrentPage - 1;
                          });
                        }
                      : null,
                  onNext: safeCurrentPage < totalPages - 1
                      ? () {
                          setState(() {
                            _currentPage = safeCurrentPage + 1;
                          });
                        }
                      : null,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _BookingPaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _BookingPaginationControls({
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    const accentOrange = Color(0xFFF59E0B);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: accentOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: accentOrange.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: onPrevious,
            style: FilledButton.styleFrom(
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: accentOrange.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 8 * scale,
              ),
              visualDensity: VisualDensity.compact,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.chevron_left, size: 16),
                SizedBox(width: 2 * scale),
                Text(
                  'Trước',
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6 * scale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * scale,
              vertical: 6 * scale,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accentOrange.withValues(alpha: 0.45)),
            ),
            child: Text(
              'Trang ${currentPage + 1}/$totalPages',
              style: AppTextStyles.arimo(
                fontSize: 11 * scale,
                fontWeight: FontWeight.w700,
                color: accentOrange,
              ),
            ),
          ),
          SizedBox(width: 6 * scale),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
              disabledBackgroundColor: accentOrange.withValues(alpha: 0.35),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.9),
              padding: EdgeInsets.symmetric(
                horizontal: 12 * scale,
                vertical: 8 * scale,
              ),
              visualDensity: VisualDensity.compact,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sau',
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 2 * scale),
                const Icon(Icons.chevron_right, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Card hiển thị Booking
class _BookingCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingCard({required this.booking});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF1B7F3A);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'cancelled':
        return const Color(0xFFDC2626);
      case 'completed':
        return const Color(0xFF2563EB);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'pending':
        return 'Chờ xử lý';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      default:
        return status;
    }
  }

  String _getServiceTitle() {
    final packageName = booking.package?.packageName.trim() ?? '';
    final roomTypeName = booking.package?.roomTypeName.trim() ?? '';

    if (packageName.isNotEmpty && roomTypeName.isNotEmpty) {
      return '$roomTypeName - $packageName';
    }
    if (packageName.isNotEmpty) {
      return packageName;
    }
    if (roomTypeName.isNotEmpty) {
      return roomTypeName;
    }
    return 'Gói dịch vụ';
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(value)} VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final statusColor = _getStatusColor(booking.status);
    final customerName = booking.customer?.username.trim().isNotEmpty == true
        ? booking.customer!.username
        : (booking.customer?.email ?? 'Khách hàng');
    final customerPhone = booking.customer?.phone.trim();
    final paymentStatus = booking.remainingAmount <= 0
        ? 'Đã thanh toán'
        : 'Còn lại: ${_formatCurrency(booking.remainingAmount)}';

    return InkWell(
      onTap: () {
        AppRouter.push(context, AppRoutes.staffBookingList);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.24),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: trạng thái + mã đơn
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 6 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8 * scale),
                  ),
                  child: Text(
                    _getStatusText(booking.status),
                    style: AppTextStyles.arimo(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Mã đơn #${booking.id}',
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),

            // Body: dịch vụ + khách hàng + liên hệ + thanh toán
            Text(
              _getServiceTitle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              customerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                color: AppColors.textPrimary,
              ),
            ),
            if (customerPhone != null && customerPhone.isNotEmpty) ...[
              SizedBox(height: 4 * scale),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 13 * scale,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 6 * scale),
                  Text(
                    customerPhone,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8 * scale),
            Text(
              paymentStatus,
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w600,
                color: booking.remainingAmount <= 0
                    ? const Color(0xFF1B7F3A)
                    : const Color(0xFFF59E0B),
              ),
            ),

            SizedBox(height: 12 * scale),
            Divider(
              height: 1,
              color: AppColors.borderLight.withValues(alpha: 0.8),
            ),
            SizedBox(height: 10 * scale),

            // Footer: ngày tháng + tổng tiền
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 13 * scale,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(width: 6 * scale),
                      Expanded(
                        child: Text(
                          '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10 * scale),
                Text(
                  _formatCurrency(booking.finalAmount),
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
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

/// Skeleton cho Booking Card
class _BookingCardSkeleton extends StatelessWidget {
  final double scale;

  const _BookingCardSkeleton({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100 * scale,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80 * scale,
            height: 20 * scale,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8 * scale),
            ),
          ),
          SizedBox(height: 12 * scale),
          Container(
            width: 150 * scale,
            height: 16 * scale,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4 * scale),
            ),
          ),
          SizedBox(height: 8 * scale),
          Container(
            width: 200 * scale,
            height: 14 * scale,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4 * scale),
            ),
          ),
        ],
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
                            const SizedBox(height: 16),
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

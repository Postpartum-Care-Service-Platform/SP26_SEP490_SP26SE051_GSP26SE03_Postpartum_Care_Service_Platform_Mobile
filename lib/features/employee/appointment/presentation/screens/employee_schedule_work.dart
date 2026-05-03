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
import '../../../../../features/booking/data/datasources/booking_remote_datasource.dart';
import '../../../../../features/booking/data/models/booking_model.dart';
import '../../../../../features/chat/data/datasources/chat_remote_datasource.dart';
import '../../../../../features/contract/data/datasources/contract_remote_datasource.dart';
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
  late final ChatRemoteDataSource _chatRemote;
  late final ContractRemoteDataSource _contractRemote;
  late final BookingRemoteDataSource _bookingRemote;
  late final AppointmentEmployeeRemoteDataSource _appointmentRemote;
  Future<_DashboardSummary>? _summaryFuture;
  Future<List<BookingModel>>? _recentBookingsFuture;
  Future<List<BookingModel>>? _bookingsFutureMemo;

  @override
  void initState() {
    super.initState();
    final dio = ApiClient.dio;
    _chatRemote = ChatRemoteDataSourceImpl(dio: dio);
    _contractRemote = ContractRemoteDataSourceImpl(dio: dio);
    _bookingRemote = BookingRemoteDataSourceImpl(dio: dio);
    _appointmentRemote = AppointmentEmployeeRemoteDataSource(dio: dio);
    _summaryFuture = _loadSummary();
    _recentBookingsFuture = _loadRecentBookings();
  }

  Future<List<BookingModel>> _loadBookings() {
    _bookingsFutureMemo ??= _bookingRemote.getAllBookings();
    return _bookingsFutureMemo!;
  }

  Future<List<BookingModel>> _loadRecentBookings() async {
    try {
      final bookings = await _loadBookings();
      // Lấy danh sách booking gần nhất, sắp xếp theo ngày tạo để phân trang ở UI
      final sortedBookings = List<BookingModel>.from(bookings);
      sortedBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sortedBookings;
    } catch (_) {
      return [];
    }
  }

  Future<_DashboardSummary> _loadSummary() async {
    int mySupportCount = 0;
    int pendingSupportCount = 0;
    int draftContractsCount = 0;
    int pendingBookingsCount = 0;

    try {
      // Yêu cầu hỗ trợ
      try {
        final mySupportList = await _chatRemote.getMySupportRequests();
        mySupportCount = mySupportList.length;
        final allSupportList = await _chatRemote.getSupportRequests();
        pendingSupportCount = allSupportList.length;
      } catch (e) {
        debugPrint('Dashboard: Error loading support requests: $e');
      }

      // Hợp đồng
      try {
        final allContracts = await _contractRemote.getAllContracts();
        draftContractsCount = allContracts.where((c) {
          return c.status.toLowerCase() == 'draft';
        }).length;
      } catch (e) {
        debugPrint('Dashboard: Error loading contracts: $e');
      }

      // Bookings
      try {
        final bookings = await _loadBookings();
        pendingBookingsCount = bookings.where((b) {
          return b.status.toLowerCase() == 'pending';
        }).length;
      } catch (e) {
        debugPrint('Dashboard: Error loading bookings: $e');
      }

      // Appointments (Lịch hẹn) - Lấy tất cả Pending trong hệ thống
      int systemPendingAppts = 0;
      try {
        final allAppts = await _appointmentRemote.getAllAppointments();
        systemPendingAppts = allAppts
            .where((a) => a.status.toLowerCase() == 'pending')
            .length;
      } catch (e) {
        debugPrint('Dashboard: Error loading appointments: $e');
      }

      // Bookings của tôi (Dành riêng cho Home Staff)
      int myWorkBookingsCount = 0;
      try {
        final myBookings = await _bookingRemote.getBookingsByHomeStaff();
        // Đếm các booking đang cần xử lý (chưa hoàn thành/hủy)
        myWorkBookingsCount = myBookings.where((b) {
          final s = b.status.toLowerCase();
          return s == 'pending' ||
              s == 'confirmed' ||
              s == 'inprogress' ||
              s == 'in_progress' ||
              s == 'checked_in' ||
              s == 'active';
        }).length;
      } catch (e) {
        debugPrint('Dashboard: Error loading my bookings count: $e');
      }

      return _DashboardSummary(
        mySupportRequests: mySupportCount,
        pendingSupportRequests: pendingSupportCount,
        unscheduledContracts: draftContractsCount,
        todaysBookings: pendingBookingsCount,
        pendingAppointments: systemPendingAppts,
        myWorkBookings: myWorkBookingsCount,
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
              SizedBox(height: 1 * AppResponsive.scaleFactor(context)),
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
              if (!isHomeStaff) ...[
                // Section Booking
                SizedBox(height: 5),
                _RecentBookingsSection(bookingsFuture: _recentBookingsFuture),
              ],
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
        int? level;
        if (authState is AuthCurrentAccountLoaded) {
          final account = authState.account;
          staffName = account.username.isNotEmpty
              ? account.username
              : account.email.split('@').first;
          avatarUrl = account.avatarUrl;
          experience = account.experience;
          level = account.level;
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

        // Sau khi load xong, nếu tất cả đều 0 thì ẩn
        if (!isLoading && summary != null) {
          final summaryAllZero = summary.isAllZero;
          final isReallyAllZero =
              summaryAllZero &&
              (isHomeStaff ? pendingAppointmentsCount == 0 : true);
          if (isReallyAllZero) {
            return const SizedBox.shrink();
          }
        }

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
              _BookingPaginationControls(
                currentPage: safeCurrentPage,
                totalPages: totalPages,
                onPageSelected: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
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
  final ValueChanged<int>? onPageSelected;

  const _BookingPaginationControls({
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
    this.onPageSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

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
        children: [
          Expanded(
            child: _PaginationButton(
              onPressed: onPrevious,
              icon: Icons.chevron_left,
              label: 'Trước',
              scale: scale,
              accentOrange: accentOrange,
            ),
          ),
          SizedBox(width: 8 * scale),
          // Danh sách số trang - Đặt trong SizedBox cố định để tránh đẩy kích thước nút Trước/Sau
          SizedBox(
            width: 140 * scale,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...() {
                  List<Widget> items = [];
                  int start = (currentPage - 1).clamp(0, totalPages - 1);
                  int end = (start + 2).clamp(0, totalPages - 1);

                  if (end == totalPages - 1 && totalPages >= 3) {
                    start = (end - 2).clamp(0, totalPages - 1);
                  }

                  if (start > 0) {
                    items.add(
                      Text(
                        '...',
                        style: TextStyle(
                          color: accentOrange,
                          fontSize: 11 * scale,
                        ),
                      ),
                    );
                  }

                  for (int i = start; i <= end; i++) {
                    final index = i;
                    final isSelected = index == currentPage;
                    items.add(
                      GestureDetector(
                        onTap: () => onPageSelected?.call(index),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 2 * scale),
                          width: 28 * scale,
                          height: 28 * scale,
                          decoration: BoxDecoration(
                            color: isSelected ? accentOrange : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? accentOrange
                                  : accentOrange.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: AppTextStyles.arimo(
                              fontSize: 11 * scale,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected ? Colors.white : accentOrange,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (end < totalPages - 1) {
                    items.add(
                      Text(
                        '...',
                        style: TextStyle(
                          color: accentOrange,
                          fontSize: 11 * scale,
                        ),
                      ),
                    );
                  }

                  return items;
                }(),
              ],
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: _PaginationButton(
              onPressed: onNext,
              icon: Icons.chevron_right,
              label: 'Sau',
              isTrailingIcon: true,
              scale: scale,
              accentOrange: accentOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool isTrailingIcon;
  final double scale;
  final Color accentOrange;

  const _PaginationButton({
    this.onPressed,
    required this.icon,
    required this.label,
    this.isTrailingIcon = false,
    required this.scale,
    required this.accentOrange,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: accentOrange,
        foregroundColor: Colors.white,
        disabledBackgroundColor: accentOrange.withValues(alpha: 0.15),
        disabledForegroundColor: accentOrange.withValues(alpha: 0.4),
        padding: EdgeInsets.zero,
        minimumSize: Size(0, 32 * scale),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8 * scale),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isTrailingIcon) ...[
            Icon(icon, size: 14 * scale),
            SizedBox(width: 2 * scale),
          ],
          Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (isTrailingIcon) ...[
            SizedBox(width: 2 * scale),
            Icon(icon, size: 14 * scale),
          ],
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
        return const Color(0xFF0284C7); // Sky blue
      case 'pending':
        return const Color(0xFFF59E0B); // Amber
      case 'inprogress':
        return const Color(0xFF6366F1); // Indigo
      case 'cancelled':
        return const Color(0xFFEF4444); // Red
      case 'completed':
        return const Color(0xFF10B981); // Emerald Green
      case 'noshow':
        return const Color(0xFF6B7280); // Gray
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Đang triển khai';
      case 'pending':
        return 'Chờ xác nhận';
      case 'inprogress':
        return 'Đang sử dụng';
      case 'cancelled':
        return 'Đã hủy bỏ';
      case 'completed':
        return 'Đã hoàn thành';
      case 'noshow':
        return 'Không tới';
      default:
        return status;
    }
  }

  String _getServiceTitle() {
    final packageName = booking.package?.packageName.trim() ?? '';
    final roomTypeName = booking.package?.roomTypeName.trim() ?? '';

    if (packageName.isNotEmpty && roomTypeName.isNotEmpty) {
      if (packageName.contains(roomTypeName)) return packageName;
      return '$roomTypeName \u2022 $packageName';
    }
    return packageName.isNotEmpty
        ? packageName
        : (roomTypeName.isNotEmpty ? roomTypeName : 'Gói dịch vụ');
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(value)} VNĐ';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final status = booking.status.toLowerCase();
    final statusColor = _getStatusColor(status);
    final isCancelled = status == 'cancelled';
    final isCompleted = status == 'completed';

    final customerName = booking.customer?.username.trim().isNotEmpty == true
        ? booking.customer!.username
        : (booking.customer?.email ?? 'Khách hàng');
    final customerPhone = booking.customer?.phone.trim();

    return InkWell(
      onTap: () => AppRouter.push(context, AppRoutes.staffBookingList),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: isCancelled ? const Color(0xFFF9FAFB) : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isCancelled
                ? AppColors.borderLight
                : statusColor.withValues(alpha: 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: isCancelled ? 0.02 : 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: EdgeInsets.all(16 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 4 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6 * scale,
                        height: 6 * scale,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        _getStatusText(booking.status),
                        style: AppTextStyles.arimo(
                          fontSize: 10 * scale,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '#${booking.id}',
                  style: AppTextStyles.arimo(
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: 14 * scale),

            // Service Title
            Text(
              _getServiceTitle(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.arimo(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w800,
                color: isCancelled
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8 * scale),

            // Customer Info Row
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14 * scale,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Text(
                    customerName,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (customerPhone != null && customerPhone.isNotEmpty) ...[
                  SizedBox(width: 12 * scale),
                  Icon(
                    Icons.phone_outlined,
                    size: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4 * scale),
                  Text(
                    customerPhone,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 12 * scale),

            // Payment Status Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: isCancelled
                    ? Colors.transparent
                    : (isCompleted
                          ? const Color(0xFFF0FDF4)
                          : const Color(0xFFFFFBEB)),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: isCancelled
                      ? AppColors.borderLight
                      : (isCompleted
                            ? const Color(0xFFBBF7D0)
                            : const Color(0xFFFEF3C7)),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_outline
                        : Icons.payments_outlined,
                    size: 16 * scale,
                    color: isCancelled
                        ? AppColors.textSecondary
                        : (isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFFD97706)),
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: Text(
                      isCancelled
                          ? 'Đã xử lý hủy đơn'
                          : (booking.remainingAmount <= 0
                                ? 'Đã thanh toán đủ'
                                : 'Còn thiếu: ${_formatCurrency(booking.remainingAmount)}'),
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w700,
                        color: isCancelled
                            ? AppColors.textSecondary
                            : (isCompleted
                                  ? const Color(0xFF059669)
                                  : const Color(0xFFD97706)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16 * scale),

            // Footer Divider
            Container(
              height: 1,
              width: double.infinity,
              color: AppColors.borderLight.withValues(alpha: 0.5),
            ),

            SizedBox(height: 12 * scale),

            // Dates and Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      size: 14 * scale,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 6 * scale),
                    Text(
                      '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}',
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Text(
                  _formatCurrency(booking.finalAmount),
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w900,
                    color: isCancelled
                        ? AppColors.textSecondary.withValues(alpha: 0.5)
                        : (isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF97316)),
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../../core/widgets/app_scaffold.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../features/package/presentation/bloc/package_bloc.dart';
import '../../../../../features/employee/shell/presentation/screens/employee_chat_screen.dart';
import '../../../../../features/chat/presentation/screens/employee_support_request_screen.dart';
import '../widgets/employee_bottom_nav_bar.dart';
import '../widgets/employee_fab.dart';
import '../widgets/employee_more_sheet.dart';
import '../../../appointment/index.dart';
import '../../../booking/presentation/screens/employee_package_booking_screen.dart';
import '../../../contract/presentation/screens/staff_contract_list_screen.dart';
import '../../../amenity_ticket/presentation/screens/service_booking_screen.dart';
import '../../../../../features/services/presentation/bloc/staff_schedule/staff_schedule_bloc.dart';
import '../../../../../features/employee/amenity_service/presentation/bloc/amenity_service/amenity_service_bloc.dart';
import '../../../../../features/employee/amenity_service/presentation/bloc/amenity_service/amenity_service_event.dart';
import '../../../../../features/employee/amenity_ticket/presentation/bloc/amenity_ticket/amenity_ticket_bloc.dart';

import '../../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../booking/presentation/screens/staff_booking_list_screen.dart';
import '../../../../../features/wallet/presentation/screens/employee_wallet_screen.dart';
import '../../../../../features/wallet/presentation/bloc/wallet_cubit.dart';
import '../../../../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../../../../core/apis/api_client.dart';
import '../../../feedback/presentation/screens/staff_feedback_screen.dart';

class EmployeePortalScreen extends StatefulWidget {
  const EmployeePortalScreen({super.key});

  @override
  State<EmployeePortalScreen> createState() => _EmployeePortalScreenState();
}

class _EmployeePortalScreenState extends State<EmployeePortalScreen> {
  AppBottomTab _currentTab = AppBottomTab.appointment;
  bool _showBottomNav = true;

  void _backToDefaultStaffPage() {
    if (!mounted) return;
    setState(() {
      _currentTab = AppBottomTab.appointment;
    });
  }

  Widget _buildScreen(AppBottomTab tab) {
    switch (tab) {
      case AppBottomTab.appointment:
        return EmployeeScheduleScreenNew(onBottomTabSelected: _onTabSelected);
      case AppBottomTab.family:
        return EmployeeAssignedFamiliesScreen(
          onBackToDefaultStaffPage: _backToDefaultStaffPage,
        );
      case AppBottomTab.contracts:
        return StaffContractListScreen(
          onBackToDefaultStaffPage: _backToDefaultStaffPage,
        );
      case AppBottomTab.amenities:
        return MultiBlocProvider(
          providers: [
            BlocProvider<StaffScheduleBloc>(
              create: (_) => InjectionContainer.staffScheduleBloc,
            ),
            BlocProvider<AmenityServiceBloc>(
              create: (_) =>
                  InjectionContainer.amenityServiceBloc
                    ..add(const LoadActiveAmenityServices()),
            ),
            BlocProvider<AmenityTicketBloc>(
              create: (_) => InjectionContainer.amenityTicketBloc,
            ),
          ],
          child: ServiceBookingScreen(
            onBackToDefaultStaffPage: _backToDefaultStaffPage,
          ),
        );
      case AppBottomTab.services:
        return BlocProvider<PackageBloc>.value(
          value: InjectionContainer.packageBloc,
          child: EmployeePackageBookingScreen(
            onBackToDefaultStaffPage: _backToDefaultStaffPage,
          ),
        );
      case AppBottomTab.myBookings:
        return const StaffBookingListScreen(useHomeStaffBookings: true);
      case AppBottomTab.wallet:
        return BlocProvider(
          create: (_) => WalletCubit(
            remoteDataSource: WalletRemoteDataSourceImpl(dio: ApiClient.dio),
          ),
          child: const EmployeeWalletScreen(),
        );
      case AppBottomTab.feedback:
        return const StaffFeedbackScreen();
      default:
        return EmployeeScheduleScreenNew(onBottomTabSelected: _onTabSelected);
    }
  }

  void _onTabSelected(AppBottomTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: InjectionContainer.authBloc..add(const AuthLoadCurrentAccount()),
      child: NotificationListener<ToggleBottomNavNotification>(
        onNotification: (notification) {
          if (mounted) {
            setState(() {
              _showBottomNav = notification.show;
            });
          }
          return true;
        },
        child: PopScope(
          canPop: _currentTab == AppBottomTab.appointment,
          onPopInvokedWithResult: (didPop, result) {
            // Nếu đang ở tab khác tab chính, back sẽ đưa về tab trang chủ
            if (!didPop && _currentTab != AppBottomTab.appointment) {
              setState(() {
                _currentTab = AppBottomTab.appointment;
              });
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: _buildScreen(_currentTab),
            bottomNavigationBar: _showBottomNav
                ? EmployeeBottomNavBar(
                    currentTab: _currentTab,
                    onTabSelected: _onTabSelected,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

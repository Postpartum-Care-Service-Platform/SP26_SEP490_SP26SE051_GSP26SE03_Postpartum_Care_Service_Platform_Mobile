import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_bottom_navigation_bar.dart';
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

class EmployeePortalScreen extends StatefulWidget {
  const EmployeePortalScreen({super.key});

  @override
  State<EmployeePortalScreen> createState() => _EmployeePortalScreenState();
}

class _EmployeePortalScreenState extends State<EmployeePortalScreen> {
  AppBottomTab _currentTab = AppBottomTab.appointment;

  void _backToDefaultStaffPage() {
    if (!mounted) return;
    setState(() {
      _currentTab = AppBottomTab.appointment;
    });
  }

  List<Widget> get _screens => [
    EmployeeScheduleScreenNew(
      onBottomTabSelected: _onTabSelected,
    ), // AppBottomTab.appointment (index 0)
    EmployeeAssignedFamiliesScreen(
      onBackToDefaultStaffPage: _backToDefaultStaffPage,
    ), // AppBottomTab.family (index 1)
    StaffContractListScreen(
      onBackToDefaultStaffPage: _backToDefaultStaffPage,
    ), // AppBottomTab.contracts (index 2)
    MultiBlocProvider(
      providers: [
        BlocProvider<StaffScheduleBloc>(
          create: (_) => InjectionContainer.staffScheduleBloc,
        ),
        BlocProvider<AmenityServiceBloc>(
          create: (_) => InjectionContainer.amenityServiceBloc
            ..add(const LoadActiveAmenityServices()),
        ),
        BlocProvider<AmenityTicketBloc>(
          create: (_) => InjectionContainer.amenityTicketBloc,
        ),
      ],
      child: ServiceBookingScreen(
        onBackToDefaultStaffPage: _backToDefaultStaffPage,
      ),
    ), // AppBottomTab.amenities (index 3)
    // Dùng BlocProvider.value để không dispose global PackageBloc
    BlocProvider<PackageBloc>.value(
      value: InjectionContainer.packageBloc,
      child: EmployeePackageBookingScreen(
        onBackToDefaultStaffPage: _backToDefaultStaffPage,
      ), 
    ), // AppBottomTab.services (index 4)
  ];

  void _onTabSelected(AppBottomTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) =>
          InjectionContainer.authBloc..add(const AuthLoadCurrentAccount()),
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
          body: switch (_currentTab) {
            AppBottomTab.appointment => _screens[0],
            AppBottomTab.family => _screens[1],
            AppBottomTab.contracts => _screens[2],
            AppBottomTab.amenities => _screens[3],
            AppBottomTab.services => _screens[4],
            _ => _screens[0],
          },
          bottomNavigationBar: EmployeeBottomNavBar(
            currentTab: _currentTab,
            onTabSelected: _onTabSelected,
          ),
        ),
      ),
    );
  }
}

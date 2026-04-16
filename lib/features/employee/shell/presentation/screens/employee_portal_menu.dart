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
    ), // AppBottomTab.appointment
    // Dùng BlocProvider.value để không dispose global PackageBloc
    BlocProvider<PackageBloc>.value(
      value: InjectionContainer.packageBloc,
      child: EmployeePackageBookingScreen(
        onBackToDefaultStaffPage: _backToDefaultStaffPage,
      ), // AppBottomTab.services
    ),
    EmployeeChatScreen(
      onBackToDefaultStaffPage: _backToDefaultStaffPage,
    ), // AppBottomTab.chat
    EmployeeSupportRequestScreen(
      onBackToDefaultStaffPage: _backToDefaultStaffPage,
    ), // AppBottomTab.supportRequests
  ];

  void _onTabSelected(AppBottomTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: InjectionContainer.authBloc..add(const AuthLoadCurrentAccount()),
      child: PopScope(
        canPop: _currentTab == AppBottomTab.appointment,
        onPopInvokedWithResult: (didPop, result) {
          // Nếu đang ở tab khác tab chính, back sẽ đưa về tab lịch làm việc
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
            AppBottomTab.services => _screens[1],
            AppBottomTab.chat => _screens[2],
            AppBottomTab.supportRequests => _screens[3],
            _ => _screens[0],
          },
          bottomNavigationBar: EmployeeBottomNavBar(
            currentTab: _currentTab,
            onTabSelected: _onTabSelected,
          ),
          floatingActionButton: Builder(
            builder: (fabContext) => EmployeeFab(
              onTap: () => EmployeeMoreSheet.show(fabContext),
            ),
          ),
        ),
      ),
    );
  }
}

// lib/features/employee/presentation/screens/employee_portal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/package/presentation/bloc/package_bloc.dart';
import '../../../../features/package/presentation/screens/package_screen.dart';
import 'employee_chat_screen.dart';
import '../widgets/employee_bottom_nav_bar.dart';
import '../widgets/employee_fab.dart';
import '../widgets/employee_more_sheet.dart';
import 'employee_schedule_screen_new.dart'; // BLoC version

class EmployeePortalScreen extends StatefulWidget {
  const EmployeePortalScreen({super.key});

  @override
  State<EmployeePortalScreen> createState() => _EmployeePortalScreenState();
}

class _EmployeePortalScreenState extends State<EmployeePortalScreen> {
  AppBottomTab _currentTab = AppBottomTab.appointment;

  List<Widget> get _screens => [
        const EmployeeScheduleScreenNew(), // AppBottomTab.appointment
        // Dùng BlocProvider.value để không dispose global PackageBloc
        BlocProvider<PackageBloc>.value(
          value: InjectionContainer.packageBloc,
          child: const PackageScreen(showBackButton: false), // AppBottomTab.services
        ),
        const EmployeeChatScreen(), // AppBottomTab.chat
      ];

  void _onTabSelected(AppBottomTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Nếu đang ở tab khác tab chính, back sẽ đưa về tab lịch làm việc
        if (_currentTab != AppBottomTab.appointment) {
          setState(() {
            _currentTab = AppBottomTab.appointment;
          });
          return false;
        }
        // Ở tab chính thì cho phép pop như bình thường
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: switch (_currentTab) {
          AppBottomTab.appointment => _screens[0],
          AppBottomTab.services => _screens[1],
          AppBottomTab.chat => _screens[2],
          _ => _screens[0],
        },
        bottomNavigationBar: EmployeeBottomNavBar(
          currentTab: _currentTab,
          onTabSelected: _onTabSelected,
        ),
        floatingActionButton: EmployeeFab(
          onTap: () => EmployeeMoreSheet.show(context),
        ),
      ),
    );
  }
}

// lib/features/employee/presentation/screens/employee_portal_screen.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/employee_bottom_nav_bar.dart';
import '../widgets/employee_fab.dart';
import '../widgets/employee_more_sheet.dart';
import 'check_in_out_screen.dart';
import 'employee_schedule_screen.dart';
import 'requests_screen.dart';
import 'tasks_screen.dart';

class EmployeePortalScreen extends StatefulWidget {
  const EmployeePortalScreen({super.key});

  @override
  State<EmployeePortalScreen> createState() => _EmployeePortalScreenState();
}

class _EmployeePortalScreenState extends State<EmployeePortalScreen> {
  EmployeeTab _currentTab = EmployeeTab.schedule;

  final List<Widget> _screens = const [
    EmployeeScheduleScreen(),
    CheckInOutScreen(),
    TasksScreen(),
    RequestsScreen(),
  ];

  void _onTabSelected(EmployeeTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_currentTab.index],
      bottomNavigationBar: EmployeeBottomNavBar(
        currentTab: _currentTab,
        onTabSelected: _onTabSelected,
      ),
      floatingActionButton: EmployeeFab(
        onTap: () => EmployeeMoreSheet.show(context),
      ),
    );
  }
}

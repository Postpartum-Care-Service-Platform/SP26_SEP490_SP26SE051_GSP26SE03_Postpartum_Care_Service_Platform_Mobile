// lib/features/employee/presentation/screens/employee_portal_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/package/presentation/bloc/package_bloc.dart';
import '../../../../features/package/presentation/bloc/package_event.dart';
import '../../../../features/package/presentation/screens/package_screen.dart';
import '../../../../features/chat/presentation/screens/chat_screen.dart';
import '../widgets/employee_bottom_nav_bar.dart';
import '../widgets/employee_fab.dart';
import '../widgets/employee_more_sheet.dart';
import 'employee_schedule_screen_new.dart'; // BLoC version
import 'tasks_screen_new.dart'; // BLoC version

class EmployeePortalScreen extends StatefulWidget {
  const EmployeePortalScreen({super.key});

  @override
  State<EmployeePortalScreen> createState() => _EmployeePortalScreenState();
}

class _EmployeePortalScreenState extends State<EmployeePortalScreen> {
  EmployeeTab _currentTab = EmployeeTab.schedule;

  List<Widget> get _screens => [
        const EmployeeScheduleScreenNew(),
        const TasksScreenNew(),
        BlocProvider<PackageBloc>(
          create: (context) =>
              InjectionContainer.packageBloc..add(const PackageLoadRequested()),
          child: const PackageScreen(),
        ),
        const ChatScreen(),
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

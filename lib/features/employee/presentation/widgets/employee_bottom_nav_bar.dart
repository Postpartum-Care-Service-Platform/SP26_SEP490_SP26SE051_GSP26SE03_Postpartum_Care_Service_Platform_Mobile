// lib/features/employee/presentation/widgets/employee_bottom_nav_bar.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

enum EmployeeTab {
  schedule,
  checkin,
  tasks,
  requests,
}

class EmployeeBottomNavBar extends StatelessWidget {
  final EmployeeTab currentTab;
  final ValueChanged<EmployeeTab> onTabSelected;

  const EmployeeBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentTab.index,
      onTap: (index) => onTabSelected(EmployeeTab.values[index]),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.third,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Lịch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.check_circle),
          label: 'Check-in',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Công việc',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Yêu cầu',
        ),
      ],
    );
  }
}

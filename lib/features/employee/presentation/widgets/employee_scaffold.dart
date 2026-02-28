// lib/features/employee/presentation/widgets/employee_scaffold.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'employee_fab.dart';
import 'employee_more_sheet.dart';

/// Khung Scaffold dùng chung cho các màn trong portal nhân viên.
/// Tự động set background và hiển thị nút "+" mở sheet More.
class EmployeeScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool showFab;

  const EmployeeScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.showFab = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: showFab
          ? EmployeeFab(
              onTap: () => EmployeeMoreSheet.show(context),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


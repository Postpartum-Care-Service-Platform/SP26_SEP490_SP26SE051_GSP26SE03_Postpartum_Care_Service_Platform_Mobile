// lib/features/employee/presentation/widgets/employee_fab.dart
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_widgets.dart';

class EmployeeFab extends StatelessWidget {
  final VoidCallback onTap;

  const EmployeeFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppWidgets.primaryFabIcon(
      context: context,
      icon: Icons.add_rounded,
      onPressed: onTap,
    );
  }
}

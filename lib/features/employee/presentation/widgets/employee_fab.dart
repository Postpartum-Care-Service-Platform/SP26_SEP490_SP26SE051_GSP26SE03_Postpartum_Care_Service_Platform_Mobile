// lib/features/employee/presentation/widgets/employee_fab.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class EmployeeFab extends StatelessWidget {
  final VoidCallback onTap;

  const EmployeeFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: onTap,
      child: const Icon(Icons.add, color: AppColors.white),
    );
  }
}

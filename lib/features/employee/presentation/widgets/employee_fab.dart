// lib/features/employee/presentation/widgets/employee_fab.dart
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';

class EmployeeFab extends StatelessWidget {
  final VoidCallback onTap;

  const EmployeeFab({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale, right: 4 * scale),
child: ClipRRect(
  borderRadius: BorderRadius.circular(999),
  child: BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: 4 * scale,
      sigmaY: 4 * scale,
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.primary.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8 * scale,
            offset: Offset(0, 3 * scale),
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 56 * scale,
                  height: 56 * scale,
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28 * scale,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../bloc/appointment_bloc.dart';
import 'appointment_drawer_helpers.dart';

/// Floating action button for creating new appointment
class ScheduleFloatingActionButton extends StatelessWidget {
  const ScheduleFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 14 * scale,
            offset: Offset(0, 3 * scale),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SizedBox(
        height: 44 * scale,
        child: FloatingActionButton.extended(
          onPressed: () {
            AppointmentDrawerHelpers.openCreateDrawer(
              context,
              context.read<AppointmentBloc>(),
            );
          },
          backgroundColor: AppColors.primary,
          elevation: 0,
          icon: Icon(
            Icons.add_rounded,
            color: AppColors.white,
            size: 20 * scale,
          ),
          label: Text(
            AppStrings.createAppointment,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}

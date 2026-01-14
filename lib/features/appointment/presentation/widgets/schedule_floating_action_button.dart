import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/appointment_bloc.dart';
import 'appointment_drawer_helpers.dart';

/// Floating action button for creating new appointment
class ScheduleFloatingActionButton extends StatelessWidget {
  const ScheduleFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return AppWidgets.primaryFabExtended(
      context: context,
      text: AppStrings.createAppointment,
      icon: Icons.add_rounded,
      onPressed: () {
        AppointmentDrawerHelpers.openCreateDrawer(
          context,
          context.read<AppointmentBloc>(),
        );
      },
      margin: EdgeInsets.only(bottom: 12 * scale),
    );
  }
}

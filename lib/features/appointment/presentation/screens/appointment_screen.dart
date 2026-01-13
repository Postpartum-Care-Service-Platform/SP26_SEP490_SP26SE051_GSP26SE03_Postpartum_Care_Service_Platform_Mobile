import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../widgets/appointment_filter_chips.dart';
import '../widgets/appointment_state_handler.dart';
import '../widgets/schedule_header.dart';
import '../widgets/schedule_floating_action_button.dart';

/// Appointment filter type enum
enum AppointmentFilterType { all, upcoming, completed, cancelled }

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.appointmentBloc
            ..add(const AppointmentLoadRequested()),
      child: const _ScheduleScreenContent(),
    );
  }
}

class _ScheduleScreenContent extends StatefulWidget {
  const _ScheduleScreenContent();

  @override
  State<_ScheduleScreenContent> createState() => _ScheduleScreenContentState();
}

class _ScheduleScreenContentState extends State<_ScheduleScreenContent> {
  AppointmentFilterType _selectedFilter = AppointmentFilterType.upcoming;

  void _handleCancel(
    BuildContext context,
    AppointmentBloc bloc,
    int appointmentId,
  ) {
    AppWidgets.showConfirmDialog(
      context,
      title: AppStrings.confirmCancel,
      message: AppStrings.confirmCancelMessage,
      confirmText: AppStrings.cancelAppointment,
      confirmColor: AppColors.appointmentCancelled,
      icon: Icons.cancel_outlined,
    ).then((confirmed) {
      if (confirmed == true) {
        bloc.add(AppointmentCancelRequested(appointmentId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const ScheduleHeader(),
            AppointmentFilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
            SizedBox(height: 8 * scale),
            Expanded(
              child: AppointmentStateHandler(
                selectedFilter: _selectedFilter,
                onCancel: (appointment) {
                  _handleCancel(
                    context,
                    context.read<AppointmentBloc>(),
                    appointment.id,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const ScheduleFloatingActionButton(),
    );
  }
}

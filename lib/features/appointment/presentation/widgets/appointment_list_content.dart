import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import 'appointment_card.dart';

/// Appointment list content widget with refresh indicator
class AppointmentListContent extends StatelessWidget {
  final List<AppointmentEntity> appointments;
  final Function(AppointmentEntity) onEdit;
  final Function(AppointmentEntity) onCancel;
  final Function(AppointmentEntity) onOpenMap;

  const AppointmentListContent({
    super.key,
    required this.appointments,
    required this.onEdit,
    required this.onCancel,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    // Sort appointments by date (newest first)
    final sortedAppointments = List.from(appointments)
      ..sort((a, b) => b.appointmentDate.compareTo(a.appointmentDate));

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AppointmentBloc>().add(const AppointmentRefresh());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      backgroundColor: AppColors.white,
      strokeWidth: 3,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          20 * scale,
          0,
          20 * scale,
          100 * scale, // Extra padding for FAB
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...sortedAppointments.map(
              (appointment) => AppointmentCard(
                appointment: appointment,
                onEdit: () => onEdit(appointment),
                onCancel: () => onCancel(appointment),
                onOpenMap: () => onOpenMap(appointment),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

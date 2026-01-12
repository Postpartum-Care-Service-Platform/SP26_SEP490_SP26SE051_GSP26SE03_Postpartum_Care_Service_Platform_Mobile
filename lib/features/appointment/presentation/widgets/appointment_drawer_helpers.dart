import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import 'appointment_form_content.dart';
import 'appointment_map_drawer.dart';

/// Helper class for appointment drawer operations
class AppointmentDrawerHelpers {
  /// Open create appointment drawer
  static void openCreateDrawer(
    BuildContext context,
    AppointmentBloc bloc,
  ) {
    final GlobalKey<AppointmentFormContentState> formKey = GlobalKey();
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.5,
        ),
        child: AppDrawerForm(
          title: AppStrings.createAppointment,
          saveButtonText: AppStrings.bookAppointment,
          onSave: () {
            formKey.currentState?.submit();
          },
          children: [
            AppointmentFormContent(
              key: formKey,
              onSubmit: (date, time, name) {
                Navigator.of(sheetContext).pop();
                bloc.add(AppointmentCreateRequested(
                  date: date,
                  time: time,
                  name: name,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Open edit appointment drawer
  static void openEditDrawer(
    BuildContext context,
    AppointmentBloc bloc,
    AppointmentEntity appointment,
  ) {
    final GlobalKey<AppointmentFormContentState> formKey = GlobalKey();
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.5,
        ),
        child: AppDrawerForm(
          title: AppStrings.editAppointment,
          saveButtonText: AppStrings.save,
          onSave: () {
            formKey.currentState?.submit();
          },
          children: [
            AppointmentFormContent(
              key: formKey,
              appointment: appointment,
              onSubmit: (date, time, name) {
                Navigator.of(sheetContext).pop();
                bloc.add(AppointmentUpdateRequested(
                  id: appointment.id,
                  date: date,
                  time: time,
                  name: name,
                ));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Open map drawer
  static void openMapDrawer(
    BuildContext context,
    AppointmentEntity appointment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const AppointmentMapDrawer(),
    );
  }
}

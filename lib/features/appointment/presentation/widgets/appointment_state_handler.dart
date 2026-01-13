import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../bloc/appointment_bloc.dart';
import '../bloc/appointment_event.dart';
import '../bloc/appointment_state.dart';
import 'appointment_empty_state.dart';
import 'appointment_error_state.dart';
import 'appointment_list_content.dart';
import '../../domain/entities/appointment_entity.dart';
import '../screens/appointment_screen.dart';
import 'appointment_drawer_helpers.dart';

/// Widget to handle appointment state changes and display appropriate UI
class AppointmentStateHandler extends StatelessWidget {
  final AppointmentFilterType selectedFilter;
  final Function(AppointmentEntity) onCancel;

  const AppointmentStateHandler({
    super.key,
    required this.selectedFilter,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBloc, AppointmentState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        if (state is AppointmentSuccess) {
          _handleSuccessState(context);
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is AppointmentLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (state is AppointmentError) {
          return AppointmentErrorState(
            message: state.message,
            onRetry: () {
              context.read<AppointmentBloc>().add(
                    const AppointmentLoadRequested(),
                  );
            },
          );
        }

        if (state is AppointmentLoaded) {
          return _buildLoadedState(state, context);
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Handle state changes in listener
  void _handleStateChanges(BuildContext context, AppointmentState state) {
    // Only show AppLoading for submit actions (create/update/cancel)
    // Not for initial data loading (AppointmentLoading)
    if (state is AppointmentCreating ||
        state is AppointmentUpdating ||
        state is AppointmentCancelling) {
      AppLoading.show(context, message: AppStrings.processing);
    } else {
      AppLoading.hide(context);
    }

    if (state is AppointmentSuccess) {
      AppToast.showSuccess(context, message: state.message);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (context.mounted) {
          context.read<AppointmentBloc>().add(const AppointmentRefresh());
        }
      });
    }

    if (state is AppointmentError) {
      AppToast.showError(context, message: state.message);
    }
  }

  /// Handle success state by triggering reload
  void _handleSuccessState(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<AppointmentBloc>().add(const AppointmentRefresh());
      }
    });
  }

  /// Build loaded state with appointments list
  Widget _buildLoadedState(AppointmentLoaded state, BuildContext context) {
    final appointments = state.appointments;

    if (appointments.isEmpty) {
      return const AppointmentEmptyState();
    }

    final filteredAppointments = _filterAppointments(
      appointments,
      selectedFilter,
    );

    if (filteredAppointments.isEmpty) {
      return const AppointmentEmptyState();
    }

    return AppointmentListContent(
      appointments: filteredAppointments,
      onEdit: (appointment) {
        AppointmentDrawerHelpers.openEditDrawer(
          context,
          context.read<AppointmentBloc>(),
          appointment,
        );
      },
      onCancel: onCancel,
      onOpenMap: (appointment) {
        AppointmentDrawerHelpers.openMapDrawer(context, appointment);
      },
    );
  }

  /// Filter appointments based on selected filter type
  List<AppointmentEntity> _filterAppointments(
    List<AppointmentEntity> appointments,
    AppointmentFilterType filterType,
  ) {
    switch (filterType) {
      case AppointmentFilterType.all:
        return appointments;
      case AppointmentFilterType.upcoming:
        return appointments.where((appointment) {
          return appointment.status != AppointmentStatus.completed &&
              appointment.status != AppointmentStatus.cancelled;
        }).toList();
      case AppointmentFilterType.completed:
        return appointments.where((appointment) {
          return appointment.status == AppointmentStatus.completed;
        }).toList();
      case AppointmentFilterType.cancelled:
        return appointments.where((appointment) {
          return appointment.status == AppointmentStatus.cancelled;
        }).toList();
    }
  }
}

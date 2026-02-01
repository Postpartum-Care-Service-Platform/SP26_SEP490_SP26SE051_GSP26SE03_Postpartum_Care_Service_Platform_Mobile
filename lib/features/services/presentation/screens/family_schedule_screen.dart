import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/family_schedule_bloc.dart';
import '../bloc/family_schedule_event.dart';
import '../bloc/family_schedule_state.dart';
import '../widgets/schedule_calendar_picker.dart';
import '../widgets/schedule_day_view.dart';
import '../../domain/entities/family_schedule_entity.dart';

/// Family Schedule Screen
/// Displays daily schedule for postpartum care
class FamilyScheduleScreen extends StatefulWidget {
  const FamilyScheduleScreen({super.key});

  @override
  State<FamilyScheduleScreen> createState() => _FamilyScheduleScreenState();
}

class _FamilyScheduleScreenState extends State<FamilyScheduleScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    // Normalize date to remove time component
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _handleDateSelected(DateTime date) {
    // Normalize date to remove time component
    final normalizedDate = DateTime(date.year, date.month, date.day);
    setState(() {
      _selectedDate = normalizedDate;
    });
  }

  /// Get schedules for the selected date
  List<FamilyScheduleEntity> _getSchedulesForDate(
    FamilyScheduleLoaded state,
  ) {
    final normalizedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return state.schedules.where((schedule) {
      final scheduleDate = DateTime(
        schedule.workDate.year,
        schedule.workDate.month,
        schedule.workDate.day,
      );
      return scheduleDate.year == normalizedDate.year &&
          scheduleDate.month == normalizedDate.month &&
          scheduleDate.day == normalizedDate.day;
    }).toList();
  }

  /// Get dates that have schedules
  List<DateTime> _getDatesWithSchedules(List<FamilyScheduleEntity> schedules) {
    return schedules
        .map((schedule) => schedule.workDate)
        .toSet()
        .toList();
  }

  /// Get day number for the selected date
  int? _getDayNumber(
    List<FamilyScheduleEntity> schedules,
    DateTime date,
  ) {
    final daySchedules = schedules.where((s) {
      final sDate = DateTime(
        s.workDate.year,
        s.workDate.month,
        s.workDate.day,
      );
      final nDate = DateTime(
        date.year,
        date.month,
        date.day,
      );
      return sDate.year == nDate.year &&
          sDate.month == nDate.month &&
          sDate.day == nDate.day;
    }).toList();

    if (daySchedules.isEmpty) return null;
    return daySchedules.first.dayNo;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (context) => context.read<FamilyScheduleBloc>()
        ..add(const FamilyScheduleLoadRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: AppStrings.servicesDailySchedule,
          showBackButton: true,
          centerTitle: true,
        ),
        body: BlocConsumer<FamilyScheduleBloc, FamilyScheduleState>(
          listener: (context, state) {
            if (state is FamilyScheduleError) {
              AppToast.showError(context, message: state.message);
            }
          },
          builder: (context, state) {
            if (state is FamilyScheduleLoading) {
              return Center(
                child: AppLoadingIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is FamilyScheduleError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64 * scale,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16 * scale,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24 * scale),
                    AppWidgets.primaryButton(
                      text: AppStrings.retry,
                      onPressed: () {
                        context
                            .read<FamilyScheduleBloc>()
                            .add(const FamilyScheduleLoadRequested());
                      },
                      width: 200,
                    ),
                  ],
                ),
              );
            }

            if (state is FamilyScheduleLoaded) {
              final schedulesForDate = _getSchedulesForDate(state);
              final datesWithSchedules = _getDatesWithSchedules(state.schedules);
              final dayNo = _getDayNumber(state.schedules, _selectedDate) ?? 0;

              return Column(
                children: [
                  // Calendar picker
                  Padding(
                    padding: EdgeInsets.only(top: 16 * scale),
                    child: ScheduleCalendarPicker(
                      selectedDate: _selectedDate,
                      onDateSelected: _handleDateSelected,
                      datesWithSchedules: datesWithSchedules,
                    ),
                  ),

                  SizedBox(height: 20 * scale),

                  // Day view with timeline
                  Expanded(
                    child: SingleChildScrollView(
                      child: ScheduleDayView(
                        date: _selectedDate,
                        schedules: schedulesForDate,
                        dayNo: dayNo,
                      ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

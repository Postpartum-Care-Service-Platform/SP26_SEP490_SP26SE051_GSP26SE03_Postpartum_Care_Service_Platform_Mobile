import 'package:flutter/material.dart';
import '../../../../core/widgets/app_widgets.dart';

/// Schedule Calendar Picker Widget - Shows week view with dates that have schedules
/// Wrapper around AppWidgets.weekCalendarPicker for schedule dates
class ScheduleCalendarPicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<DateTime> datesWithSchedules;

  const ScheduleCalendarPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.datesWithSchedules = const [],
  });

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _hasSchedule(DateTime date) {
    return datesWithSchedules.any((d) => _isSameDay(d, date));
  }

  @override
  Widget build(BuildContext context) {
    return AppWidgets.weekCalendarPicker(
      context: context,
      selectedDate: selectedDate,
      onDateSelected: onDateSelected,
      hasData: _hasSchedule,
    );
  }
}

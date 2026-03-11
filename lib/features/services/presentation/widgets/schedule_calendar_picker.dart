import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_widgets.dart';

/// Schedule Calendar Picker Widget - Toggle between week and month view
class ScheduleCalendarPicker extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<DateTime> datesWithSchedules;
  final DateTime? minDate;
  final DateTime? maxDate;

  const ScheduleCalendarPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.datesWithSchedules = const [],
    this.minDate,
    this.maxDate,
  });

  @override
  State<ScheduleCalendarPicker> createState() =>
      _ScheduleCalendarPickerState();
}

class _ScheduleCalendarPickerState extends State<ScheduleCalendarPicker> {
  bool _isExpanded = false;

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _hasSchedule(DateTime date) {
    return widget.datesWithSchedules.any((d) => _isSameDay(d, date));
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final calendar = _isExpanded
        ? AppWidgets.monthCalendarPicker(
            context: context,
            selectedDate: widget.selectedDate,
            onDateSelected: widget.onDateSelected,
            hasData: _hasSchedule,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
          )
        : AppWidgets.weekCalendarPicker(
            context: context,
            selectedDate: widget.selectedDate,
            onDateSelected: widget.onDateSelected,
            hasData: _hasSchedule,
            minDate: widget.minDate,
            maxDate: widget.maxDate,
          );

    return Stack(
      children: [
        calendar,
        Positioned(
          right: 24 * scale,
          bottom: -6 * scale,
          child: IconButton(
            onPressed: _toggleExpanded,
            icon: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textSecondary,
              size: 24 * scale,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: _isExpanded
                ? AppStrings.homeServiceCollapseCalendar
                : AppStrings.homeServiceExpandCalendar,
          ),
        ),
      ],
    );
  }
}

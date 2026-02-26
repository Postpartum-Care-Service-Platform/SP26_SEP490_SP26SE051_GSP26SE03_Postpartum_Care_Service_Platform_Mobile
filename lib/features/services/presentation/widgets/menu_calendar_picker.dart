import 'package:flutter/material.dart';
import '../../../../core/widgets/app_widgets.dart';

/// Calendar Picker Widget - Based on Figma design
/// Wrapper around AppWidgets.weekCalendarPicker for menu dates
class MenuCalendarPicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<DateTime> datesWithMenus;

  const MenuCalendarPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.datesWithMenus = const [],
  });

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _hasMenu(DateTime date) {
    return datesWithMenus.any((d) => _isSameDay(d, date));
  }

  @override
  Widget build(BuildContext context) {
    return AppWidgets.weekCalendarPicker(
      context: context,
      selectedDate: selectedDate,
      onDateSelected: onDateSelected,
      hasData: _hasMenu,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// Calendar Picker Widget - Based on Figma design
class MenuCalendarPicker extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final List<DateTime> datesWithMenus;

  const MenuCalendarPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.datesWithMenus = const [],
  });

  @override
  State<MenuCalendarPicker> createState() => _MenuCalendarPickerState();
}

class _MenuCalendarPickerState extends State<MenuCalendarPicker> {
  late DateTime _currentWeekStart; // Monday of current week
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _currentWeekStart = _getMondayOfWeek(widget.selectedDate);
  }

  @override
  void didUpdateWidget(MenuCalendarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
      _currentWeekStart = _getMondayOfWeek(widget.selectedDate);
    }
  }

  /// Get Monday of the week containing the given date
  DateTime _getMondayOfWeek(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final daysFromMonday = (date.weekday - 1) % 7;
    return date.subtract(Duration(days: daysFromMonday));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentWeekStart = _getMondayOfWeek(date);
    });
    widget.onDateSelected(date);
  }

  /// Get 7 days of the current week (Monday to Sunday)
  List<DateTime> _getDaysInWeek() {
    final days = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      days.add(_currentWeekStart.add(Duration(days: i)));
    }
    return days;
  }

  String _getWeekText() {
    final monday = _currentWeekStart;
    final sunday = _currentWeekStart.add(const Duration(days: 6));
    
    // If same month, show "day - day month"
    if (monday.month == sunday.month) {
      return '${monday.day} - ${sunday.day} ${AppFormatters.getMonthName(monday.month)}';
    } else {
      // Different months, show "day month - day month"
      return '${monday.day} ${AppFormatters.getMonthName(monday.month)} - ${sunday.day} ${AppFormatters.getMonthName(sunday.month)}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _hasMenu(DateTime date) {
    return widget.datesWithMenus.any((d) => _isSameDay(d, date));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final days = _getDaysInWeek();
    final weekDays = AppFormatters.getWeekDayAbbreviations();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * scale),
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with week range and navigation arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getWeekText(),
                  style: AppTextStyles.tinos(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 20 * scale,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _previousWeek,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24 * scale,
                      minHeight: 24 * scale,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 20 * scale,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _nextWeek,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24 * scale,
                      minHeight: 24 * scale,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          // Calendar days with day labels - only 7 days (Monday to Sunday)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((entry) {
              final index = entry.key;
              final date = entry.value;
              final dayLabel = weekDays[index];
              final isSelected = _isSameDay(date, _selectedDate);
              final hasMenu = _hasMenu(date);
              final isToday = _isToday(date);

              return GestureDetector(
                onTap: () => _selectDate(date),
                child: Container(
                  width: 44 * scale,
                  padding: EdgeInsets.only(
                    top: 8 * scale,
                    bottom: 8 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? Colors.grey.shade200
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Day label (T2, T3, etc.)
                      Text(
                        dayLabel,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.normal,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      // Date number - fixed height container to ensure consistent positioning
                      SizedBox(
                        height: 20 * scale, // Fixed height for date number
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: AppTextStyles.tinos(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // Fixed space below date number - same for all days
                      SizedBox(height: 6 * scale),
                      // Dot indicator - always reserve same space
                      SizedBox(
                        height: 4 * scale,
                        child: hasMenu && !isSelected
                            ? Container(
                                width: 4 * scale,
                                height: 4 * scale,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

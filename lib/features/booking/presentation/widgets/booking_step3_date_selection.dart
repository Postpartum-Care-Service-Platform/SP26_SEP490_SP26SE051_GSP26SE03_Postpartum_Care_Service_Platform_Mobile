import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import 'booking_step3/check_in_out_cards.dart';

class BookingStep3DateSelection extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const BookingStep3DateSelection({super.key, required this.onDateSelected});

  @override
  State<BookingStep3DateSelection> createState() =>
      _BookingStep3DateSelectionState();
}

class _BookingStep3DateSelectionState extends State<BookingStep3DateSelection> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final today = DateTime.now();
    final firstDate = today;
    final lastDate = today.add(const Duration(days: 365));

    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        PackageEntity? selectedPackage;
        DateTime? checkOutDate;

        // Get selected package to calculate check-out date
        if (state is BookingSummaryReady) {
          selectedPackage = state.package;
          // Always update selected date from summary when available
            _selectedDate = state.startDate;
        } else if (state is BookingPackagesLoaded &&
            state.selectedPackageId != null) {
          // Try to get package from packages list
          try {
            selectedPackage = state.packages.firstWhere(
              (p) => p.id == state.selectedPackageId,
            );
          } catch (e) {
            // Package not found, ignore
          }
        }

        // Update selected date from state if available
        if (state is BookingDateSelected) {
          _selectedDate = state.selectedDate;
        } else if (state is BookingSummaryReady && _selectedDate == null) {
          // Fallback: get from summary if not set
          _selectedDate = state.startDate;
        }

        // Calculate check-out date if we have both package and selected date
        final currentSelectedDate = _selectedDate;
        if (selectedPackage != null && currentSelectedDate != null) {
          checkOutDate = currentSelectedDate.add(
            Duration(days: selectedPackage.durationDays),
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16 * scale,
            4 * scale,
            16 * scale,
            4 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Calendar - fixed size (60% of available space)
              Flexible(
                flex: 4,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8 * scale,
                        offset: Offset(0, 2 * scale),
                      ),
                    ],
                  ),
                  child: _CustomCalendar(
                    selectedDate: _selectedDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                      });
                      widget.onDateSelected(date);
                    },
                  ),
                ),
              ),
              // Selected dates display - 2 squares in a row (below calendar)
              if (_selectedDate != null) ...[
                SizedBox(height: 8 * scale),
                CheckInOutCards(
                  checkInDate: _selectedDate,
                  checkOutDate: checkOutDate,
                ),
              ],
              // Spacer to fill remaining space (only if check-in/check-out is not shown)
              if (_selectedDate == null) Spacer(flex: 2),
            ],
          ),
        );
      },
    );
  }
}

class _CustomCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;

  const _CustomCalendar({
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  State<_CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<_CustomCalendar> {
  late DateTime _currentMonth;
  final List<String> _weekDays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  final List<String> _monthNames = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
    _currentMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
  }

  List<DateTime?> _getDaysInMonth() {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    
    final List<DateTime?> days = [];
    
    // Add empty cells for days before the first day of the month
    for (int i = 0; i < firstDayWeekday; i++) {
      days.add(null);
    }
    
    // Add all days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, day));
    }
    
    return days;
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  bool _isDateDisabled(DateTime date) {
    return date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  bool _isSelected(DateTime date) {
    if (widget.selectedDate == null) return false;
    return date.year == widget.selectedDate!.year &&
        date.month == widget.selectedDate!.month &&
        date.day == widget.selectedDate!.day;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final days = _getDaysInMonth();

    return Padding(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        children: [
          // Header with month/year and navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${_monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                    style: AppTextStyles.tinos(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 16 * scale,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _previousMonth,
                    child: Container(
                      padding: EdgeInsets.all(4 * scale),
                      child: Icon(
                        Icons.chevron_left,
                        size: 20 * scale,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Container(
                      padding: EdgeInsets.all(4 * scale),
                      child: Icon(
                        Icons.chevron_right,
                        size: 20 * scale,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20 * scale),
          // Week days header
          Row(
            children: _weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8 * scale),
          // Calendar grid - allow scrolling if needed
          Flexible(
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: false,
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4 * scale,
                crossAxisSpacing: 4 * scale,
                childAspectRatio: 1.0,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final date = days[index];
                
                if (date == null) {
                  return const SizedBox();
                }
                
                final isDisabled = _isDateDisabled(date);
                final isToday = _isToday(date);
                final isSelected = _isSelected(date);
                
                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () {
                          widget.onDateSelected(date);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : isToday
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isToday && !isSelected
                          ? Border.all(
                              color: AppColors.primary,
                              width: 1,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isDisabled
                              ? AppColors.textSecondary.withValues(alpha: 0.3)
                              : isSelected
                                  ? AppColors.white
                                  : isToday
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

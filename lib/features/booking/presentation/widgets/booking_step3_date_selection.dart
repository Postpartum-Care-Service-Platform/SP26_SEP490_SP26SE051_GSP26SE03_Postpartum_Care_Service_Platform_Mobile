import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
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
          // Prefer package from BookingDateSelected if available
          if (state.package != null) {
            selectedPackage = state.package;
          }
        } else if (state is BookingSummaryReady && _selectedDate == null) {
          // Fallback: get from summary if not set
          _selectedDate = state.startDate;
        }

        // Always ensure we have the selected package and date from bloc if not in state
        final bloc = context.read<BookingBloc>();
        selectedPackage ??= bloc.selectedPackage;
        _selectedDate ??= bloc.selectedDate;

        // Calculate check-out date if we have both package and selected date
        final currentSelectedDate = _selectedDate;
        if (selectedPackage != null && 
            currentSelectedDate != null &&
            selectedPackage.durationDays != null) {
          checkOutDate = currentSelectedDate.add(
            Duration(days: selectedPackage.durationDays!),
          );
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              4 * scale,
              16 * scale,
              4 * scale,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Custom Calendar
                Container(
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
                    checkOutDate: checkOutDate,
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
                // Selected dates display - 2 squares in a row (below calendar)
                if (_selectedDate != null) ...[
                  SizedBox(height: 12 * scale),
                  CheckInOutCards(
                    checkInDate: _selectedDate,
                    checkOutDate: checkOutDate,
                  ),
                  SizedBox(height: 16 * scale),
                  // Staff Availability Status
                  BlocBuilder<BookingBloc, BookingState>(
                    buildWhen: (previous, current) =>
                        current is BookingCheckingStaffAvailability ||
                        current is BookingStaffAvailabilityChecked ||
                        current is BookingDateSelected,
                    builder: (context, state) {
                      if (state is BookingCheckingStaffAvailability) {
                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16 * scale,
                                height: 16 * scale,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              Text(
                                'Đang kiểm tra nhân sự...',
                                style: AppTextStyles.arimo(
                                  fontSize: 13 * scale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is BookingStaffAvailabilityChecked) {
                        if (state.hasAvailableStaff) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale, vertical: 8 * scale),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 18 * scale),
                                SizedBox(width: 8 * scale),
                                Text(
                                  'Còn nhân viên phục vụ (${state.availableCount} người)',
                                  style: AppTextStyles.arimo(
                                    fontSize: 13 * scale,
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12 * scale, vertical: 8 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF44336).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    color: const Color(0xFFF44336), size: 18 * scale),
                                SizedBox(width: 8 * scale),
                                Expanded(
                                  child: Text(
                                    state.message ?? 'Không còn nhân viên phục vụ',
                                    style: AppTextStyles.arimo(
                                      fontSize: 13 * scale,
                                      color: const Color(0xFFF44336),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }

                      return const SizedBox();
                    },
                  ),
                ],
                // Spacing at the bottom
                SizedBox(height: 16 * scale),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomCalendar extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime? checkOutDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;

  const _CustomCalendar({
    required this.selectedDate,
    this.checkOutDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });

  @override
  State<_CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<_CustomCalendar> {
  late DateTime _currentMonth;
  final List<String> _weekDays = [
    AppStrings.weekDaySunday,
    AppStrings.weekDayMonday,
    AppStrings.weekDayTuesday,
    AppStrings.weekDayWednesday,
    AppStrings.weekDayThursday,
    AppStrings.weekDayFriday,
    AppStrings.weekDaySaturday,
  ];
  final List<String> _monthNames = [
    AppStrings.month1,
    AppStrings.month2,
    AppStrings.month3,
    AppStrings.month4,
    AppStrings.month5,
    AppStrings.month6,
    AppStrings.month7,
    AppStrings.month8,
    AppStrings.month9,
    AppStrings.month10,
    AppStrings.month11,
    AppStrings.month12,
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

  bool _isCheckOut(DateTime date) {
    if (widget.checkOutDate == null) return false;
    return date.year == widget.checkOutDate!.year &&
        date.month == widget.checkOutDate!.month &&
        date.day == widget.checkOutDate!.day;
  }

  bool _isInRange(DateTime date) {
    if (widget.selectedDate == null || widget.checkOutDate == null) return false;
    return date.isAfter(widget.selectedDate!) &&
        date.isBefore(widget.checkOutDate!);
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
          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
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
              final isCheckOut = _isCheckOut(date);
              final isInRange = _isInRange(date);
              
              return GestureDetector(
                onTap: isDisabled
                    ? null
                    : () {
                        widget.onDateSelected(date);
                      },
                child: Stack(
                  children: [
                    // Range Highlight Background
                    if (isSelected || isCheckOut || isInRange)
                      Positioned(
                        top: 4 * scale,
                        bottom: 4 * scale,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.horizontal(
                              left: isSelected ? Radius.circular(20 * scale) : Radius.zero,
                              right: isCheckOut ? Radius.circular(20 * scale) : Radius.zero,
                            ),
                          ),
                        ),
                      ),
                    // Date Circle
                    Center(
                      child: Container(
                        width: 36 * scale,
                        height: 36 * scale,
                        decoration: BoxDecoration(
                          color: (isSelected || isCheckOut)
                              ? AppColors.primary
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: isToday && !isSelected && !isCheckOut
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
                              fontWeight: isSelected || isCheckOut || isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isDisabled
                                  ? AppColors.textSecondary.withValues(alpha: 0.3)
                                  : (isSelected || isCheckOut)
                                      ? AppColors.white
                                      : isToday
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

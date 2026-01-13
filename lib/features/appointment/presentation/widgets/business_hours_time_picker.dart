import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';

/// Custom time picker for business hours (8:00 - 17:00)
/// Shows a clock-like UI for easy time selection
class BusinessHoursTimePicker extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay? initialTime;
  final Function(TimeOfDay) onTimeSelected;

  const BusinessHoursTimePicker({
    super.key,
    required this.selectedDate,
    this.initialTime,
    required this.onTimeSelected,
  });

  static Future<TimeOfDay?> show({
    required BuildContext context,
    required DateTime selectedDate,
    TimeOfDay? initialTime,
  }) async {
    TimeOfDay? selectedTime;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BusinessHoursTimePicker(
        selectedDate: selectedDate,
        initialTime: initialTime,
        onTimeSelected: (time) {
          selectedTime = time;
          Navigator.pop(context);
        },
      ),
    );
    
    return selectedTime;
  }

  @override
  State<BusinessHoursTimePicker> createState() => _BusinessHoursTimePickerState();
}

class _BusinessHoursTimePickerState extends State<BusinessHoursTimePicker> {
  static const int _startHour = 8; // 8:00 AM
  static const int _endHour = 17; // 5:00 PM
  
  TimeOfDay? _selectedTime;
  final DateTime _now = DateTime.now();
  bool _isCustomTime = false;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    // Check if initial time is not a standard hour (not :00)
    if (_selectedTime != null && _selectedTime!.minute != 0) {
      _isCustomTime = true;
    }
  }

  bool _isTimeDisabled(int hour) {
    final isToday = _isSameDay(widget.selectedDate, _now);
    if (!isToday) return false;
    
    // If today, disable hours that have passed
    // Also disable if it's the current hour and we're past the hour mark
    if (hour < _now.hour) return true;
    if (hour == _now.hour && _now.minute > 0) return true;
    
    return false;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  List<int> _getAvailableHours() {
    final hours = <int>[];
    final isToday = _isSameDay(widget.selectedDate, _now);
    
    for (int hour = _startHour; hour <= _endHour; hour++) {
      if (!isToday) {
        // For future dates, all business hours are available
        hours.add(hour);
      } else {
        // For today, only show hours that haven't passed
        // If current hour is past, don't show it
        if (hour > _now.hour) {
          hours.add(hour);
        } else if (hour == _now.hour && _now.minute == 0) {
          // Only show current hour if it's exactly on the hour
          hours.add(hour);
        }
      }
    }
    
    return hours;
  }

  void _showCustomTimeDialog(BuildContext context, double scale) {
    final hourController = TextEditingController(
      text: _selectedTime?.hour.toString() ?? '',
    );
    final minuteController = TextEditingController(
      text: _selectedTime?.minute.toString().padLeft(2, '0') ?? '00',
    );
    
    final isToday = _isSameDay(widget.selectedDate, _now);
    final minHour = isToday ? _now.hour : _startHour;
    // If today and selecting current hour, must be at least current minute + 1
    final minMinute = (isToday && _now.hour == minHour) ? _now.minute + 1 : 0;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        title: Text(
          'Nhập giờ tùy chỉnh',
          style: AppTextStyles.tinos(
            fontSize: 18 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Giờ hành chính: 8:00 - 17:00',
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16 * scale),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Giờ',
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      TextField(
                        controller: hourController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '8-17',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                            borderSide: BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                            vertical: 12 * scale,
                          ),
                        ),
                        style: AppTextStyles.arimo(fontSize: 14 * scale),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16 * scale),
                Padding(
                  padding: EdgeInsets.only(top: 32 * scale),
                  child: Text(
                    ':',
                    style: AppTextStyles.arimo(
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phút',
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      TextField(
                        controller: minuteController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '00-59',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                            borderSide: BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12 * scale),
                            borderSide: BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12 * scale,
                            vertical: 12 * scale,
                          ),
                        ),
                        style: AppTextStyles.arimo(fontSize: 14 * scale),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Hủy',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final hour = int.tryParse(hourController.text);
              final minute = int.tryParse(minuteController.text);

              if (hour == null || minute == null) {
                AppToast.showError(
                  context,
                  message: 'Vui lòng nhập đầy đủ giờ và phút',
                );
                return;
              }

              // Validate business hours
              if (hour < _startHour || hour > _endHour) {
                AppToast.showError(
                  context,
                  message:
                      'Giờ phải trong khoảng $_startHour:00 - $_endHour:00',
                );
                return;
              }

              // Validate minute
              if (minute < 0 || minute > 59) {
                AppToast.showError(
                  context,
                  message: 'Phút phải trong khoảng 0-59',
                );
                return;
              }

              // Validate not in the past
              final selectedDateTime = DateTime(
                widget.selectedDate.year,
                widget.selectedDate.month,
                widget.selectedDate.day,
                hour,
                minute,
              );

              if (selectedDateTime.isBefore(_now)) {
                AppToast.showError(
                  context,
                  message: 'Không thể chọn thời gian quá khứ',
                );
                return;
              }

              // Validate minimum time if today
              if (isToday) {
                if (hour < minHour) {
                  AppToast.showError(
                    context,
                    message:
                        'Không thể chọn giờ đã qua. Giờ tối thiểu: ${(_now.hour + 1).toString().padLeft(2, '0')}:00',
                  );
                  return;
                }
                if (hour == minHour && minute < minMinute) {
                  final nextMinute = _now.minute + 1;
                  final nextHour = nextMinute >= 60 ? _now.hour + 1 : _now.hour;
                  final displayMinute = nextMinute >= 60 ? 0 : nextMinute;
                  AppToast.showError(
                    context,
                    message:
                        'Không thể chọn thời gian đã qua. Thời gian tối thiểu: ${nextHour.toString().padLeft(2, '0')}:${displayMinute.toString().padLeft(2, '0')}',
                  );
                  return;
                }
              }

              final customTime = TimeOfDay(hour: hour, minute: minute);
              setState(() {
                _selectedTime = customTime;
                _isCustomTime = true;
              });
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12 * scale),
              ),
            ),
            child: Text(
              'Xác nhận',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final availableHours = _getAvailableHours();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12 * scale, bottom: 8 * scale),
              width: 40 * scale,
              height: 4 * scale,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),
            
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 16 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Chọn giờ hẹn',
                    style: AppTextStyles.tinos(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24 * scale),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            
            // Business hours info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: Container(
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16 * scale,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Text(
                        'Giờ hành chính: 8:00 - 17:00',
                        style: AppTextStyles.arimo(
                          fontSize: 12 * scale,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24 * scale),
            
            // Clock-like time selection
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: availableHours.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Column(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            size: 48 * scale,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 16 * scale),
                          Text(
                            'Không còn khung giờ trống trong ngày hôm nay',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            'Vui lòng chọn ngày khác',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 8 * scale,
                        mainAxisSpacing: 8 * scale,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: availableHours.length,
                       itemBuilder: (context, index) {
                         final hour = availableHours[index];
                         // Only highlight if it's a standard hour (minute == 0) and not custom time
                         final isSelected = !_isCustomTime && 
                             _selectedTime?.hour == hour && 
                             _selectedTime?.minute == 0;
                         final isDisabled = _isTimeDisabled(hour);
                         
                         return InkWell(
                           onTap: isDisabled ? null : () {
                             setState(() {
                               _selectedTime = TimeOfDay(hour: hour, minute: 0);
                               _isCustomTime = false;
                             });
                           },
                          borderRadius: BorderRadius.circular(12 * scale),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDisabled
                                      ? AppColors.borderLight
                                      : AppColors.white),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.borderLight,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 8 * scale,
                                        offset: Offset(0, 2 * scale),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${hour.toString().padLeft(2, '0')}:00',
                                    style: AppTextStyles.arimo(
                                      fontSize: 13 * scale,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected
                                          ? AppColors.white
                                          : (isDisabled
                                              ? AppColors.textSecondary
                                              : AppColors.textPrimary),
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    SizedBox(height: 2 * scale),
                                    Container(
                                      width: 4 * scale,
                                      height: 4 * scale,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            SizedBox(height: 24 * scale),
            
            // Custom time input option
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * scale),
              child: InkWell(
                onTap: () => _showCustomTimeDialog(context, scale),
                borderRadius: BorderRadius.circular(12 * scale),
                child: Container(
                  padding: EdgeInsets.all(16 * scale),
                  decoration: BoxDecoration(
                    color: _isCustomTime
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: _isCustomTime
                          ? AppColors.primary
                          : AppColors.borderLight,
                      width: _isCustomTime ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 20 * scale,
                        color: _isCustomTime
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhập giờ khác',
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                fontWeight: _isCustomTime
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: _isCustomTime
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            if (_isCustomTime && _selectedTime != null) ...[
                              SizedBox(height: 4 * scale),
                              Text(
                                '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16 * scale,
                        color: _isCustomTime
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 24 * scale),
            
            // Confirm button
            Padding(
              padding: EdgeInsets.fromLTRB(24 * scale, 0, 24 * scale, 24 * scale),
              child: SizedBox(
                width: double.infinity,
                height: 52 * scale,
                child: ElevatedButton(
                  onPressed: _selectedTime != null
                      ? () {
                          widget.onTimeSelected(_selectedTime!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.borderLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16 * scale),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Xác nhận',
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

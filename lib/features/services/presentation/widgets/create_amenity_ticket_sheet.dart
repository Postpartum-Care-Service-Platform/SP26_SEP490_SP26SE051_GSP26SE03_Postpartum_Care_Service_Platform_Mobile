import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../../domain/entities/amenity_service_entity.dart';
import '../../domain/entities/family_schedule_entity.dart';
import '../bloc/amenity_bloc.dart';
import 'amenity_service_card.dart';
import '../bloc/amenity_event.dart';
import '../bloc/amenity_state.dart';
import '../bloc/family_schedule_bloc.dart';
import '../bloc/family_schedule_event.dart';
import '../bloc/family_schedule_state.dart';

/// Create Amenity Ticket Bottom Sheet
class CreateAmenityTicketSheet extends StatefulWidget {
  final List<AmenityServiceEntity> services;
  final AmenityServiceEntity? preselectedService;
  final BuildContext parentContext;

  const CreateAmenityTicketSheet({
    super.key,
    required this.services,
    this.preselectedService,
    required this.parentContext,
  });

  static void show(
    BuildContext context,
    List<AmenityServiceEntity> services, {
    AmenityServiceEntity? preselectedService,
  }) {
    final amenityBloc = context.read<AmenityBloc>();
    final familyScheduleBloc = context.read<FamilyScheduleBloc>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: amenityBloc),
          BlocProvider.value(value: familyScheduleBloc),
        ],
        child: CreateAmenityTicketSheet(
          services: services,
          preselectedService: preselectedService,
          parentContext: context,
        ),
      ),
    );
  }

  @override
  State<CreateAmenityTicketSheet> createState() => _CreateAmenityTicketSheetState();
}

class _CreateAmenityTicketSheetState extends State<CreateAmenityTicketSheet> {
  AmenityServiceEntity? _selectedService;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _calculatedEndTime;

  @override
  void initState() {
    super.initState();
    _selectedService = widget.preselectedService;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    
    // Load schedules for today
    _loadSchedulesForDate(_selectedDate!);
  }

  void _loadSchedulesForDate(DateTime date) {
    // Format date as YYYY-MM-DD
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    context.read<FamilyScheduleBloc>().add(
      FamilyScheduleLoadByDateRequested(dateString),
    );
  }

  void _onServiceSelected(AmenityServiceEntity? service) {
    setState(() {
      _selectedService = service;
      if (service != null && _selectedDate != null && _selectedTime != null) {
        _calculateEndTime();
      }
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      if (_selectedService != null && _selectedTime != null) {
        _calculateEndTime();
      }
    });
    _loadSchedulesForDate(date);
  }

  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
      if (_selectedService != null && _selectedDate != null) {
        _calculateEndTime();
      }
    });
  }

  void _calculateEndTime() {
    if (_selectedService == null || _selectedDate == null || _selectedTime == null) {
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final endDateTime = startDateTime.add(
      Duration(minutes: _selectedService!.duration),
    );

    setState(() {
      _calculatedEndTime = endDateTime;
    });
  }


  /// Check if selected time conflicts with existing schedules
  /// Returns the conflicting schedule if found, null otherwise
  FamilyScheduleEntity? _getConflictingSchedule() {
    if (_selectedDate == null || _selectedTime == null || _calculatedEndTime == null) {
      return null;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Get current schedules from bloc state
    final scheduleState = context.read<FamilyScheduleBloc>().state;
    final schedules = scheduleState is FamilyScheduleLoaded 
        ? scheduleState.schedules 
        : <FamilyScheduleEntity>[];

    for (final schedule in schedules) {
      // Only check schedules on the same date
      if (schedule.workDate.year != _selectedDate!.year ||
          schedule.workDate.month != _selectedDate!.month ||
          schedule.workDate.day != _selectedDate!.day) {
        continue;
      }

      // Parse schedule times
      final scheduleStartParts = schedule.startTime.split(':');
      final scheduleEndParts = schedule.endTime.split(':');
      
      if (scheduleStartParts.length >= 2 && scheduleEndParts.length >= 2) {
        final scheduleStart = DateTime(
          schedule.workDate.year,
          schedule.workDate.month,
          schedule.workDate.day,
          int.parse(scheduleStartParts[0]),
          int.parse(scheduleStartParts[1]),
        );
        
        final scheduleEnd = DateTime(
          schedule.workDate.year,
          schedule.workDate.month,
          schedule.workDate.day,
          int.parse(scheduleEndParts[0]),
          int.parse(scheduleEndParts[1]),
        );

        // Check for overlap: two time ranges overlap if:
        // - startDateTime < scheduleEnd AND _calculatedEndTime > scheduleStart
        // This covers all overlap scenarios including:
        // - New time starts before and ends during existing schedule
        // - New time starts during and ends after existing schedule
        // - New time completely contains existing schedule
        // - New time is completely contained by existing schedule
        if (startDateTime.isBefore(scheduleEnd) && _calculatedEndTime!.isAfter(scheduleStart)) {
          return schedule;
        }
      }
    }

    return null;
  }

  bool _hasConflict() {
    return _getConflictingSchedule() != null;
  }

  void _handleSubmit() {
    if (_selectedService == null) {
      AppToast.showError(
        context,
        message: AppStrings.amenityPleaseSelectService,
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      AppToast.showError(
        context,
        message: AppStrings.amenityPleaseSelectTime,
      );
      return;
    }

    if (_calculatedEndTime == null) {
      _calculateEndTime();
      if (_calculatedEndTime == null) {
        AppToast.showError(
          context,
          message: 'Không thể tính toán thời gian kết thúc',
        );
        return;
      }
    }

    // Check for conflicts before submitting
    final conflictingSchedule = _getConflictingSchedule();
    if (conflictingSchedule != null) {
      AppToast.showError(
        context,
        message: 'Thời gian đã chọn bị trùng với "${conflictingSchedule.activity}" (${conflictingSchedule.timeRange}). Vui lòng chọn thời gian khác.',
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // Use parent context to show full screen loading
    AppLoading.show(widget.parentContext, message: AppStrings.processing);

    context.read<AmenityBloc>().add(
          AmenityTicketCreateRequested(
            amenityServiceId: _selectedService!.id,
            startTime: startDateTime,
            endTime: _calculatedEndTime!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocListener<AmenityBloc, AmenityState>(
      listener: (context, state) {
        final parentContext = widget.parentContext;
        
        if (state is AmenityLoaded && state.isCreatingTicket == false) {
          // Ticket created successfully - refresh both services and tickets
          Navigator.of(context).pop();
          AppLoading.hide(parentContext);
          AppToast.showSuccess(
            parentContext,
            message: AppStrings.amenityCreateSuccess,
          );
          // Refresh services and tickets
          context.read<AmenityBloc>().add(const AmenityRefresh());
        } else if (state is AmenityError) {
          AppLoading.hide(parentContext);
          // Improve error message for overlap conflicts
          String errorMessage = state.message;
          if (errorMessage.toLowerCase().contains('overlap') || 
              errorMessage.toLowerCase().contains('trùng') ||
              errorMessage.toLowerCase().contains('conflict')) {
            errorMessage = 'Thời gian đã chọn bị trùng với lịch trình hiện có. Vui lòng chọn thời gian khác.';
          }
          AppToast.showError(
            parentContext,
            message: errorMessage,
          );
        }
      },
      child: AppDrawerForm(
        title: AppStrings.amenityCreateTicket,
        isLoading: context.watch<AmenityBloc>().state is AmenityLoaded &&
            (context.watch<AmenityBloc>().state as AmenityLoaded).isCreatingTicket,
        isDisabled: _hasConflict(),
        onSave: _handleSubmit,
        children: [
          // Service Selection
          _buildServiceSelection(context, scale),
          SizedBox(height: 20 * scale),

          // Date Selection
          _buildDateSelection(context, scale),
          SizedBox(height: 20 * scale),

          // Time Selection - Only show when service is selected
          if (_selectedService != null) ...[
            _buildTimeSelection(context, scale),
            SizedBox(height: 20 * scale),

            // Calculated End Time
            if (_calculatedEndTime != null) ...[
              _buildEndTimeDisplay(context, scale),
              SizedBox(height: 20 * scale),
            ],

            // Schedule Conflict Warning
            if (_hasConflict()) ...[
              _buildConflictWarning(context, scale),
              SizedBox(height: 20 * scale),
            ],
          ],

          // Current Schedule Preview - Show when date is selected (even without service)
          if (_selectedDate != null) ...[
            _buildSchedulePreview(context, scale),
            SizedBox(height: 20 * scale),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceSelection(BuildContext context, double scale) {
    final activeServices = widget.services.where((s) => s.isActive).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.amenitySelectService,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (_selectedService == null) ...[
              SizedBox(width: 8 * scale),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  'Bắt buộc',
                  style: AppTextStyles.arimo(
                    fontSize: 10 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12 * scale),
        if (activeServices.isEmpty)
          Container(
            padding: EdgeInsets.all(24 * scale),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                'Không có dịch vụ tiện ích nào',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Container(
            constraints: BoxConstraints(
              maxHeight: 400 * scale, // Limit height for scrollable grid
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: _selectedService == null
                    ? AppColors.red
                    : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(12 * scale),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12 * scale,
                mainAxisSpacing: 12 * scale,
                childAspectRatio: 0.7, // Card height/width ratio (image 100 + padding/content ~40)
              ),
              itemCount: activeServices.length,
              itemBuilder: (context, index) {
                final service = activeServices[index];
                final isSelected = _selectedService?.id == service.id;
                
                return GestureDetector(
                  onTap: () => _onServiceSelected(service),
                  child: Stack(
                    children: [
                      AmenityServiceCard(
                        service: service,
                        onTap: () => _onServiceSelected(service),
                      ),
                      // Selection indicator
                      if (isSelected)
                        Positioned(
                          top: 8 * scale,
                          right: 8 * scale,
                          child: Container(
                            width: 24 * scale,
                            height: 24 * scale,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8 * scale,
                                  offset: Offset(0, 2 * scale),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.check,
                              size: 16 * scale,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      // Selection border overlay
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        // Selected service info
        if (_selectedService != null) ...[
          SizedBox(height: 12 * scale),
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20 * scale,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã chọn: ${_selectedService!.name}',
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        'Thời lượng: ${_selectedService!.duration} phút',
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18 * scale,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedService = null;
                      _calculatedEndTime = null;
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSelection(BuildContext context, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày',
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12 * scale),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              locale: const Locale('vi', 'VN'),
            );
            if (picked != null) {
              _onDateSelected(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 16 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: _selectedDate == null
                    ? AppColors.red
                    : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? DateFormat('dd/MM/yyyy', 'vi').format(_selectedDate!)
                      : AppStrings.selectDate,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: _selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20 * scale,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Get suggested time slots based on selected service and current schedules
  List<TimeOfDay> _getSuggestedTimeSlots() {
    if (_selectedService == null || _selectedDate == null) {
      return [];
    }

    final duration = _selectedService!.duration;
    final scheduleState = context.read<FamilyScheduleBloc>().state;
    final schedules = scheduleState is FamilyScheduleLoaded 
        ? scheduleState.schedules 
        : <FamilyScheduleEntity>[];

    // Filter schedules for the selected date
    final daySchedules = schedules.where((schedule) {
      return schedule.workDate.year == _selectedDate!.year &&
          schedule.workDate.month == _selectedDate!.month &&
          schedule.workDate.day == _selectedDate!.day;
    }).toList();

    // Sort schedules by start time
    daySchedules.sort((a, b) {
      final aStart = a.startTime.split(':');
      final bStart = b.startTime.split(':');
      final aHour = int.parse(aStart[0]);
      final aMin = int.parse(aStart[1]);
      final bHour = int.parse(bStart[0]);
      final bMin = int.parse(bStart[1]);
      if (aHour != bHour) return aHour.compareTo(bHour);
      return aMin.compareTo(bMin);
    });

    final suggestions = <TimeOfDay>[];
    final now = DateTime.now();
    final isToday = _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    // Start from 8:00 AM or current time if today
    int startHour = 8;
    int startMinute = 0;
    if (isToday) {
      startHour = now.hour;
      startMinute = (now.minute ~/ 15) * 15 + 15; // Round up to next 15 minutes
      if (startMinute >= 60) {
        startHour++;
        startMinute = 0;
      }
    }

    // Find gaps between schedules
    for (int hour = startHour; hour < 22; hour++) {
      for (int minute = (hour == startHour ? startMinute : 0); minute < 60; minute += 15) {
        final slotStart = TimeOfDay(hour: hour, minute: minute);
        final slotStartDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          hour,
          minute,
        );
        final slotEndDateTime = slotStartDateTime.add(Duration(minutes: duration));

        // Check if this slot fits before any schedule or in a gap
        bool fits = true;
        for (final schedule in daySchedules) {
          final scheduleStartParts = schedule.startTime.split(':');
          final scheduleEndParts = schedule.endTime.split(':');
          if (scheduleStartParts.length >= 2 && scheduleEndParts.length >= 2) {
            final scheduleStart = DateTime(
              schedule.workDate.year,
              schedule.workDate.month,
              schedule.workDate.day,
              int.parse(scheduleStartParts[0]),
              int.parse(scheduleStartParts[1]),
            );
            final scheduleEnd = DateTime(
              schedule.workDate.year,
              schedule.workDate.month,
              schedule.workDate.day,
              int.parse(scheduleEndParts[0]),
              int.parse(scheduleEndParts[1]),
            );

            // Check overlap
            if (slotStartDateTime.isBefore(scheduleEnd) && 
                slotEndDateTime.isAfter(scheduleStart)) {
              fits = false;
              break;
            }
          }
        }

        if (fits) {
          suggestions.add(slotStart);
          // Limit to 6 suggestions
          if (suggestions.length >= 6) break;
        }
      }
      if (suggestions.length >= 6) break;
    }

    return suggestions;
  }

  Widget _buildTimeSelection(BuildContext context, double scale) {
    final suggestions = _getSuggestedTimeSlots();
    final hasSuggestions = suggestions.isNotEmpty && 
        _selectedService != null && 
        _selectedDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.amenityStartTime,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12 * scale),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _selectedTime ?? TimeOfDay.now(),
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: true,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              _onTimeSelected(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 16 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(
                color: _selectedTime == null
                    ? AppColors.red
                    : AppColors.borderLight,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedTime != null
                      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                      : AppStrings.selectTime,
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: _selectedTime != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  size: 20 * scale,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        // Suggested time slots
        if (hasSuggestions) ...[
          SizedBox(height: 12 * scale),
          Text(
            'Gợi ý thời gian phù hợp:',
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: [
              ...suggestions.map((time) {
                final isSelected = _selectedTime?.hour == time.hour &&
                    _selectedTime?.minute == time.minute;
                return GestureDetector(
                  onTap: () => _onTimeSelected(time),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 10 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.white
                            : AppColors.primary,
                      ),
                    ),
                  ),
                );
              }),
              // Custom time option
              GestureDetector(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          alwaysUse24HourFormat: true,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    _onTimeSelected(picked);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 10 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16 * scale,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4 * scale),
                      Text(
                        'Tùy chọn',
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEndTimeDisplay(BuildContext context, double scale) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            size: 20 * scale,
            color: AppColors.primary,
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.amenityEndTime,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  DateFormat('HH:mm', 'vi').format(_calculatedEndTime!),
                  style: AppTextStyles.arimo(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictWarning(BuildContext context, double scale) {
    final conflictingSchedule = _getConflictingSchedule();
    
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: AppColors.red.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 24 * scale,
                color: AppColors.red,
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  'Thời gian đã chọn bị trùng với lịch trình hiện có',
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.red,
                  ),
                ),
              ),
            ],
          ),
          if (conflictingSchedule != null) ...[
            SizedBox(height: 12 * scale),
            Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: AppColors.red.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8 * scale,
                      vertical: 4 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8 * scale),
                    ),
                    child: Text(
                      conflictingSchedule.timeRange,
                      style: AppTextStyles.arimo(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.red,
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Expanded(
                    child: Text(
                      conflictingSchedule.activity,
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Vui lòng chọn thời gian khác để tránh trùng lịch.',
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSchedulePreview(BuildContext context, double scale) {
    // Use selectedDate as key to force rebuild when date changes
    final dateKey = _selectedDate?.toIso8601String() ?? '';
    
    return BlocBuilder<FamilyScheduleBloc, FamilyScheduleState>(
      key: ValueKey('schedule_preview_$dateKey'),
      builder: (context, scheduleState) {
        final isLoading = scheduleState is FamilyScheduleLoading;
        // Always use schedules from state if available
        final schedules = scheduleState is FamilyScheduleLoaded 
            ? scheduleState.schedules 
            : <FamilyScheduleEntity>[];
        
        // Debug: Print schedules count
        print('SchedulePreview: isLoading=$isLoading, schedulesCount=${schedules.length}, dateKey=$dateKey');

        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.amenityCurrentSchedule,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isLoading) ...[
              SizedBox(width: 8 * scale),
              SizedBox(
                width: 14 * scale,
                height: 14 * scale,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12 * scale),
        Container(
          constraints: BoxConstraints(maxHeight: 200 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16 * scale),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          child: isLoading
              ? Padding(
                  padding: EdgeInsets.all(24 * scale),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                )
                  : schedules.isEmpty
                  ? Padding(
                      padding: EdgeInsets.all(24 * scale),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 32 * scale,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: 8 * scale),
                            Text(
                              'Không có lịch trình cho ngày này',
                              style: AppTextStyles.arimo(
                                fontSize: 13 * scale,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return Container(
                          padding: EdgeInsets.all(12 * scale),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AppColors.borderLight,
                                width: index < schedules.length - 1 ? 1 : 0,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8 * scale,
                                  vertical: 4 * scale,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8 * scale),
                                ),
                                child: Text(
                                  schedule.timeRange,
                                  style: AppTextStyles.arimo(
                                    fontSize: 11 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: Text(
                                  schedule.activity,
                                  style: AppTextStyles.arimo(
                                    fontSize: 13 * scale,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
      },
    );
  }
}

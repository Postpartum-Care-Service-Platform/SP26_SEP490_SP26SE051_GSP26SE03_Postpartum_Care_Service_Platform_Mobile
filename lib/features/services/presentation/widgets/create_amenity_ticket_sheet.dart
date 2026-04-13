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
  final List<FamilyScheduleEntity>? predefinedSchedules;
  final void Function(AmenityServiceEntity service, DateTime date, TimeOfDay startTime, DateTime endTime)? onStaffSubmit;

  const CreateAmenityTicketSheet({
    super.key,
    required this.services,
    this.preselectedService,
    required this.parentContext,
    this.predefinedSchedules,
    this.onStaffSubmit,
  });

  static void show(
    BuildContext context,
    List<AmenityServiceEntity> services, {
    AmenityServiceEntity? preselectedService,
    List<FamilyScheduleEntity>? predefinedSchedules,
    void Function(AmenityServiceEntity service, DateTime date, TimeOfDay startTime, DateTime endTime)? onStaffSubmit,
  }) {
    final amenityBloc = context.read<AmenityBloc>();
    final familyScheduleBloc = onStaffSubmit == null ? context.read<FamilyScheduleBloc>() : null;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final child = CreateAmenityTicketSheet(
          services: services,
          preselectedService: preselectedService,
          parentContext: context,
          predefinedSchedules: predefinedSchedules,
          onStaffSubmit: onStaffSubmit,
        );

        if (onStaffSubmit != null) {
          // Khi staff tạo, ta sẽ tự quản lý submit nên không cung cấp Bloc làm gì nếu ko có
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: amenityBloc),
            ],
            child: child,
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: amenityBloc),
            if (familyScheduleBloc != null) BlocProvider.value(value: familyScheduleBloc),
          ],
          child: child,
        );
      },
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
    if (widget.predefinedSchedules != null) {
      // Dùng lịch truyền từ parent, không cần gọi API (đây là staff tạo ticket cho khách)
      setState(() {});
      return;
    }

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
    if (_selectedDate != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        time.hour,
        time.minute,
      );
      
      if (selectedDateTime.isBefore(now)) {
        AppToast.showError(context, message: 'Bạn không thể chọn thời gian trong quá khứ');
        return;
      }
    }

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

    List<FamilyScheduleEntity> schedules = [];
    if (widget.predefinedSchedules != null) {
      schedules = widget.predefinedSchedules!;
    } else {
      // Get current schedules from bloc state
      final scheduleState = context.read<FamilyScheduleBloc>().state;
      schedules = scheduleState is FamilyScheduleLoaded 
          ? scheduleState.schedules 
          : <FamilyScheduleEntity>[];
    }

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

    if (widget.onStaffSubmit != null) {
      widget.onStaffSubmit!(
        _selectedService!,
        _selectedDate!,
        _selectedTime!,
        _calculatedEndTime!,
      );
      return;
    }

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
        isDisabled: _selectedService == null || _hasConflict(),
        saveButtonIcon: Icons.check_circle_outline,
        onSave: _handleSubmit,
        children: [
          // Service Selection
          _buildServiceSelection(context, scale),
          SizedBox(height: 20 * scale),

          // Date Selection
          _buildDateSelection(context, scale),
          SizedBox(height: 20 * scale),

          // Time Selection
          _buildTimeSelection(context, scale),
          SizedBox(height: 20 * scale),

          // Schedule Preview (always show when date is selected)
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
                mainAxisExtent: 190 * scale, // Fixed height specifically for image + 2 lines text
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
            final amenityState = context.read<AmenityBloc>().state;
            DateTime minDate = DateTime.now();
            DateTime maxDate = DateTime.now().add(const Duration(days: 365));

            if (amenityState is AmenityLoaded) {
              if (amenityState.checkInDate != null) {
                // Determine if today is after checkInDate. If so, user can only pick from today onwards to prevent booking in the past
                // Or if it's strictly check-in to check-out. Let's use checkInDate as firstDate, but bound by today for fairness?
                // Actually, just limit securely to the booking range.
                minDate = amenityState.checkInDate!;
                if (DateTime.now().isAfter(minDate)) {
                  // If we are currently in the middle of a booking
                  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
                  minDate = today.isAfter(amenityState.checkOutDate ?? maxDate)
                      ? amenityState.checkOutDate ?? maxDate
                      : today;
                }
              }
              if (amenityState.checkOutDate != null) {
                maxDate = amenityState.checkOutDate!;
              }
            }

            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? minDate,
              firstDate: minDate,
              lastDate: maxDate.isBefore(minDate) ? minDate : maxDate,
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



  Widget _buildTimeSelection(BuildContext context, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Start Time Input
            Expanded(
              child: Column(
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
                          Expanded(
                            child: Text(
                              _selectedTime != null
                                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : AppStrings.selectTime,
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                color: _selectedTime != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                  // Placeholder to keep alignment with End Time column
                  SizedBox(height: 25 * scale),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            // End Time Display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.amenityEndTime,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16 * scale,
                      vertical: 16 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: _hasConflict()
                          ? AppColors.red.withValues(alpha: 0.05)
                          : _calculatedEndTime != null 
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : AppColors.background,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(
                        color: _hasConflict()
                            ? AppColors.red
                            : _calculatedEndTime != null
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _calculatedEndTime != null
                                ? DateFormat('HH:mm', 'vi').format(_calculatedEndTime!)
                                : '--:--',
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: _calculatedEndTime != null ? FontWeight.w600 : FontWeight.normal,
                              color: _hasConflict()
                                  ? AppColors.red
                                  : _calculatedEndTime != null
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.schedule,
                          size: 20 * scale,
                          color: _hasConflict()
                              ? AppColors.red
                              : _calculatedEndTime != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  // Reserve space for error message to avoid layout shift
                  SizedBox(
                    height: 25 * scale, // Enough space for one line of text + padding
                    child: _hasConflict()
                        ? Padding(
                            padding: EdgeInsets.only(top: 6 * scale),
                            child: Text(
                              'Trùng: ${_getConflictingSchedule()?.activity ?? ""}',
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                color: AppColors.red,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }



  Widget _buildSchedulePreview(BuildContext context, double scale) {
    // Use selectedDate as key to force rebuild when date changes
    final dateKey = _selectedDate?.toIso8601String() ?? '';
    
    if (widget.predefinedSchedules != null) {
      final now = DateTime.now();
      final schedules = widget.predefinedSchedules!.where((schedule) {
        if (_selectedDate != null && 
           (schedule.workDate.year != _selectedDate!.year ||
            schedule.workDate.month != _selectedDate!.month ||
            schedule.workDate.day != _selectedDate!.day)) {
          return false;
        }

        final endParts = schedule.endTime.split(':');
        if (endParts.length >= 2) {
          final scheduleEnd = DateTime(
            schedule.workDate.year,
            schedule.workDate.month,
            schedule.workDate.day,
            int.parse(endParts[0]),
            int.parse(endParts[1]),
          );
          // If the selected date is today, only show upcoming schedules
          if (schedule.workDate.year == now.year &&
              schedule.workDate.month == now.month &&
              schedule.workDate.day == now.day) {
             return scheduleEnd.isAfter(now);
          }
          return true;
        }
        return true;
      }).toList();

      return _buildSchedulePreviewContent(context, scale, schedules, false);
    }

    return BlocBuilder<FamilyScheduleBloc, FamilyScheduleState>(
      key: ValueKey('schedule_preview_$dateKey'),
      builder: (context, scheduleState) {
        final isLoading = scheduleState is FamilyScheduleLoading;
        List<FamilyScheduleEntity> schedules = [];
        if (scheduleState is FamilyScheduleLoaded) {
          final now = DateTime.now();
          schedules = scheduleState.schedules.where((schedule) {
            final endParts = schedule.endTime.split(':');
            if (endParts.length >= 2) {
              final scheduleEnd = DateTime(
                schedule.workDate.year,
                schedule.workDate.month,
                schedule.workDate.day,
                int.parse(endParts[0]),
                int.parse(endParts[1]),
              );
              return scheduleEnd.isAfter(now);
            }
            return true;
          }).toList();
        }
        return _buildSchedulePreviewContent(context, scale, schedules, isLoading);
      },
    );
  }

  Widget _buildSchedulePreviewContent(BuildContext context, double scale, List<FamilyScheduleEntity> schedules, bool isLoading) {
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
                      physics: const NeverScrollableScrollPhysics(),
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
  }
}

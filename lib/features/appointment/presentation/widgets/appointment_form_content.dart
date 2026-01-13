import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/appointment_type_entity.dart';
import '../../domain/usecases/get_appointment_types_usecase.dart';
import '../../../../core/di/injection_container.dart';
import 'business_hours_time_picker.dart';

/// Appointment form content widget (for use in drawer or dialog)
class AppointmentFormContent extends StatefulWidget {
  final AppointmentEntity? appointment;
  final Function(String date, String time, String name, int? appointmentTypeId) onSubmit;

  const AppointmentFormContent({
    super.key,
    this.appointment,
    required this.onSubmit,
  });

  @override
  AppointmentFormContentState createState() => AppointmentFormContentState();
}

/// State class exposed for external access
class AppointmentFormContentState extends State<AppointmentFormContent> {

  late TextEditingController _nameController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<AppointmentTypeEntity> _appointmentTypes = [];
  int? _selectedAppointmentTypeId;
  bool _isLoadingTypes = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.appointment?.name ?? '',
    );
    if (widget.appointment != null) {
      _selectedDate = widget.appointment!.appointmentDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.appointment!.appointmentDate);
      _selectedAppointmentTypeId = widget.appointment!.appointmentType?.id;
    }
    _loadAppointmentTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointmentTypes() async {
    setState(() {
      _isLoadingTypes = true;
    });
    try {
      final GetAppointmentTypesUsecase usecase =
          InjectionContainer.appointmentTypesUsecase;
      final types = await usecase();
      setState(() {
        _appointmentTypes = types;
        _selectedAppointmentTypeId = _selectedAppointmentTypeId ??
            (types.isNotEmpty ? types.first.id : null);
      });
    } catch (_) {
      // silent fail; dropdown will be empty
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTypes = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    // Only allow selecting today or future dates
    final DateTime firstDate = widget.appointment != null
        ? (widget.appointment!.appointmentDate.isBefore(now)
            ? widget.appointment!.appointmentDate
            : now)
        : now;
    final DateTime lastDate = now.add(const Duration(days: 365));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('vi', 'VN'),
      // Disable past dates
      selectableDayPredicate: (DateTime date) {
        // Allow today and future dates only
        final today = DateTime(now.year, now.month, now.day);
        final selectedDay = DateTime(date.year, date.month, date.day);
        return selectedDay.isAtSameMomentAs(today) || selectedDay.isAfter(today);
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        // Reset time if selected date is today and current time has passed
        final today = DateTime(now.year, now.month, now.day);
        final selectedDay = DateTime(picked.year, picked.month, picked.day);
        if (selectedDay.isAtSameMomentAs(today) && _selectedTime != null) {
          final selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
          if (selectedDateTime.isBefore(now)) {
            _selectedTime = null;
          }
        }
      });
      
      // Automatically show time picker after selecting date
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          await _selectTime(context);
        }
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    if (_selectedDate == null) {
      AppToast.showError(
        context,
        message: 'Vui lòng chọn ngày trước',
      );
      return;
    }

    final TimeOfDay? picked = await BusinessHoursTimePicker.show(
      context: context,
      selectedDate: _selectedDate!,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      AppToast.showError(
        context,
        message: AppStrings.pleaseEnterAppointmentName,
      );
      return false;
    }

    if (_selectedDate == null) {
      AppToast.showError(
        context,
        message: AppStrings.pleaseSelectDate,
      );
      return false;
    }

    if (_selectedTime == null) {
      AppToast.showError(
        context,
        message: AppStrings.pleaseSelectTime,
      );
      return false;
    }

    // Validate that appointment is not in the past
    final appointmentDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );
    
    final now = DateTime.now();
    if (appointmentDateTime.isBefore(now)) {
      AppToast.showError(
        context,
        message: 'Không thể đặt lịch hẹn vào thời gian quá khứ',
      );
      return false;
    }

    // Validate business hours (8:00 - 17:00)
    if (_selectedTime!.hour < 8 || _selectedTime!.hour > 17) {
      AppToast.showError(
        context,
        message: 'Chỉ có thể đặt lịch trong giờ hành chính (8:00 - 17:00)',
      );
      return false;
    }

    if (_appointmentTypes.isNotEmpty && _selectedAppointmentTypeId == null) {
      AppToast.showError(
        context,
        message: AppStrings.pleaseSelectAppointmentType,
      );
      return false;
    }

    return true;
  }


  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name field
        AppWidgets.textInput(
          label: AppStrings.appointmentName,
          placeholder: AppStrings.appointmentNamePlaceholder,
          controller: _nameController,
        ),
        SizedBox(height: 12 * scale),

        // Date and Time in one row
        Row(
          children: [
            // Date field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.appointmentDate,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedDate != null
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: _selectedDate != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18 * scale,
                            color: _selectedDate != null
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          SizedBox(width: 8 * scale),
                          Expanded(
                            child: Text(
                              _selectedDate != null
                                  ? _formatDate(_selectedDate!)
                                  : AppStrings.selectAppointmentDate,
                              style: AppTextStyles.arimo(
                                fontSize: 13 * scale,
                                color: _selectedDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12 * scale),
            // Time field
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.appointmentTime,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8 * scale),
                  InkWell(
                    onTap: () => _selectTime(context),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedTime != null
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: _selectedTime != null ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 18 * scale,
                            color: _selectedTime != null
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          SizedBox(width: 8 * scale),
                          Expanded(
                            child: Text(
                              _selectedTime != null
                                  ? _formatTime(_selectedTime!)
                                  : AppStrings.selectAppointmentTime,
                              style: AppTextStyles.arimo(
                                fontSize: 13 * scale,
                                color: _selectedTime != null
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),

        // Appointment Type - single choice list
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appointmentType,
              style: AppTextStyles.arimo(
                fontSize: 13 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8 * scale),
            if (_isLoadingTypes)
              Text(
                '${AppStrings.loading}...',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              )
            else if (_appointmentTypes.isEmpty)
              Text(
                AppStrings.selectAppointmentType,
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              )
            else
              Column(
                children: _appointmentTypes.map((type) {
                  final bool isSelected =
                      _selectedAppointmentTypeId == type.id;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAppointmentTypeId = type.id;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.only(bottom: 6 * scale),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 10 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.06)
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderLight,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            size: 18 * scale,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          SizedBox(width: 8 * scale),
                          Expanded(
                            child: Text(
                              type.name,
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                color: AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ],
    );
  }

  // Expose submit method for external call
  void submit() {
    if (!_validate()) return;

    final dateStr =
        '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    widget.onSubmit(
      dateStr,
      timeStr,
      _nameController.text.trim(),
      _selectedAppointmentTypeId,
    );
  }
}

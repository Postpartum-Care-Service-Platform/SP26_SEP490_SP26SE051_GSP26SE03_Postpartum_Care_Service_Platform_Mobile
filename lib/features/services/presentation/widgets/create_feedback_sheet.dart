import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/amenity_ticket_entity.dart';
import '../../domain/entities/family_schedule_entity.dart';
import '../../domain/entities/feedback_type_entity.dart';
import '../bloc/amenity_bloc.dart';
import '../bloc/amenity_event.dart';
import '../bloc/amenity_state.dart';
import '../bloc/feedback_bloc.dart';
import '../bloc/feedback_event.dart';
import '../bloc/feedback_state.dart';
import '../bloc/family_schedule_bloc.dart';
import '../bloc/family_schedule_event.dart';
import '../bloc/family_schedule_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/data/models/current_account_model.dart';
import '../../../auth/domain/entities/staff_entity.dart';
import 'feedback_image_picker.dart';
import 'star_rating_widget.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_routes.dart';

/// Create Feedback Bottom Sheet
class CreateFeedbackSheet extends StatefulWidget {
  final List<FeedbackTypeEntity> feedbackTypes;
  final BuildContext parentContext;
  final FamilyScheduleEntity? initialSchedule;
  final AmenityTicketEntity? initialAmenityTicket;
  final DateTime? initialDate;

  const CreateFeedbackSheet({
    super.key,
    required this.feedbackTypes,
    required this.parentContext,
    this.initialSchedule,
    this.initialAmenityTicket,
    this.initialDate,
  });

  static void show(
    BuildContext context, {
    List<FeedbackTypeEntity>? feedbackTypes,
    FamilyScheduleEntity? initialSchedule,
    AmenityTicketEntity? initialAmenityTicket,
    DateTime? initialDate,
  }) {
    FeedbackBloc? feedbackBloc;
    try {
      feedbackBloc = context.read<FeedbackBloc>();
    } catch (_) {
      feedbackBloc = InjectionContainer.feedbackBloc;
      // If we create a new bloc, we must load types immediately
      feedbackBloc.add(const FeedbackTypesLoadRequested());
    }
    
    // Fallback: If feedbackTypes not provided, try to get from Bloc state or wait for load
    List<FeedbackTypeEntity> types = feedbackTypes ?? [];
    if (types.isEmpty) {
      final state = feedbackBloc.state;
      if (state is MyFeedbacksLoaded) {
        types = state.types;
      } else if (state is FeedbackTypesLoaded) {
        types = state.types;
      }
    }
    AuthBloc? authBloc;
    try { authBloc = context.read<AuthBloc>(); } catch (_) {}

    FamilyScheduleBloc? familyScheduleBloc;
    try { familyScheduleBloc = context.read<FamilyScheduleBloc>(); } catch (_) {}
    
    AmenityBloc? amenityBloc;
    try { amenityBloc = context.read<AmenityBloc>(); } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: feedbackBloc!),
          if (authBloc != null)
            BlocProvider.value(value: authBloc),
          if (familyScheduleBloc != null)
            BlocProvider.value(value: familyScheduleBloc),
          if (amenityBloc != null)
            BlocProvider.value(value: amenityBloc),
        ],
        child: CreateFeedbackSheet(
          feedbackTypes: types,
          parentContext: context,
          initialSchedule: initialSchedule,
          initialAmenityTicket: initialAmenityTicket,
          initialDate: initialDate,
        ),
      ),
    );
  }

  @override
  State<CreateFeedbackSheet> createState() => _CreateFeedbackSheetState();
}

class _CreateFeedbackSheetState extends State<CreateFeedbackSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  int? _selectedTypeId;
  int _rating = 0;
  List<String> _imagePaths = [];
  int? _familyScheduleId;
  FamilyScheduleEntity? _selectedSchedule;
  int? _amenityTicketId;
  String? _selectedStaffId;
  StaffEntity? _selectedStaff;
  DateTime? _selectedScheduleDate;
  late final bool _hasFamilyScheduleBloc;
  late final bool _hasAmenityBloc;

  FeedbackTypeEntity? get _selectedType {
    List<FeedbackTypeEntity> types = widget.feedbackTypes;
    if (types.isEmpty) {
      final state = _maybeRead<FeedbackBloc>()?.state;
      if (state is MyFeedbacksLoaded) {
        types = state.types;
      } else if (state is FeedbackTypesLoaded) {
        types = state.types;
      }
    }
    
    for (final type in types) {
      if (type.id == _selectedTypeId) return type;
    }
    return null;
  }

  bool get _requiresFamilyScheduleId {
    final name = _selectedType?.name.toLowerCase() ?? '';
    return name.contains('dịch vụ') || name.contains('service');
  }

  bool get _requiresAmenityTicketId {
    final name = _selectedType?.name.toLowerCase() ?? '';
    return name.contains('tiện ích') || name.contains('amenity');
  }

  bool get _requiresStaffId {
    final name = _selectedType?.name.toLowerCase() ?? '';
    return name.contains('nhân viên') || name.contains('staff');
  }

  bool get _isFormValid {
    if (_selectedTypeId == null) return false;
    if (_titleController.text.trim().isEmpty) return false;
    if (_contentController.text.trim().isEmpty) return false;
    if (_rating == 0) return false;
    if (_requiresFamilyScheduleId && _familyScheduleId == null) return false;
    if (_requiresAmenityTicketId && _amenityTicketId == null) return false;
    if (_requiresStaffId && _selectedStaffId == null) return false;
    return true;
  }

  void _autoSelectInitialType(List<FeedbackTypeEntity> types) {
    if (_selectedTypeId != null || types.isEmpty) return;
    
    if (widget.initialSchedule != null) {
      final serviceType = types.cast<FeedbackTypeEntity?>().firstWhere(
        (t) {
          final name = t?.name.toLowerCase() ?? '';
          return name.contains('dịch vụ') || name.contains('service');
        },
        orElse: () => null,
      );
      if (serviceType != null) {
        setState(() {
          _selectedTypeId = serviceType.id;
        });
      }
    } else if (widget.initialAmenityTicket != null) {
      final amenityType = types.cast<FeedbackTypeEntity?>().firstWhere(
        (t) {
          final name = t?.name.toLowerCase() ?? '';
          return name.contains('tiện ích') || name.contains('amenity');
        },
        orElse: () => null,
      );
      if (amenityType != null) {
        setState(() {
          _selectedTypeId = amenityType.id;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _hasFamilyScheduleBloc = _maybeRead<FamilyScheduleBloc>() != null;
    _hasAmenityBloc = _maybeRead<AmenityBloc>() != null;
    
    if (_hasAmenityBloc) {
      context.read<AmenityBloc>().add(const MyAmenityTicketsLoadRequested());
    }
    if (_hasFamilyScheduleBloc) {
      context.read<FamilyScheduleBloc>().add(const FamilyScheduleLoadRequested());
    }

    // Apply initial data
    if (widget.initialSchedule != null) {
      _selectedSchedule = widget.initialSchedule;
      _familyScheduleId = widget.initialSchedule!.id;
      _selectedScheduleDate = widget.initialDate ?? widget.initialSchedule!.workDate;
    } else if (widget.initialAmenityTicket != null) {
      _amenityTicketId = widget.initialAmenityTicket!.id;
    } else if (widget.initialDate != null) {
      _selectedScheduleDate = widget.initialDate;
    }

    _autoSelectInitialType(widget.feedbackTypes);

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  T? _maybeRead<T>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTextChanged);
    _contentController.removeListener(_onTextChanged);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduleDate() async {
    if (!_hasFamilyScheduleBloc) return;
    final familyScheduleBloc = context.read<FamilyScheduleBloc>();

    // Safely get stay dates from AuthBloc
    DateTime? checkinDate;
    DateTime? checkoutDate;
    final authBloc = _maybeRead<AuthBloc>();
    if (authBloc != null && authBloc.state is AuthCurrentAccountLoaded) {
      final nowPackage = (authBloc.state as AuthCurrentAccountLoaded).account.nowPackage;
      checkinDate = nowPackage?.checkinDate;
      checkoutDate = nowPackage?.checkoutDate;

      // Fallback to serviceDates if stay dates are missing
      if (checkinDate == null && nowPackage?.serviceDates.isNotEmpty == true) {
        checkinDate = nowPackage!.serviceDates.first.date;
      }
      if (checkoutDate == null && nowPackage?.serviceDates.isNotEmpty == true) {
        checkoutDate = nowPackage!.serviceDates.last.date;
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Use booking dates if available, otherwise fallback to today
    final firstDate = checkinDate ?? today;
    final lastDate = checkoutDate ?? today.add(const Duration(days: 365));

    // Ensure initial date is within range
    DateTime initialDate = _selectedScheduleDate ?? today;
    if (initialDate.isBefore(firstDate)) initialDate = firstDate;
    if (initialDate.isAfter(lastDate)) initialDate = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('vi', 'VN'),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedScheduleDate = picked;
      _familyScheduleId = null;
      _selectedSchedule = null;
    });

    final pickedKey =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    familyScheduleBloc.add(
      FamilyScheduleLoadByDateRequested(pickedKey),
    );
  }

  void _showSchedulePickerDrawer(List<FamilyScheduleEntity> schedules, double scale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppDrawerForm(
        title: 'Chọn hoạt động',
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schedules.length,
            separatorBuilder: (context, index) => SizedBox(height: 8 * scale),
            itemBuilder: (context, index) {
              final schedule = schedules[index];
              final isSelected = _familyScheduleId == schedule.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _familyScheduleId = schedule.id;
                    _selectedSchedule = schedule;
                  });
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(12 * scale),
                child: Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1,
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
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                        child: Text(
                          schedule.timeRange,
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              schedule.activity,
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (schedule.status.isNotEmpty)
                              Text(
                                schedule.status,
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  color: schedule.isCompleted
                                      ? AppColors.verified
                                      : AppColors.primary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24 * scale),
        ],
      ),
    );
  }

  void _showAmenityTicketPickerDrawer(List<AmenityTicketEntity> tickets, double scale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppDrawerForm(
        title: 'Chọn AmenityTicket',
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tickets.length,
            separatorBuilder: (context, index) => SizedBox(height: 8 * scale),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final isSelected = _amenityTicketId == ticket.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _amenityTicketId = ticket.id;
                  });
                  Navigator.of(context).pop();
                },
                borderRadius: BorderRadius.circular(12 * scale),
                child: Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1,
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
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(6 * scale),
                        ),
                        child: Text(
                          '#${ticket.id}',
                          style: AppTextStyles.arimo(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.amenityServiceName ?? 'Amenity',
                              style: AppTextStyles.arimo(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2 * scale),
                            Text(
                              '${ticket.startTime.day.toString().padLeft(2, '0')}/${ticket.startTime.month.toString().padLeft(2, '0')}/${ticket.startTime.year} • ${ticket.timeRange}',
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24 * scale),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTypeId == null) {
      AppToast.showError(context, message: 'Vui lòng chọn loại feedback');
      return;
    }
    if (_rating == 0) {
      AppToast.showError(context, message: 'Vui lòng đánh giá sao');
      return;
    }
    if (_requiresFamilyScheduleId && _familyScheduleId == null) {
      AppToast.showError(context, message: 'Vui lòng chọn lịch hợp lệ');
      return;
    }
    if (_requiresAmenityTicketId && _amenityTicketId == null) {
      AppToast.showError(context, message: 'Vui lòng chọn AmenityTicket hoàn thành');
      return;
    }
    if (_requiresStaffId && _selectedStaffId == null) {
      AppToast.showError(context, message: 'Vui lòng chọn nhân viên');
      return;
    }

    AppLoading.show(widget.parentContext, message: AppStrings.processing);
    context.read<FeedbackBloc>().add(
          FeedbackCreateRequested(
            feedbackTypeId: _selectedTypeId!,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            rating: _rating,
            imagePaths: _imagePaths,
            familyScheduleId: _familyScheduleId,
            staffId: _selectedStaffId,
            amenityTicketId: _amenityTicketId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocListener<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        final parentContext = widget.parentContext;

        if (state is MyFeedbacksLoaded) {
          _autoSelectInitialType(state.types);
        } else if (state is FeedbackTypesLoaded) {
          _autoSelectInitialType(state.types);
        }

        if (state is FeedbackCreated) {
          Navigator.of(context).pop();
          AppLoading.hide(parentContext);
          AppToast.showSuccess(
            parentContext,
            message: AppStrings.feedbackSubmitSuccess,
          );
        } else if (state is FeedbackError) {
          AppLoading.hide(parentContext);
          AppToast.showError(parentContext, message: state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: AppDrawerForm(
          title: 'Viết feedback',
          onSave: _handleSubmit,
          isDisabled: !_isFormValid,
          saveButtonIcon: Icons.check_rounded,
          children: [
          Text(
            'Loại feedback',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8 * scale),
          BlocBuilder<FeedbackBloc, FeedbackState>(
            builder: (context, state) {
              final types = (state is MyFeedbacksLoaded)
                  ? state.types
                  : (state is FeedbackTypesLoaded)
                      ? state.types
                      : widget.feedbackTypes;
              if (types.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return Column(
                children: types.where((t) => t.isActive).map((type) {
                  final isSelected = _selectedTypeId == type.id;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8 * scale),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTypeId = type.id;
                          _familyScheduleId = null;
                          _selectedSchedule = null;
                          _amenityTicketId = null;

                          // Auto-fetch today's schedule if Service type is selected
                          if (_requiresFamilyScheduleId &&
                              _selectedScheduleDate == null &&
                              _hasFamilyScheduleBloc) {
                            final now = DateTime.now();
                            _selectedScheduleDate = now;
                            final pickedKey =
                                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
                                context.read<FamilyScheduleBloc>().add(
                                      FamilyScheduleLoadByDateRequested(pickedKey),
                                    );
                              }

                              // Auto-fetch staff if Staff type is selected
                              if (_requiresStaffId) {
                                context.read<FeedbackBloc>().add(
                                      const FeedbackCurrentBookingStaffLoadRequested(),
                                    );
                              }
                            });
                          },
                      borderRadius: BorderRadius.circular(10 * scale),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale,
                          vertical: 10 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(10 * scale),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            RadioGroup<int>(
                              groupValue: _selectedTypeId,
                              onChanged: (value) => setState(() {
                                _selectedTypeId = value;
                                _familyScheduleId = null;
                                _selectedSchedule = null;
                                _amenityTicketId = null;
                                _selectedStaffId = null;
                                _selectedStaff = null;
                              }),
                              child: Radio<int>(
                                value: type.id,
                                activeColor: AppColors.primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            SizedBox(width: 6 * scale),
                            Expanded(
                              child: Text(
                                type.name,
                                style: AppTextStyles.arimo(
                                  fontSize: 14 * scale,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          if (_requiresFamilyScheduleId && _hasFamilyScheduleBloc) ...[
            SizedBox(height: 12 * scale),
            Text(
              'Chọn ngày hợp lệ',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8 * scale),
            GestureDetector(
              onTap: _pickScheduleDate,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 16 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16 * scale),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedScheduleDate == null
                            ? 'Chọn ngày'
                            : '${_selectedScheduleDate!.day}/${_selectedScheduleDate!.month}/${_selectedScheduleDate!.year}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            BlocBuilder<FamilyScheduleBloc, FamilyScheduleState>(
              builder: (context, state) {
                if (state is FamilyScheduleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is! FamilyScheduleLoaded || state.schedules.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Không có lịch dịch vụ phù hợp',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);
                final selectedDate = _selectedScheduleDate != null
                    ? DateTime(_selectedScheduleDate!.year,
                        _selectedScheduleDate!.month, _selectedScheduleDate!.day)
                    : today;

                final schedules = state.schedules.where((schedule) {
                  // If selected date is in the past, show all
                  if (selectedDate.isBefore(today)) return true;

                  // If selected date is today, only show activities that have started
                  if (selectedDate.isAtSameMomentAs(today)) {
                    try {
                      // Always show if it's already done or staff-marked done
                      if (schedule.isCompleted || schedule.isStaffDone) {
                        return true;
                      }

                      final timeParts = schedule.startTime.split(':');
                      final scheduleHour = int.parse(timeParts[0]);
                      final scheduleMinute = int.parse(timeParts[1]);

                      if (scheduleHour < now.hour) return true;
                      if (scheduleHour == now.hour &&
                          scheduleMinute <= now.minute) return true;
                      return false;
                    } catch (_) {
                      return true;
                    }
                  }

                  // If selected date is in the future, hide all
                  return false;
                }).toList();

                if (schedules.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Không có lịch dịch vụ hợp lệ để feedback',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedSchedule != null) ...[
                      SizedBox(height: 8 * scale),
                      Text(
                        'Hoạt động đã chọn',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Container(
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8 * scale,
                                vertical: 4 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(6 * scale),
                              ),
                              child: Text(
                                _selectedSchedule!.timeRange,
                                style: AppTextStyles.arimo(
                                  fontSize: 12 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: Text(
                                _selectedSchedule!.activity,
                                style: AppTextStyles.arimo(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  _showSchedulePickerDrawer(schedules, scale),
                              child: const Text('Thay đổi'),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      SizedBox(height: 8 * scale),
                      GestureDetector(
                        onTap: () => _showSchedulePickerDrawer(schedules, scale),
                        child: Container(
                          padding: EdgeInsets.all(16 * scale),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16 * scale),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.list_alt,
                                  color: AppColors.textSecondary),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: Text(
                                  'Chọn hoạt động cần feedback',
                                  style: AppTextStyles.arimo(
                                    fontSize: 14 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
          if (_requiresAmenityTicketId && _hasAmenityBloc) ...[
            SizedBox(height: 12 * scale),
            Text(
              'Chọn AmenityTicket hoàn thành',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8 * scale),
            BlocBuilder<AmenityBloc, AmenityState>(
              builder: (context, state) {
                if (state is AmenityLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tickets = state is AmenityLoaded
                    ? state.tickets.where((ticket) => ticket.isCompleted).toList()
                    : <AmenityTicketEntity>[];

                if (tickets.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Không có AmenityTicket hoàn thành',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () => _showAmenityTicketPickerDrawer(tickets, scale),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.receipt_long, color: AppColors.textSecondary),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Text(
                            _amenityTicketId == null
                                ? 'Chọn ticket hoàn thành'
                                : (() {
                                    final selectedTicket = tickets.firstWhere(
                                        (t) => t.id == _amenityTicketId,
                                        orElse: () => tickets.first);
                                    return '#${selectedTicket.id} - ${selectedTicket.amenityServiceName ?? 'Amenity'}';
                                  })(),
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              color: _amenityTicketId == null
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
          if (_requiresStaffId) ...[
            SizedBox(height: 12 * scale),
            Text(
              'Chọn nhân viên',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8 * scale),
            BlocBuilder<FeedbackBloc, FeedbackState>(
              builder: (context, state) {
                List<StaffEntity> staffs = [];
                bool isLoading = false;

                if (state is FeedbackLoading) {
                  isLoading = true;
                } else if (state is FeedbackCurrentBookingStaffLoaded) {
                  staffs = state.staffs;
                }

                if (isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (staffs.isEmpty && state is! FeedbackLoading) {
                  return Container(
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Không tìm thấy nhân viên phụ trách',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return Column(
                  children: staffs.map((staff) {
                    final isSelected = _selectedStaffId == staff.id;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8 * scale),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedStaffId = staff.id;
                            _selectedStaff = staff;
                          });
                        },
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: Container(
                          padding: EdgeInsets.all(12 * scale),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.05)
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderLight,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20 * scale,
                                backgroundImage: staff.avatarUrl != null
                                    ? NetworkImage(staff.avatarUrl!)
                                    : null,
                                child: staff.avatarUrl == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              SizedBox(width: 12 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      staff.fullName,
                                      style: AppTextStyles.arimo(
                                        fontSize: 14 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (staff.email != null)
                                      Text(
                                        staff.email!,
                                        style: AppTextStyles.arimo(
                                          fontSize: 12 * scale,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle,
                                    color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
          SizedBox(height: 16 * scale),
          AppWidgets.textInput(
            label: 'Tiêu đề',
            placeholder: 'Nhập tiêu đề feedback',
            controller: _titleController,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập tiêu đề'
                : null,
          ),
          SizedBox(height: 16 * scale),
          AppWidgets.textInput(
            label: 'Nội dung',
            placeholder: 'Nhập nội dung feedback',
            controller: _contentController,
            maxLines: 5,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập nội dung'
                : null,
          ),
          SizedBox(height: 16 * scale),
          Text(
            'Đánh giá',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12 * scale),
          Center(
            child: StarRatingWidget(
              initialRating: _rating,
              onRatingChanged: (rating) => setState(() => _rating = rating),
              starSize: 40,
              interactive: true,
            ),
          ),
          SizedBox(height: 16 * scale),
          Text(
            'Ảnh đính kèm (tùy chọn)',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12 * scale),
          FeedbackImagePicker(
            imagePaths: _imagePaths,
            onImagesChanged: (paths) => setState(() => _imagePaths = paths),
          ),
        ],
      ),
    ),
  );
}
}

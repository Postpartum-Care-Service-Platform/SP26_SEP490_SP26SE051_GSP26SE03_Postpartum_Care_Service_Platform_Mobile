import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_drawer_form.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/amenity_ticket_entity.dart';
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
import 'feedback_image_picker.dart';
import 'star_rating_widget.dart';

/// Create Feedback Bottom Sheet
class CreateFeedbackSheet extends StatefulWidget {
  final List<FeedbackTypeEntity> feedbackTypes;
  final BuildContext parentContext;

  const CreateFeedbackSheet({
    super.key,
    required this.feedbackTypes,
    required this.parentContext,
  });

  static void show(BuildContext context, List<FeedbackTypeEntity> feedbackTypes) {
    final feedbackBloc = context.read<FeedbackBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => BlocProvider.value(
        value: feedbackBloc,
        child: CreateFeedbackSheet(
          feedbackTypes: feedbackTypes,
          parentContext: context,
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
  int? _amenityTicketId;
  DateTime? _selectedScheduleDate;
  late final bool _hasFamilyScheduleBloc;
  late final bool _hasAmenityBloc;

  FeedbackTypeEntity? get _selectedType {
    for (final type in widget.feedbackTypes) {
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
  }

  T? _maybeRead<T>() {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduleDate() async {
    if (!_hasFamilyScheduleBloc) return;
    final familyScheduleBloc = context.read<FamilyScheduleBloc>();

    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = now.add(const Duration(days: 365));

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedScheduleDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('vi', 'VN'),
    );

    if (!mounted || picked == null) return;

    setState(() {
      _selectedScheduleDate = picked;
      _familyScheduleId = null;
    });

    final pickedKey =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    familyScheduleBloc.add(
      FamilyScheduleLoadByDateRequested(pickedKey),
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

    AppLoading.show(widget.parentContext, message: AppStrings.processing);
    context.read<FeedbackBloc>().add(
          FeedbackCreateRequested(
            feedbackTypeId: _selectedTypeId!,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            rating: _rating,
            imagePaths: _imagePaths,
            familyScheduleId: _familyScheduleId,
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
      child: AppDrawerForm(
        title: 'Viết feedback',
        onSave: _handleSubmit,
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
          ...widget.feedbackTypes.where((t) => t.isActive).map((type) {
            final isSelected = _selectedTypeId == type.id;
            return Padding(
              padding: EdgeInsets.only(bottom: 8 * scale),
              child: InkWell(
                onTap: () => setState(() {
                  _selectedTypeId = type.id;
                  _familyScheduleId = null;
                  _amenityTicketId = null;
                }),
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
                          _amenityTicketId = null;
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
          }),
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

                final completedSchedules = state.schedules
                    .where((schedule) =>
                        schedule.isCompleted || schedule.isStaffDone)
                    .toList();

                if (completedSchedules.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Text(
                      'Không có FamilySchedule hoàn thành',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                }

                return DropdownButtonFormField<int>(
                  key: ValueKey(_selectedScheduleDate?.toIso8601String() ?? 'all'),
                  initialValue: _familyScheduleId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12 * scale,
                      vertical: 14 * scale,
                    ),
                  ),
                  hint: const Text('Chọn FamilySchedule hoàn thành'),
                  items: completedSchedules.map<DropdownMenuItem<int>>((schedule) {
                    return DropdownMenuItem<int>(
                      value: schedule.id,
                      child: Text(
                        '${schedule.activity} - ${schedule.timeRange}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _familyScheduleId = value),
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

                return DropdownButtonFormField<int>(
                  initialValue: _amenityTicketId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12 * scale,
                      vertical: 14 * scale,
                    ),
                  ),
                  hint: const Text('Chọn ticket hoàn thành'),
                  items: tickets.map((ticket) {
                    return DropdownMenuItem<int>(
                      value: ticket.id,
                      child: Text(
                        '#${ticket.id} - ${ticket.amenityServiceName ?? 'Amenity'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _amenityTicketId = value),
                );
              },
            ),
          ],
          SizedBox(height: 16 * scale),
          Text(
            'Tiêu đề',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8 * scale),
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập tiêu đề'
                : null,
          ),
          SizedBox(height: 16 * scale),
          Text(
            'Nội dung',
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8 * scale),
          TextFormField(
            controller: _contentController,
            maxLines: 5,
            decoration: const InputDecoration(border: OutlineInputBorder()),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/feedback_type_entity.dart';
import '../bloc/feedback_bloc.dart';
import '../bloc/feedback_event.dart';
import '../bloc/feedback_state.dart';
import 'star_rating_widget.dart';
import 'feedback_image_picker.dart';

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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedTypeId == null) {
      AppToast.showError(
        context,
        message: 'Vui lòng chọn loại feedback',
      );
      return;
    }

    if (_rating == 0) {
      AppToast.showError(
        context,
        message: 'Vui lòng đánh giá sao',
      );
      return;
    }

    // Use parent context to show full screen loading (has Overlay)
    AppLoading.show(widget.parentContext, message: AppStrings.processing);

    context.read<FeedbackBloc>().add(
          FeedbackCreateRequested(
            feedbackTypeId: _selectedTypeId!,
            title: _titleController.text.trim(),
            content: _contentController.text.trim(),
            rating: _rating,
            imagePaths: _imagePaths,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocListener<FeedbackBloc, FeedbackState>(
      listener: (context, state) {
        // Use parent context for loading overlay and toast
        final parentContext = widget.parentContext;
        
        if (state is FeedbackCreated) {
          // Close bottom sheet
          Navigator.of(context).pop();
          // Show success message
          // Note: Loading will be hidden in FeedbackScreen when MyFeedbacksLoaded
          AppToast.showSuccess(
            parentContext,
            message: AppStrings.feedbackSubmitSuccess,
          );
        } else if (state is FeedbackError) {
          // Hide loading on error
          AppLoading.hide(parentContext);
          // Show error message
          AppToast.showError(
            parentContext,
            message: state.message,
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24 * scale),
            topRight: Radius.circular(24 * scale),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12 * scale),
                  width: 40 * scale,
                  height: 4 * scale,
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2 * scale),
                  ),
                ),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Viết feedback',
                          style: AppTextStyles.tinos(
                            fontSize: 24 * scale,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 24 * scale,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16 * scale),
                // Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                      children: [
                        // Feedback type radio buttons
                        Text(
                          'Loại feedback',
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        ...widget.feedbackTypes
                            .where((type) => type.isActive)
                            .map((type) {
                          final isSelected = _selectedTypeId == type.id;
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8 * scale),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedTypeId = type.id;
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
                                    Radio<int>(
                                      value: type.id,
                                      groupValue: _selectedTypeId,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTypeId = value;
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
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
                        SizedBox(height: 20 * scale),
                        // Title
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
                          decoration: InputDecoration(
                            hintText: 'Nhập tiêu đề feedback',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                              borderSide: BorderSide(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                              borderSide: BorderSide(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập tiêu đề';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20 * scale),
                        // Content
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
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Nhập nội dung feedback',
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                              borderSide: BorderSide(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                              borderSide: BorderSide(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Vui lòng nhập nội dung';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20 * scale),
                        // Rating
                        Text(
                          'Đánh giá',
                          style: AppTextStyles.arimo(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        // Center the star rating
                        Center(
                          child: StarRatingWidget(
                            initialRating: _rating,
                            onRatingChanged: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                            starSize: 40,
                            interactive: true,
                          ),
                        ),
                        if (_rating > 0) ...[
                          SizedBox(height: 8 * scale),
                          Center(
                            child: Text(
                              '$_rating / 5 sao',
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 20 * scale),
                        // Images
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
                          onImagesChanged: (paths) {
                            setState(() {
                              _imagePaths = paths;
                            });
                          },
                        ),
                        SizedBox(height: 32 * scale),
                        // Submit button
                        BlocBuilder<FeedbackBloc, FeedbackState>(
                          builder: (context, state) {
                            final isLoading = state is FeedbackLoading;
                            return AppWidgets.primaryButton(
                              text: 'Gửi feedback',
                              onPressed: isLoading ? () {} : _handleSubmit,
                              isEnabled: !isLoading,
                            );
                          },
                        ),
                        SizedBox(height: 32 * scale),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

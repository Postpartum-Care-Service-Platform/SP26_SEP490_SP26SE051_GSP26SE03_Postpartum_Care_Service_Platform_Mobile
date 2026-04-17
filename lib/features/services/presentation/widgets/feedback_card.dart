import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../domain/entities/feedback_entity.dart';
import '../../domain/entities/feedback_type_entity.dart';
import 'star_rating_widget.dart';

/// Feedback Card Widget
/// Displays a single feedback item
class FeedbackCard extends StatelessWidget {
  final FeedbackEntity feedback;
  final FeedbackTypeEntity? feedbackType;

  const FeedbackCard({
    super.key,
    required this.feedback,
    this.feedbackType,
  });

  Widget _buildSmartHeader(double scale) {
    IconData? icon;
    String? targetText;

    if (feedback.feedbackTypeId == 3 && (feedback.familyScheduleInfo != null || feedback.familyScheduleId != null)) {
      icon = Icons.design_services_rounded;
      final info = feedback.familyScheduleInfo;
      if (info != null) {
        final timeParts = <String>[];
        if (info.workDate != null && info.workDate!.isNotEmpty) timeParts.add(info.workDate!);
        if (info.startTime != null && info.endTime != null) timeParts.add('${info.startTime} - ${info.endTime}');
        final timeStr = timeParts.join(' ');
        targetText = '${info.activity ?? ""}${timeStr.isNotEmpty ? ' ($timeStr)' : ''}';
      } else {
        targetText = feedback.familyScheduleId?.toString();
      }
    } else if (feedback.feedbackTypeId == 4 && (feedback.staffInfo != null || feedback.staffName != null)) {
      icon = Icons.support_agent_rounded;
      final info = feedback.staffInfo;
      if (info != null) {
        final extra = (info.phone?.isNotEmpty == true) ? info.phone : info.email;
        targetText = '${info.fullName ?? ""}${extra != null && extra.isNotEmpty ? ' ($extra)' : ''}';
      } else {
        targetText = feedback.staffName;
      }
    } else if (feedback.feedbackTypeId == 5 && (feedback.amenityTicketInfo != null || feedback.amenityServiceName != null)) {
      icon = Icons.spa_rounded;
      final info = feedback.amenityTicketInfo;
      if (info != null) {
        final timeParts = <String>[];
        if (info.date != null && info.date!.isNotEmpty) timeParts.add(info.date!);
        if (info.startTime != null && info.endTime != null) timeParts.add('${info.startTime} - ${info.endTime}');
        final timeStr = timeParts.join(' ');
        targetText = '${info.amenityServiceName ?? ""}${timeStr.isNotEmpty ? ' ($timeStr)' : ''}';
      } else {
        targetText = feedback.amenityServiceName;
      }
    }

    final typeName = feedbackType?.name ?? feedback.feedbackTypeName ?? '';
    final hasTarget = targetText != null && targetText.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Neat category badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 6 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8 * scale),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14 * scale, color: AppColors.primary),
                      SizedBox(width: 6 * scale),
                    ],
                    Flexible(
                      child: Text(
                        typeName,
                        style: AppTextStyles.arimo(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasTarget) ...[
                SizedBox(height: 8 * scale),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 2 * scale),
                      child: Icon(Icons.subdirectory_arrow_right_rounded, size: 14 * scale, color: AppColors.primary.withValues(alpha: 0.6)),
                    ),
                    SizedBox(width: 6 * scale),
                    Expanded(
                      child: Text(
                        targetText!,
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                        ).copyWith(height: 1.45),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 12 * scale),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StarRatingWidget(
              initialRating: feedback.rating,
              onRatingChanged: (_) {},
              starSize: 14 * scale,
              interactive: false,
            ),
            SizedBox(height: 6 * scale),
            Text(
              feedback.formattedDate,
              style: AppTextStyles.arimo(
                fontSize: 11 * scale,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<TextSpan> _buildContentSpans(String content, double scale) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*', dotAll: true);

    int currentIndex = 0;
    for (final match in boldPattern.allMatches(content)) {
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: content.substring(currentIndex, match.start)));
      }

      final boldText = match.group(1);
      if (boldText != null && boldText.isNotEmpty) {
        spans.add(
          TextSpan(
            text: boldText,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }

      currentIndex = match.end;
    }

    if (currentIndex < content.length) {
      spans.add(TextSpan(text: content.substring(currentIndex)));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: content));
    }

    return spans;
  }

  void _openImageViewer(BuildContext context, int initialIndex) {
    final pageController = PageController(initialPage: initialIndex);

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black.withValues(alpha: 0.96),
          child: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: feedback.images.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          feedback.images[index],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.white,
                            size: 52,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.white,
                    tooltip: 'Đóng',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 16 * scale),
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24 * scale,
            offset: Offset(0, 8 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSmartHeader(scale),
          SizedBox(height: 16 * scale),
          // Title
          Text(
            feedback.title,
            style: AppTextStyles.tinos(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8 * scale),
          // Content - supports line breaks and markdown-style bold: **text**
          RichText(
            text: TextSpan(
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textPrimary.withValues(alpha: 0.85),
              ).copyWith(height: 1.55),
              children: _buildContentSpans(feedback.content, scale),
            ),
          ),
          // Images
          if (feedback.hasImages) ...[
            SizedBox(height: 16 * scale),
            SizedBox(
              height: 120 * scale,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: feedback.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(context, index),
                    child: Container(
                      width: 120 * scale,
                      height: 120 * scale,
                      margin: EdgeInsets.only(right: 8 * scale),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12 * scale),
                        child: Image.network(
                          feedback.images[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.background,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.background,
                            child: Icon(
                              Icons.error_outline,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

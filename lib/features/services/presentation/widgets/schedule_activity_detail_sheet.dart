import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_date_time_utils.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../bloc/family_schedule_bloc.dart';
import '../bloc/family_schedule_event.dart';
import '../../domain/entities/family_schedule_entity.dart';
import '../../domain/entities/staff_schedule_entity.dart';
import 'create_feedback_sheet.dart';

/// Schedule Activity Detail Bottom Sheet
/// Displays activity, staff and note information with user-friendly layout.
class ScheduleActivityDetailSheet extends StatelessWidget {
  final FamilyScheduleEntity schedule;

  const ScheduleActivityDetailSheet({
    super.key,
    required this.schedule,
  });

  static void show(BuildContext context, FamilyScheduleEntity schedule) {
    FamilyScheduleBloc? bloc;
    try {
      bloc = context.read<FamilyScheduleBloc>();
    } catch (_) {
      // Ignore if not found
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        Widget sheet = ScheduleActivityDetailSheet(schedule: schedule);
        if (bloc != null) {
          sheet = BlocProvider.value(
            value: bloc,
            child: sheet,
          );
        }
        return sheet;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24 * scale),
          topRight: Radius.circular(24 * scale),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(
              16 * scale,
              8 * scale,
              16 * scale,
              20 * scale,
            ),
            children: [
              _buildHandle(scale),
              SizedBox(height: 6 * scale),
              _buildHeader(context, scale),
              SizedBox(height: 10 * scale),
              _buildMetaSummary(scale),
              SizedBox(height: 14 * scale),
              if (schedule.description?.trim().isNotEmpty ?? false) ...[
                _buildSectionTitle(
                  title: 'Mô tả công việc',
                  icon: Icons.article_outlined,
                  scale: scale,
                ),
                SizedBox(height: 8 * scale),
                _buildDescriptionCard(schedule.description!.trim(), scale),
                SizedBox(height: 14 * scale),
              ],
              _buildSectionTitle(
                title: AppStrings.scheduleStaffAssigned,
                icon: Icons.groups_2_outlined,
                scale: scale,
              ),
              SizedBox(height: 8 * scale),
              _buildStaffSection(scale),
              SizedBox(height: 14 * scale),
              _buildSectionTitle(
                title: AppStrings.scheduleNote,
                icon: Icons.sticky_note_2_outlined,
                scale: scale,
              ),
              SizedBox(height: 8 * scale),
              _buildNoteSection(context, scale),
              if (_isStaffDone) ...[
                SizedBox(height: 24 * scale),
                AppWidgets.primaryButton(
                  text: 'Xác nhận hoàn thành',
                  onPressed: () => _showConfirmDialog(context, scale),
                  width: double.infinity,
                ),
              ],
              if (schedule.isCompleted || _isStaffDone) ...[
                SizedBox(height: 12 * scale),
                AppWidgets.secondaryButton(
                  text: 'Viết feedback',
                  onPressed: () => CreateFeedbackSheet.show(
                    context,
                    initialSchedule: schedule,
                  ),
                  width: double.infinity,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildHandle(double scale) {
    return Center(
      child: Container(
        width: 46 * scale,
        height: 5 * scale,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (schedule.title?.trim().isNotEmpty ?? false)
                    ? schedule.title!.trim()
                    : schedule.activity,
                style: AppTextStyles.tinos(
                  fontSize: 22 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8 * scale),
              Wrap(
                spacing: 8 * scale,
                runSpacing: 6 * scale,
                children: [
                  _buildHeaderChip(
                    icon: Icons.access_time_rounded,
                    text: schedule.timeRange,
                    textColor: AppColors.primary,
                    bgColor: AppColors.primary.withValues(alpha: 0.14),
                    scale: scale,
                  ),
                  _buildHeaderChip(
                    icon: Icons.flag_outlined,
                    text: _statusText,
                    textColor: _statusColor,
                    bgColor: _statusColor.withValues(alpha: 0.12),
                    scale: scale,
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            size: 24 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showConfirmDialog(BuildContext context, double scale) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Xác nhận hoàn thành',
          style: AppTextStyles.tinos(
            fontSize: 20 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Bạn có chắc chắn xác nhận nhân viên đã hoàn thành công việc này không?',
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            color: AppColors.textPrimary,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16 * scale),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Hủy',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet
              context.read<FamilyScheduleBloc>().add(
                    FamilyScheduleConfirmDoneRequested(schedule.id),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8 * scale),
              ),
            ),
            child: Text(
              'Xác nhận',
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openImageViewer(BuildContext context, List<String> images, int initialIndex) {
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
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          images[index],
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

  Widget _buildMetaSummary(double scale) {
    final items = <_MetaItem>[
      _MetaItem(
        icon: Icons.track_changes_outlined,
        label: 'Đối tượng',
        value: _targetText,
      ),

      _MetaItem(
        icon: Icons.calendar_today_outlined,
        label: AppStrings.scheduleDay,
        value: 'Ngày ${schedule.dayNo}',
      ),
      if (schedule.amenityServiceName?.trim().isNotEmpty ?? false)
        _MetaItem(
          icon: Icons.miscellaneous_services_outlined,
          label: 'Tiện ích',
          value: schedule.amenityServiceName!.trim(),
        ),
      if (schedule.roomName?.trim().isNotEmpty ?? false)
        _MetaItem(
          icon: Icons.meeting_room_outlined,
          label: 'Phòng',
          value: schedule.roomName!.trim(),
        ),
    ];

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(vertical: 6 * scale),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 16 * scale,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      '${item.label}: ',
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        style: AppTextStyles.arimo(
                          fontSize: 13 * scale,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildHeaderChip({
    required IconData icon,
    required String text,
    required Color textColor,
    required Color bgColor,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 5 * scale,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13 * scale, color: textColor),
          SizedBox(width: 5 * scale),
          Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required IconData icon,
    required double scale,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20 * scale, color: AppColors.primary),
        SizedBox(width: 8 * scale),
        Text(
          title,
          style: AppTextStyles.tinos(
            fontSize: 18 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStaffSection(double scale) {
    if (!schedule.hasStaff) {
      return _buildEmptyCard(
        icon: Icons.group_off_outlined,
        message: AppStrings.scheduleNoStaffAssigned,
        scale: scale,
      );
    }

    return Column(
      children: schedule.staffSchedules
          .map((staff) => _buildStaffCard(staff, scale))
          .toList(),
    );
  }

  Widget _buildStaffCard(StaffScheduleEntity staff, double scale) {
    final statusColor = staff.isChecked
        ? AppColors.verified
        : AppColors.textSecondary.withValues(alpha: 0.8);

    return Container(
      margin: EdgeInsets.only(bottom: 10 * scale),
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: staff.isChecked
              ? AppColors.verified.withValues(alpha: 0.35)
              : AppColors.textSecondary.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 6 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18 * scale,
                backgroundColor: AppColors.borderLight,
                backgroundImage:
                    staff.staffAvatar != null ? NetworkImage(staff.staffAvatar!) : null,
                child: staff.staffAvatar == null
                    ? Icon(
                        Icons.person,
                        size: 18 * scale,
                        color: AppColors.textSecondary,
                      )
                    : null,
              ),
              SizedBox(width: 10 * scale),
              Expanded(
                child: Text(
                  staff.staffName ?? AppStrings.scheduleStaff,
                  style: AppTextStyles.arimo(
                    fontSize: 15 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  staff.isChecked
                      ? AppStrings.scheduleCompleted
                      : AppStrings.scheduleNotCompleted,
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          if (staff.managerName != null)
            _buildInfoRow(
              icon: Icons.supervisor_account_outlined,
              text: '${AppStrings.scheduleManager}: ${staff.managerName}',
              scale: scale,
            ),
          if (staff.checkedAt != null)
            _buildInfoRow(
              icon: Icons.history_toggle_off,
              text:
                  '${AppStrings.scheduleCompletedAt}: ${_formatDateTime(staff.checkedAt!)}',
              scale: scale,
            ),
          if (staff.staffName == null)
            _buildInfoRow(
              icon: Icons.badge_outlined,
              text: 'ID: ${staff.staffId.substring(0, 8)}...',
              scale: scale,
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textPrimary,
              ).copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context, double scale) {
    final note = schedule.note?.trim() ?? '';
    final allImages = schedule.staffSchedules.expand((s) => s.images).toList();

    if (note.isEmpty && allImages.isEmpty) {
      return _buildEmptyCard(
        icon: Icons.note_alt_outlined,
        message: AppStrings.scheduleNoNote,
        scale: scale,
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: AppColors.textSecondary.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (note.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      color: AppColors.textPrimary,
                    ).copyWith(height: 1.45),
                  ),
                ),
              ],
            ),
          if (allImages.isNotEmpty) ...[
            if (note.isNotEmpty) SizedBox(height: 16 * scale),
            SizedBox(
              height: 90 * scale,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allImages.length,
                separatorBuilder: (context, index) => SizedBox(width: 8 * scale),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openImageViewer(context, allImages, index),
                    child: Container(
                      width: 90 * scale,
                      height: 90 * scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8 * scale),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8 * scale),
                        child: Image.network(
                          allImages[index],
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

  Widget _buildEmptyCard({
    required IconData icon,
    required String message,
    required double scale,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20 * scale, horizontal: 12 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 24 * scale,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required double scale,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 6 * scale),
      child: Row(
        children: [
          Icon(icon, size: 14 * scale, color: AppColors.textSecondary),
          SizedBox(width: 6 * scale),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.arimo(
                fontSize: 12 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _targetText {
    if (schedule.isForBoth) return 'Mẹ và bé';
    if (schedule.isForMom) return 'Mẹ';
    if (schedule.isForBaby) return 'Bé';
    return schedule.target;
  }

  Color get _statusColor {
    if (schedule.isCompleted || _isStaffDone) return AppColors.verified;
    if (schedule.isMissed) return AppColors.scheduleMissed;
    if (schedule.isCancelled) return AppColors.scheduleCancelled;
    return AppColors.textSecondary;
  }

  String get _statusText {
    if (schedule.isCompleted) return AppStrings.scheduleCompleted;
    if (_isStaffDone) return 'Nhân viên đã Check';
    if (schedule.isMissed) return AppStrings.scheduleMissed;
    if (schedule.isCancelled) return AppStrings.scheduleCancelled;

    final raw = schedule.status.trim().toLowerCase();
    if (raw == 'scheduled') return 'Đã lên lịch';
    return schedule.status;
  }

  bool get _isStaffDone => schedule.status.trim().toLowerCase() == 'staffdone';

  String _formatDateTime(DateTime dateTime) {
    return AppDateTimeUtils.formatVietnamDateTime(dateTime);
  }
}

class _MetaItem {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

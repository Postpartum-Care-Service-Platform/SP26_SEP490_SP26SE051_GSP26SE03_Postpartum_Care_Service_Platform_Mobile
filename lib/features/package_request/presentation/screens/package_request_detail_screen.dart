import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/package_request_entity.dart';
import '../bloc/package_request_bloc.dart';
import '../bloc/package_request_event.dart';
import '../bloc/package_request_state.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/avatar_widget.dart';
import '../../../package/domain/entities/package_entity.dart';
import '../../../care_plan/domain/entities/care_plan_entity.dart';

class PackageRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const PackageRequestDetailScreen({super.key, required this.requestId});

  @override
  State<PackageRequestDetailScreen> createState() =>
      _PackageRequestDetailScreenState();
}

class _PackageRequestDetailScreenState
    extends State<PackageRequestDetailScreen> {
  int _currentDayNo = 0;
  List<int> _availableDays = [];
  @override
  void initState() {
    super.initState();
    context
        .read<PackageRequestBloc>()
        .add(LoadPackageRequestDetail(widget.requestId));
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Chi tiết yêu cầu',
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
      ),
      body: BlocConsumer<PackageRequestBloc, PackageRequestState>(
        listener: (context, state) {
          if (state is PackageRequestActionSuccess) {
            AppToast.showSuccess(context, message: state.message);
            Navigator.of(context).pop();
          } else if (state is PackageRequestError) {
            AppToast.showError(context, message: 'Đã xảy ra lỗi');
          }
        },
        builder: (context, state) {
          if (state is PackageRequestLoading ||
              state is PackageRequestActionLoading) {
            return const Center(
              child: AppLoadingIndicator(color: AppColors.primary),
            );
          }

          if (state is PackageRequestDetailLoaded) {
            return _buildDetail(scale, state);
          }

          if (state is PackageRequestError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64 * scale, color: AppColors.textSecondary),
                  SizedBox(height: 16 * scale),
                  AppWidgets.primaryButton(
                    text: 'Thử lại',
                    onPressed: () => context
                        .read<PackageRequestBloc>()
                        .add(LoadPackageRequestDetail(widget.requestId)),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(double scale, PackageRequestDetailLoaded state) {
    final request = state.request;
    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _buildStatusCard(scale, request),
          SizedBox(height: 16 * scale),

          // Tổng quan yêu cầu
          _buildSection(
            scale,
            title: 'Thông tin tổng quan',
            icon: Icons.info_outline,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Gói mẫu
                Row(
                  children: [
                    Container(
                      width: 40 * scale,
                      height: 40 * scale,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: request.basePackageImageUrl != null &&
                              request.basePackageImageUrl!.isNotEmpty
                          ? AppNetworkImage(
                              request.basePackageImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Icon(Icons.inventory_2_outlined,
                              color: AppColors.primary, size: 20 * scale),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.basePackageName,
                            style: AppTextStyles.tinos(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (request.packageName != null) ...[
                            SizedBox(height: 2 * scale),
                            Text(
                              'Gói đã soạn: ${request.packageName}',
                              style: AppTextStyles.arimo(
                                  fontSize: 13 * scale, color: AppColors.primary),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12 * scale),
                  child: Divider(color: AppColors.borderLight, height: 1),
                ),

                // 2. Tiêu đề và mô tả
                _buildDetailRow(scale, 'Tiêu đề', request.title),
                SizedBox(height: 8 * scale),
                _buildDetailRow(scale, 'Mô tả', request.description),
                SizedBox(height: 8 * scale),
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailRow(
                          scale, 'Ngày bắt đầu', request.requestedStartDate),
                    ),
                    Expanded(
                      child: _buildDetailRow(
                          scale, 'Số ngày', '${request.totalDays} ngày'),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12 * scale),
                  child: Divider(color: AppColors.borderLight, height: 1),
                ),

                // 3. Đối tượng phục vụ
                Text(
                  'Đối tượng phục vụ',
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Wrap(
                  spacing: 8 * scale,
                  runSpacing: 8 * scale,
                  children: request.familyProfiles.map((p) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: _getMemberColor(p.memberType).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20 * scale),
                        border: Border.all(
                          color: _getMemberColor(p.memberType).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AvatarWidget(
                            imageUrl: p.avatarUrl,
                            displayName: p.fullName,
                            size: 20 * scale,
                            fallbackIcon: _getMemberIcon(p.memberType),
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            p.fullName,
                            style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4 * scale),
                          Text(
                            '(${_translateMemberType(p.memberType)})',
                            style: AppTextStyles.arimo(
                              fontSize: 11 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),

          // Lịch trình nghỉ dưỡng
          if (state.customCarePlans != null && state.customCarePlans!.isNotEmpty) ...[
            _buildSection(
              scale,
              title: 'Lịch trình nghỉ dưỡng',
              icon: Icons.calendar_month_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hoạt động chăm sóc theo từng ngày',
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  // Day picker
                  _buildDayPicker(scale, state.customCarePlans!),
                  SizedBox(height: 16 * scale),
                  // Timeline for the selected day
                  _buildActivityTimeline(scale, state.customCarePlans!),
                ],
              ),
            ),
            SizedBox(height: 12 * scale),
          ],

          // Reject reason / feedback
          if (request.rejectReason != null &&
              request.rejectReason!.isNotEmpty) ...[
            _buildSection(
              scale,
              title: 'Lý do từ chối',
              icon: Icons.warning_amber_rounded,
              child: Text(
                request.rejectReason!,
                style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: const Color(0xFFC62828)),
              ),
            ),
            SizedBox(height: 12 * scale),
          ],

          if (request.customerFeedback != null &&
              request.customerFeedback!.isNotEmpty) ...[
            _buildSection(
              scale,
              title: 'Phản hồi của bạn',
              icon: Icons.chat_bubble_outline_rounded,
              child: Text(
                request.customerFeedback!,
                style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textPrimary),
              ),
            ),
            SizedBox(height: 12 * scale),
          ],

          // Action buttons (only if status == 1, Drafted)
          if (request.status == 1) ...[
            SizedBox(height: 8 * scale),
            _buildActionButtons(scale, request),
          ],
          SizedBox(height: 32 * scale),
        ],
      ),
    );
  }

  Widget _buildStatusCard(double scale, PackageRequestEntity request) {
    final statusInfo = _getStatusInfo(request.status, request.statusName);

    return Container(
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusInfo['color'] as Color,
            (statusInfo['color'] as Color).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusInfo['icon'] as IconData,
                color: Colors.white, size: 28 * scale),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusInfo['label'] as String,
                  style: AppTextStyles.tinos(
                    fontSize: 18 * scale,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  statusInfo['desc'] as String,
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(int status, String statusName) {
    switch (status) {
      case 0:
        return {
          'color': AppColors.textSecondary,
          'icon': Icons.hourglass_empty_rounded,
          'label': 'Đang chờ xử lý',
          'desc': 'Trung tâm đang xem xét yêu cầu của bạn',
        };
      case 1:
        return {
          'color': AppColors.primary,
          'icon': Icons.assignment_turned_in_outlined,
          'label': 'Gói đã được soạn',
          'desc': 'Trung tâm đã soạn gói cho bạn, vui lòng xem xét',
        };
      case 3:
        return {
          'color': const Color(0xFF2E7D32),
          'icon': Icons.check_circle_outline_rounded,
          'label': 'Đã chấp nhận',
          'desc': 'Bạn đã chấp nhận gói dịch vụ này',
        };
      case 4:
        return {
          'color': const Color(0xFFC62828),
          'icon': Icons.cancel_outlined,
          'label': 'Đã từ chối',
          'desc': 'Yêu cầu này đã bị từ chối',
        };
      case 2:
        return {
          'color': const Color(0xFF1565C0),
          'icon': Icons.edit_note_rounded,
          'label': 'Yêu cầu chỉnh sửa',
          'desc': 'Bạn đã yêu cầu trung tâm chỉnh sửa lại gói',
        };
      default:
        return {
          'color': AppColors.textSecondary,
          'icon': Icons.info_outline,
          'label': statusName,
          'desc': '',
        };
    }
  }

  Widget _buildSection(
    double scale, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18 * scale, color: AppColors.primary),
              SizedBox(width: 8 * scale),
              Text(
                title,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(double scale, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
              fontSize: 12 * scale, color: AppColors.textSecondary),
        ),
        SizedBox(height: 2 * scale),
        Text(
          value,
          style: AppTextStyles.arimo(
            fontSize: 15 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(double scale, PackageRequestEntity request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Hành động',
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12 * scale),
        AppWidgets.primaryButton(
          text: 'Chấp nhận gói dịch vụ',
          onPressed: () => _confirmAction(
            'Bạn có chắc muốn chấp nhận gói dịch vụ này?',
            () => context
                .read<PackageRequestBloc>()
                .add(ApprovePackageRequest(request.id)),
          ),
        ),
        SizedBox(height: 10 * scale),
        OutlinedButton.icon(
          onPressed: () => _showRevisionDialog(request.id),
          icon: Icon(Icons.edit_note_rounded,
              size: 20 * scale, color: const Color(0xFF1565C0)),
          label: Text(
            'Yêu cầu chỉnh sửa',
            style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1565C0)),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14 * scale),
            side: const BorderSide(color: Color(0xFF1565C0)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16 * scale),
            ),
          ),
        ),
        SizedBox(height: 10 * scale),
        OutlinedButton.icon(
          onPressed: () => _confirmAction(
            'Bạn có chắc muốn từ chối gói dịch vụ này?',
            () => context
                .read<PackageRequestBloc>()
                .add(RejectPackageRequest(request.id)),
          ),
          icon: Icon(Icons.close_rounded,
              size: 20 * scale, color: const Color(0xFFC62828)),
          label: Text(
            'Từ chối',
            style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFC62828)),
          ),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 14 * scale),
            side: const BorderSide(color: Color(0xFFC62828)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16 * scale),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmAction(String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text('Xác nhận',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showRevisionDialog(int requestId) {
    final controller = TextEditingController();
    final scale = AppResponsive.scaleFactor(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Yêu cầu chỉnh sửa',
          style: AppTextStyles.tinos(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Nhập phản hồi của bạn...',
            hintStyle: AppTextStyles.arimo(
                fontSize: 14 * scale, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(ctx);
                context.read<PackageRequestBloc>().add(
                      RequestRevisionPackageRequest(
                          requestId, controller.text.trim()),
                    );
              }
            },
            child: Text('Gửi',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Color _getMemberColor(String memberType) {
    switch (memberType.toLowerCase()) {
      case 'mom':
        return AppColors.primary;
      case 'baby':
        return const Color(0xFF1565C0);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getMemberIcon(String memberType) {
    switch (memberType.toLowerCase()) {
      case 'mom':
        return Icons.pregnant_woman_rounded;
      case 'baby':
        return Icons.child_care_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _translateMemberType(String type) {
    switch (type.toLowerCase()) {
      case 'mom':
        return 'Mẹ';
      case 'baby':
        return 'Bé';
      case 'head of family':
        return 'Chủ hộ';
      default:
        return type;
    }
  }

  Widget _buildDayPicker(double scale, List<CarePlanEntity> carePlans) {
    final days = carePlans.map((e) => e.dayNo).toSet().toList()..sort();
    if (days.isEmpty) return const SizedBox.shrink();

    // ensure _currentDayNo is valid
    bool updateState = false;
    if (_availableDays.length != days.length || !_availableDays.every((d) => days.contains(d))) {
      _availableDays = days;
      if (_currentDayNo == 0 || !days.contains(_currentDayNo)) {
        _currentDayNo = days.first;
      }
      updateState = true;
    }

    if (updateState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: days.map((dayNo) {
          final isSelected = dayNo == _currentDayNo;
          return GestureDetector(
            onTap: () => setState(() => _currentDayNo = dayNo),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: 10 * scale),
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 8 * scale,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: 1.5,
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
              child: Text(
                'Ngày $dayNo',
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityTimeline(double scale, List<CarePlanEntity> carePlans) {
    final dayActivities = carePlans.where((cp) => cp.dayNo == _currentDayNo).toList()
      ..sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        return a.startTime.compareTo(b.startTime);
      });

    if (dayActivities.isEmpty) {
      return Center(
        child: Text(
          'Không có hoạt động nào cho ngày $_currentDayNo',
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      children: dayActivities.asMap().entries.map((entry) {
        final index = entry.key;
        final activity = entry.value;
        final isLast = index == dayActivities.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline column
              SizedBox(
                width: 24 * scale,
                child: Column(
                  children: [
                    // Dot
                    Container(
                      width: 12 * scale,
                      height: 12 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 4 * scale,
                          ),
                        ],
                      ),
                    ),
                    // Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2 * scale,
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: 12 * scale),
              // Activity card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16 * scale),
                  child: Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8 * scale,
                            vertical: 4 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6 * scale),
                          ),
                          child: Text(
                            '${activity.startTime} - ${activity.endTime}',
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          activity.activityName,
                          style: AppTextStyles.arimo(
                            fontSize: 15 * scale,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (activity.instruction != null && activity.instruction!.isNotEmpty) ...[
                          SizedBox(height: 4 * scale),
                          Text(
                            activity.instruction!,
                            style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              color: AppColors.textSecondary,
                            ).copyWith(height: 1.4),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

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

class PackageRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const PackageRequestDetailScreen({super.key, required this.requestId});

  @override
  State<PackageRequestDetailScreen> createState() =>
      _PackageRequestDetailScreenState();
}

class _PackageRequestDetailScreenState
    extends State<PackageRequestDetailScreen> {
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
            return _buildDetail(scale, state.request);
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

  Widget _buildDetail(double scale, PackageRequestEntity request) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          _buildStatusCard(scale, request),
          SizedBox(height: 16 * scale),

          // Package info
          _buildSection(
            scale,
            title: 'Gói mẫu',
            icon: Icons.inventory_2_outlined,
            child: Row(
              children: [
                Container(
                  width: 50 * scale,
                  height: 50 * scale,
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
                          color: AppColors.primary, size: 24 * scale),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.basePackageName,
                        style: AppTextStyles.tinos(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (request.packageName != null) ...[
                        SizedBox(height: 4 * scale),
                        Text(
                          'Gói đã soạn: ${request.packageName}',
                          style: AppTextStyles.arimo(
                              fontSize: 14 * scale, color: AppColors.primary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),

          // Request details
          _buildSection(
            scale,
            title: 'Thông tin yêu cầu',
            icon: Icons.description_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
              ],
            ),
          ),
          SizedBox(height: 12 * scale),

          // Family profiles
          _buildSection(
            scale,
            title: 'Đối tượng phục vụ',
            icon: Icons.family_restroom_rounded,
            child: Column(
              children: request.familyProfiles.map((p) {
                return Container(
                  margin: EdgeInsets.only(bottom: 8 * scale),
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: _getMemberColor(p.memberType)
                        .withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: _getMemberColor(p.memberType)
                          .withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      AvatarWidget(
                        imageUrl: p.avatarUrl,
                        displayName: p.fullName,
                        size: 40,
                        fallbackIcon: _getMemberIcon(p.memberType),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.fullName,
                              style: AppTextStyles.arimo(
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              _translateMemberType(p.memberType),
                              style: AppTextStyles.arimo(
                                  fontSize: 13 * scale,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 12 * scale),

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
}

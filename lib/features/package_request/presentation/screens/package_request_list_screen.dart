import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/package_request_entity.dart';
import '../bloc/package_request_bloc.dart';
import '../bloc/package_request_event.dart';
import '../bloc/package_request_state.dart';
import '../widgets/create_package_request_sheet.dart';
import 'package_request_detail_screen.dart';
import '../../../../core/widgets/avatar_widget.dart';

class PackageRequestListScreen extends StatefulWidget {
  const PackageRequestListScreen({super.key});

  @override
  State<PackageRequestListScreen> createState() =>
      _PackageRequestListScreenState();
}

class _PackageRequestListScreenState extends State<PackageRequestListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PackageRequestBloc>().add(const LoadPackageRequests());
  }

  void _showCreateSheet() {
    final height = MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: height * 0.9),
        child: BlocProvider.value(
          value: context.read<PackageRequestBloc>(),
          child: const CreatePackageRequestSheet(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'Cá nhân hoá gói dịch vụ',
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
      ),
      body: BlocConsumer<PackageRequestBloc, PackageRequestState>(
        listener: (context, state) {
          if (state is PackageRequestCreated) {
            // Refresh list when a new request is created
            context.read<PackageRequestBloc>().add(const LoadPackageRequests());
          }
        },
        builder: (context, state) {
          if (state is PackageRequestLoading) {
            return const Center(
              child: AppLoadingIndicator(color: AppColors.primary),
            );
          }

          if (state is PackageRequestsLoaded) {
            if (state.requests.isEmpty) {
              return _buildEmptyState(scale);
            }
            return _buildList(scale, state.requests);
          }

          if (state is PackageRequestError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(32 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 64 * scale, color: AppColors.textSecondary),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Đã xảy ra lỗi',
                      style: AppTextStyles.tinos(
                          fontSize: 18 * scale,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8 * scale),
                    AppWidgets.primaryButton(
                      text: 'Thử lại',
                      onPressed: () => context
                          .read<PackageRequestBloc>()
                          .add(const LoadPackageRequests()),
                    ),
                  ],
                ),
              ),
            );
          }

          return _buildEmptyState(scale);
        },
      ),
      floatingActionButton: AppWidgets.primaryFabExtendedIconOnly(
        context: context,
        icon: Icons.add_rounded,
        onPressed: _showCreateSheet,
      ),
    );
  }

  Widget _buildEmptyState(double scale) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(Icons.tune_rounded,
                  size: 64 * scale, color: AppColors.primary),
            ),
            SizedBox(height: 24 * scale),
            Text(
              'Chưa có yêu cầu nào',
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Bấm vào nút + bên dưới để tạo yêu cầu\ncá nhân hoá gói dịch vụ.',
              style: AppTextStyles.arimo(
                  fontSize: 14 * scale, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(double scale, List<PackageRequestEntity> requests) {
    // Sort by createdAt descending
    final sorted = List<PackageRequestEntity>.from(requests)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PackageRequestBloc>().add(const LoadPackageRequests());
      },
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 16 * scale),
        itemCount: sorted.length,
        itemBuilder: (context, index) =>
            _buildRequestCard(scale, sorted[index]),
      ),
    );
  }

  Widget _buildRequestCard(double scale, PackageRequestEntity request) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => InjectionContainer.packageRequestBloc,
              child: PackageRequestDetailScreen(requestId: request.id),
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8 * scale,
              offset: Offset(0, 2 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16 * scale)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40 * scale,
                    height: 40 * scale,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
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
                        SizedBox(height: 2 * scale),
                        Text(
                          request.title,
                          style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(scale, request.status, request.statusName),
                ],
              ),
            ),
            // Body
            Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildInfoChip(scale, Icons.calendar_today_rounded,
                          request.requestedStartDate),
                      SizedBox(width: 16 * scale),
                      _buildInfoChip(scale, Icons.schedule_rounded,
                          '${request.totalDays} ngày'),
                    ],
                  ),
                  SizedBox(height: 12 * scale),
                  // Family profiles
                  Wrap(
                    spacing: 8 * scale,
                    runSpacing: 6 * scale,
                    children: request.familyProfiles.map((p) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale, vertical: 6 * scale),
                        decoration: BoxDecoration(
                          color: _getMemberColor(p.memberType)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20 * scale),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AvatarWidget(
                              imageUrl: p.avatarUrl,
                              displayName: p.fullName,
                              size: 18,
                              fallbackIcon: _getMemberIcon(p.memberType),
                            ),
                            SizedBox(width: 4 * scale),
                            Text(
                              p.fullName,
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: _getMemberColor(p.memberType),
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(double scale, int status, String statusName) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 0:
        bgColor = AppColors.textSecondary.withValues(alpha: 0.1);
        textColor = AppColors.textSecondary;
        label = 'Đang chờ';
        break;
      case 1:
        bgColor = AppColors.primary.withValues(alpha: 0.1);
        textColor = AppColors.primary;
        label = 'Đã soạn gói';
        break;
      case 3:
        bgColor = const Color(0xFF2E7D32).withValues(alpha: 0.1);
        textColor = const Color(0xFF2E7D32);
        label = 'Đã chấp nhận';
        break;
      case 4:
        bgColor = const Color(0xFFC62828).withValues(alpha: 0.1);
        textColor = const Color(0xFFC62828);
        label = 'Đã từ chối';
        break;
      case 2:
        bgColor = const Color(0xFF1565C0).withValues(alpha: 0.1);
        textColor = const Color(0xFF1565C0);
        label = 'Yêu cầu chỉnh sửa';
        break;
      default:
        bgColor = AppColors.textSecondary.withValues(alpha: 0.1);
        textColor = AppColors.textSecondary;
        label = statusName;
    }

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Text(
        label,
        style: AppTextStyles.arimo(
          fontSize: 11 * scale,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildInfoChip(double scale, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14 * scale, color: AppColors.textSecondary),
        SizedBox(width: 4 * scale),
        Text(
          text,
          style: AppTextStyles.arimo(
              fontSize: 13 * scale, color: AppColors.textSecondary),
        ),
      ],
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
}

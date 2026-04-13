import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../domain/entities/refund_request_entity.dart';
import '../bloc/refund_request/refund_request_bloc.dart';
import '../bloc/refund_request/refund_request_event.dart';
import '../bloc/refund_request/refund_request_state.dart';

/// Screen to display user's refund request history
class RefundRequestHistoryScreen extends StatelessWidget {
  const RefundRequestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.refundRequestHistoryTitle,
        showBackButton: true,
        centerTitle: true,
      ),
      body: BlocBuilder<RefundRequestBloc, RefundRequestState>(
        builder: (context, state) {
          if (state is RefundRequestLoading) {
            return const Center(
              child: AppLoadingIndicator(color: AppColors.primary),
            );
          }

          if (state is RefundRequestError) {
            return _buildErrorView(context, state.message);
          }

          if (state is RefundRequestLoaded) {
            if (state.requests.isEmpty) {
              return _buildEmptyView(context);
            }
            return _buildRequestList(context, state.requests);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    final scale = AppResponsive.scaleFactor(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64 * scale,
              color: AppColors.red,
            ),
            SizedBox(height: 16 * scale),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24 * scale),
            AppWidgets.primaryButton(
              text: AppStrings.retry,
              onPressed: () {
                context
                    .read<RefundRequestBloc>()
                    .add(const RefundRequestLoadMyRequests());
              },
              width: 200 * scale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 44 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24 * scale),
            Text(
              AppStrings.refundRequestNoRequests,
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8 * scale),
            Text(
              AppStrings.refundRequestEmptyHint,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(
    BuildContext context,
    List<RefundRequestEntity> requests,
  ) {
    final scale = AppResponsive.scaleFactor(context);

    // Sort by createdAt descending (newest first)
    final sortedRequests = List<RefundRequestEntity>.from(requests)
      ..sort((a, b) {
        final aDate = a.createdAt ?? DateTime(2000);
        final bDate = b.createdAt ?? DateTime(2000);
        return bDate.compareTo(aDate);
      });

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context
            .read<RefundRequestBloc>()
            .add(const RefundRequestLoadMyRequests());
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20 * scale),
        itemCount: sortedRequests.length,
        separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
        itemBuilder: (context, index) {
          return _RefundRequestCard(request: sortedRequests[index]);
        },
      ),
    );
  }
}

class _RefundRequestCard extends StatefulWidget {
  final RefundRequestEntity request;

  const _RefundRequestCard({required this.request});

  @override
  State<_RefundRequestCard> createState() => _RefundRequestCardState();
}

class _RefundRequestCardState extends State<_RefundRequestCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _getStatusColor(widget.request.status);
    final statusText = _getStatusText(widget.request.status);

    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(16 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
          border: Border.all(
            color: AppColors.borderLight.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upper Section (Always visible)
            Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Yêu cầu #${widget.request.id}',
                        style: AppTextStyles.arimo(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      _buildStatusBadge(statusText, statusColor, scale),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoRow(
                        'Mã booking',
                        '#${widget.request.bookingId}',
                        AppColors.primary,
                        scale,
                        icon: Icons.tag_rounded,
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 20 * scale,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_balance_outlined,
                        size: 16 * scale,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.request.bankName,
                              style: AppTextStyles.arimo(
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2 * scale),
                            Text(
                              '${widget.request.accountNumber} • ${widget.request.accountHolder}',
                              style: AppTextStyles.arimo(
                                fontSize: 12 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Dashed Divider
            _buildDashedDivider(scale),

            // Lower Section (Partially visible/expandable)
            Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Financial Info (Always visible)
                  Row(
                    children: [
                      Expanded(
                        child: _buildAmountBox(
                          'Số tiền yêu cầu',
                          widget.request.requestedAmount ?? 0,
                          AppColors.textSecondary,
                          scale,
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: _buildAmountBox(
                          'Số tiền được duyệt',
                          widget.request.approvedAmount ?? 0,
                          widget.request.approvedAmount != null &&
                                  widget.request.approvedAmount! > 0
                              ? AppColors.appointmentCompleted
                              : AppColors.textSecondary,
                          scale,
                          isHighlight: true,
                        ),
                      ),
                    ],
                  ),

                  // Expandable Section for Reason and Admin Note
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        SizedBox(height: 16 * scale),
                        // Reason
                        _buildAccentSection(
                          label: AppStrings.refundRequestReason,
                          content: widget.request.reason,
                          accentColor: AppColors.primary,
                          scale: scale,
                        ),

                        // Admin Note
                        if (widget.request.adminNote != null &&
                            widget.request.adminNote!.isNotEmpty) ...[
                          SizedBox(height: 12 * scale),
                          _buildAccentSection(
                            label: AppStrings.refundRequestAdminNote,
                            content: widget.request.adminNote!,
                            accentColor: AppColors.appointmentScheduled,
                            scale: scale,
                            isSecondary: true,
                          ),
                        ],
                      ],
                    ),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  SizedBox(height: 20 * scale),
                  // Metadata Footer (Always visible)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetaDate('Ngày tạo', widget.request.createdAt, scale),
                      if (widget.request.processedAt != null)
                        _buildMetaDate(
                            'Hoàn thành', widget.request.processedAt, scale),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedDivider(double scale) {
    return Row(
      children: [
        SizedBox(
          width: 8 * scale,
          height: 16 * scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8 * scale),
                bottomRight: Radius.circular(8 * scale),
              ),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const dashWidth = 4.0;
              const dashSpace = 4.0;
              final dashCount =
                  (constraints.constrainWidth() / (dashWidth + dashSpace))
                      .floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(dashCount, (_) {
                  return SizedBox(
                    width: dashWidth,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.borderLight.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        SizedBox(
          width: 8 * scale,
          height: 16 * scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8 * scale),
                bottomLeft: Radius.circular(8 * scale),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.arimo(
          fontSize: 9 * scale,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color, double scale,
      {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14 * scale, color: color.withValues(alpha: 0.6)),
          SizedBox(width: 8 * scale),
        ],
        Text(
          '$label: ',
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountBox(String label, double amount, Color color, double scale,
      {bool isHighlight = false}) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: isHighlight
            ? color.withValues(alpha: 0.04)
            : AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(
          color: isHighlight
              ? color.withValues(alpha: 0.2)
              : AppColors.borderLight.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 10 * scale,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            _formatPrice(amount),
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w800,
              color: isHighlight ? color : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccentSection({
    required String label,
    required String content,
    required Color accentColor,
    required double scale,
    bool isSecondary = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12 * scale,
              height: 2 * scale,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              label.toUpperCase(),
              style: AppTextStyles.arimo(
                fontSize: 10 * scale,
                fontWeight: FontWeight.w800,
                color: accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
              horizontal: 16 * scale, vertical: 12 * scale),
          decoration: BoxDecoration(
            color: isSecondary
                ? accentColor.withValues(alpha: 0.03)
                : AppColors.background.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(
              color: isSecondary
                  ? accentColor.withValues(alpha: 0.1)
                  : AppColors.borderLight.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            content,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaDate(String label, DateTime? date, double scale) {
    if (date == null) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.access_time_rounded,
            size: 12 * scale, color: AppColors.textSecondary.withValues(alpha: 0.5)),
        SizedBox(width: 6 * scale),
        Text(
          '$label: ',
          style: AppTextStyles.arimo(
            fontSize: 10 * scale,
            color: AppColors.textSecondary.withValues(alpha: 0.6),
          ),
        ),
        Text(
          _formatDateTime(date),
          style: AppTextStyles.arimo(
            fontSize: 10 * scale,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return '0 ${AppStrings.currencyUnit}';
    final priceStr = price.toStringAsFixed(0);
    if (priceStr.length <= 3) {
      return '$priceStr ${AppStrings.currencyUnit}';
    }
    final buffer = StringBuffer();
    int count = 0;
    for (int i = priceStr.length - 1; i >= 0; i--) {
      buffer.write(priceStr[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join()} ${AppStrings.currencyUnit}';
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Color _getStatusColor(String status) {
    final normalizedStatus = status.trim().toLowerCase();
    switch (normalizedStatus) {
      case 'approved':
        return AppColors.appointmentCompleted;
      case 'rejected':
        return AppColors.appointmentCancelled;
      case 'processed':
        return AppColors.appointmentScheduled;
      case 'pending':
      default:
        return AppColors.appointmentPending;
    }
  }

  String _getStatusText(String status) {
    final normalizedStatus = status.trim().toLowerCase();
    switch (normalizedStatus) {
      case 'approved':
        return AppStrings.refundRequestStatusApproved;
      case 'rejected':
        return AppStrings.refundRequestStatusRejected;
      case 'processed':
        return AppStrings.refundRequestStatusProcessed;
      case 'pending':
      default:
        return AppStrings.refundRequestStatusPending;
    }
  }
}

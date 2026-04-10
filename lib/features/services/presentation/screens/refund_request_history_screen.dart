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
      child: Container(
        margin: EdgeInsets.all(20 * scale),
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.52,
        ),
        padding: EdgeInsets.all(32 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16 * scale),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 36 * scale,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 18 * scale),
            Text(
              AppStrings.refundRequestNoRequests,
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
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

class _RefundRequestCard extends StatelessWidget {
  final RefundRequestEntity request;

  const _RefundRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _getStatusColor(request.status);
    final statusText = _getStatusText(request.status);

    return Container(
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Request ID and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yêu cầu #${request.id}',
                style: AppTextStyles.tinos(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              _buildStatusBadge(statusText, statusColor, scale),
            ],
          ),

          SizedBox(height: 16 * scale),
          const Divider(height: 1, color: AppColors.borderLight),
          SizedBox(height: 16 * scale),

          // Main Info Block: Booking ID & Bank details
          _buildInfoGrid(context, scale),

          SizedBox(height: 16 * scale),

          // Financial Summary
          _buildFinancialSummary(context, scale),

          SizedBox(height: 16 * scale),

          // Reason Section (Modern accent style)
          _buildAccentSection(
            context,
            label: AppStrings.refundRequestReason,
            content: request.reason,
            accentColor: AppColors.primary,
            scale: scale,
          ),

          // Admin Note Section
          if (request.adminNote != null && request.adminNote!.isNotEmpty) ...[
            SizedBox(height: 12 * scale),
            _buildAccentSection(
              context,
              label: AppStrings.refundRequestAdminNote,
              content: request.adminNote!,
              accentColor: AppColors.appointmentScheduled,
              scale: scale,
              isSecondary: true,
            ),
          ],

          SizedBox(height: 18 * scale),
          // Footer: Minimalist dates
          _buildCompactFooter(context, scale),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5 * scale,
            height: 5 * scale,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 6 * scale),
          Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 10 * scale,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context, double scale) {
    return Column(
      children: [
        _buildInfoRow(
          'Mã booking',
          '#${request.bookingId}',
          AppColors.primary,
          scale,
          icon: Icons.confirmation_number_outlined,
        ),
        SizedBox(height: 10 * scale),
        Container(
          padding: EdgeInsets.all(12 * scale),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12 * scale),
          ),
          child: Column(
            children: [
              _buildBankDetail('Ngân hàng', request.bankName, scale),
              SizedBox(height: 8 * scale),
              _buildBankDetail('Số tài khoản', request.accountNumber, scale, isBold: true),
              SizedBox(height: 8 * scale),
              _buildBankDetail('Chủ tài khoản', request.accountHolder, scale),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, Color color, double scale, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14 * scale, color: color.withValues(alpha: 0.6)),
          SizedBox(width: 6 * scale),
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

  Widget _buildBankDetail(String label, String value, double scale, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 11 * scale,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.arimo(
            fontSize: 11 * scale,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(BuildContext context, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.primary.withValues(alpha: 0.01),
          ],
        ),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAmountItem(
              'Số tiền yêu cầu',
              request.requestedAmount ?? 0,
              AppColors.textSecondary,
              scale,
            ),
          ),
          Container(height: 30 * scale, width: 1, color: AppColors.borderLight),
          Expanded(
            child: _buildAmountItem(
              'Số tiền được duyệt',
              request.approvedAmount ?? 0,
              request.approvedAmount != null && request.approvedAmount! > 0
                  ? AppColors.appointmentCompleted
                  : AppColors.textSecondary,
              scale,
              emphasize: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountItem(String label, double amount, Color color, double scale, {bool emphasize = false}) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 10 * scale,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 4 * scale),
        Text(
          _formatPrice(amount),
          style: AppTextStyles.arimo(
            fontSize: emphasize ? 15 * scale : 13 * scale,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildAccentSection(
    BuildContext context, {
    required String label,
    required String content,
    required Color accentColor,
    required double scale,
    bool isSecondary = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isSecondary ? accentColor.withValues(alpha: 0.03) : Colors.transparent,
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3 * scale,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2 * scale),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: AppTextStyles.arimo(
                      fontSize: 9 * scale,
                      fontWeight: FontWeight.w800,
                      color: accentColor.withValues(alpha: 0.8),
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    content,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactFooter(BuildContext context, double scale) {
    return Column(
      children: [
        if (request.createdAt != null)
          _buildMinimalDate('Đã tạo', request.createdAt!, scale),
        if (request.processedAt != null) ...[
          SizedBox(height: 4 * scale),
          _buildMinimalDate('Đã xử lý', request.processedAt!, scale),
        ],
      ],
    );
  }

  Widget _buildMinimalDate(String label, DateTime date, double scale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$label ',
          style: AppTextStyles.arimo(
            fontSize: 10 * scale,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
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


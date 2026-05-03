import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
              Icons.error_outline_rounded,
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
              padding: EdgeInsets.all(32 * scale),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                size: 60 * scale,
                color: AppColors.primary.withValues(alpha: 0.5),
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
            SizedBox(height: 12 * scale),
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

    // Group by month
    final groupedRequests = <String, List<RefundRequestEntity>>{};
    for (var request in sortedRequests) {
      final date = request.createdAt ?? DateTime.now();
      final key = DateFormat('MMMM, yyyy').format(date);
      if (!groupedRequests.containsKey(key)) {
        groupedRequests[key] = [];
      }
      groupedRequests[key]!.add(request);
    }

    final monthKeys = groupedRequests.keys.toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        context
            .read<RefundRequestBloc>()
            .add(const RefundRequestLoadMyRequests());
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 12 * scale),
        itemCount: monthKeys.length,
        itemBuilder: (context, monthIndex) {
          final monthKey = monthKeys[monthIndex];
          final monthItems = groupedRequests[monthKey]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: 4 * scale, top: 16 * scale, bottom: 12 * scale),
                child: Text(
                  _translateMonth(monthKey),
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...monthItems.map((request) => Padding(
                    padding: EdgeInsets.only(bottom: 16 * scale),
                    child: _RefundRequestCard(request: request),
                  )),
            ],
          );
        },
      ),
    );
  }

  String _translateMonth(String monthYear) {
    // Basic translation for month names from English to Vietnamese
    final parts = monthYear.split(', ');
    if (parts.length != 2) return monthYear;
    
    String month = parts[0];
    final year = parts[1];
    
    switch (month.toLowerCase()) {
      case 'january': month = 'Tháng 1'; break;
      case 'february': month = 'Tháng 2'; break;
      case 'march': month = 'Tháng 3'; break;
      case 'april': month = 'Tháng 4'; break;
      case 'may': month = 'Tháng 5'; break;
      case 'june': month = 'Tháng 6'; break;
      case 'july': month = 'Tháng 7'; break;
      case 'august': month = 'Tháng 8'; break;
      case 'september': month = 'Tháng 9'; break;
      case 'october': month = 'Tháng 10'; break;
      case 'november': month = 'Tháng 11'; break;
      case 'december': month = 'Tháng 12'; break;
    }
    
    return '$month, $year';
  }
}

class _RefundRequestCard extends StatefulWidget {
  final RefundRequestEntity request;

  const _RefundRequestCard({required this.request});

  @override
  State<_RefundRequestCard> createState() => _RefundRequestCardState();
}

class _RefundRequestCardState extends State<_RefundRequestCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final statusColor = _getStatusColor(widget.request.status);
    final statusText = _getStatusText(widget.request.status);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          borderRadius: BorderRadius.circular(20 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8 * scale),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                              child: Icon(
                                Icons.receipt_outlined,
                                size: 18 * scale,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 12 * scale),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Yêu cầu #${widget.request.id}',
                                  style: AppTextStyles.arimo(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Mã booking: #${widget.request.bookingId}',
                                  style: AppTextStyles.arimo(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        _buildStatusBadge(statusText, statusColor, scale),
                      ],
                    ),
                    SizedBox(height: 16 * scale),
                    
                    // Bank Info
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(
                          color: AppColors.borderLight.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_rounded,
                            size: 18 * scale,
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          SizedBox(width: 12 * scale),
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
                    ),
                  ],
                ),
              ),

              // Dashed Divider with semi-circles
              _buildModernDivider(scale),

              // Amount Section
              Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildAmountCard(
                            'Yêu cầu',
                            widget.request.requestedAmount ?? 0,
                            Icons.account_balance_wallet_outlined,
                            AppColors.textSecondary,
                            scale,
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: _buildAmountCard(
                            'Được duyệt',
                            widget.request.approvedAmount ?? 0,
                            Icons.check_circle_outline_rounded,
                            widget.request.approvedAmount != null &&
                                    widget.request.approvedAmount! > 0
                                ? AppColors.appointmentCompleted
                                : AppColors.textSecondary,
                            scale,
                            isHighlithed: widget.request.approvedAmount != null &&
                                    widget.request.approvedAmount! > 0,
                          ),
                        ),
                      ],
                    ),

                    // Expandable Details
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: Column(
                        children: [
                          if (_isExpanded) ...[
                            SizedBox(height: 16 * scale),
                            _buildDetailSection(
                              'Lý do hoàn tiền',
                              widget.request.reason,
                              Icons.info_outline_rounded,
                              AppColors.primary,
                              scale,
                            ),
                            if (widget.request.adminNote != null &&
                                widget.request.adminNote!.isNotEmpty) ...[
                              SizedBox(height: 12 * scale),
                              _buildDetailSection(
                                'Ghi chú từ quản trị viên',
                                widget.request.adminNote!,
                                Icons.note_alt_outlined,
                                AppColors.appointmentScheduled,
                                scale,
                                isSecondary: true,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 16 * scale),
                    
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFooterDate(
                            'Ngày tạo', widget.request.createdAt, scale),
                        Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20 * scale,
                          color: AppColors.textSecondary.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDivider(double scale) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Container(
              width: 10 * scale,
              height: 20 * scale,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10 * scale),
                  bottomRight: Radius.circular(10 * scale),
                ),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.2)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.constrainWidth();
                    const dashWidth = 6.0;
                    const dashHeight = 1.2;
                    final dashCount = (boxWidth / (2 * dashWidth)).floor();
                    return Flex(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      direction: Axis.horizontal,
                      children: List.generate(dashCount, (_) {
                        return SizedBox(
                          width: dashWidth,
                          height: dashHeight,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: AppColors.borderLight.withValues(alpha: 0.4)),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
            Container(
              width: 10 * scale,
              height: 20 * scale,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10 * scale),
                  bottomLeft: Radius.circular(10 * scale),
                ),
                border: Border.all(color: AppColors.borderLight.withValues(alpha: 0.2)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text.toUpperCase(),
        style: AppTextStyles.arimo(
          fontSize: 10 * scale,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildAmountCard(
      String label, double amount, IconData icon, Color color, double scale,
      {bool isHighlithed = false}) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: isHighlithed
            ? color.withValues(alpha: 0.05)
            : AppColors.background.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(
          color: isHighlithed
              ? color.withValues(alpha: 0.15)
              : AppColors.borderLight.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14 * scale, color: color.withValues(alpha: 0.6)),
              SizedBox(width: 6 * scale),
              Text(
                label,
                style: AppTextStyles.arimo(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            _formatPrice(amount),
            style: AppTextStyles.arimo(
              fontSize: 15 * scale,
              fontWeight: FontWeight.w900,
              color: isHighlithed ? color : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
      String title, String content, IconData icon, Color accentColor, double scale,
      {bool isSecondary = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: isSecondary
            ? accentColor.withValues(alpha: 0.04)
            : AppColors.background.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14 * scale, color: accentColor),
              SizedBox(width: 8 * scale),
              Text(
                title.toUpperCase(),
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
          Text(
            content,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textPrimary.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterDate(String label, DateTime? date, double scale) {
    if (date == null) return const SizedBox.shrink();
    return Row(
      children: [
        Icon(Icons.calendar_today_rounded,
            size: 12 * scale, color: AppColors.textSecondary.withValues(alpha: 0.4)),
        SizedBox(width: 6 * scale),
        Text(
          '$label: ',
          style: AppTextStyles.arimo(
            fontSize: 10 * scale,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
        Text(
          DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal()),
          style: AppTextStyles.arimo(
            fontSize: 10 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
        .format(price);
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

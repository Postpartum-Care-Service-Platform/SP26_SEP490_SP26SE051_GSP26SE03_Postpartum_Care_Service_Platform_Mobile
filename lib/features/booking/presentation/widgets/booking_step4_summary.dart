import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_state.dart';

class BookingStep4Summary extends StatelessWidget {
  final VoidCallback onConfirm;

  const BookingStep4Summary({
    super.key,
    required this.onConfirm,
  });

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    
    // Format with thousand separators
    final buffer = StringBuffer();
    final length = priceStr.length;
    
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    
    return buffer.toString() + AppStrings.currencyUnit;
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        // Get summary data from state
        if (state is! BookingSummaryReady) {
          // If not ready, show loading or error
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16 * scale),
                Text(
                  'Đang tải thông tin...',
                  style: AppTextStyles.arimo(
                    fontSize: 14 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        final package = state.package;
        final room = state.room;
        final startDate = state.startDate;
        final endDate = package.durationDays != null
            ? startDate.add(Duration(days: package.durationDays!))
            : startDate;
        final totalPrice = package.basePrice;
        final depositAmount = totalPrice * 0.1; // 10% deposit

        return SingleChildScrollView(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Package and Room info - side by side (30% / 70%)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Package info - 30%
                  Expanded(
                    flex: 3,
                    child: _SummarySection(
                title: AppStrings.bookingPackage,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.packageName,
                      style: AppTextStyles.tinos(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4 * scale),
                    if (package.durationDays != null)
                      Text(
                        '${package.durationDays} ${AppStrings.bookingDays}',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
                  ),
                  SizedBox(width: 12 * scale),
                  // Room info - 70%
                  Expanded(
                    flex: 7,
                    child: _SummarySection(
                title: AppStrings.bookingRoom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                      'Phòng ${room.name}',
                      style: AppTextStyles.tinos(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (room.floor != null)
                      Text(
                        '${AppStrings.bookingFloor} ${room.floor}',
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                                ),
                            ],
                      ),
                    SizedBox(height: 4 * scale),
                    Text(
                      room.roomTypeName,
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        color: AppColors.textSecondary,
                      ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * scale),
              // Date info
              _SummarySection(
                title: 'Thời gian',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateRow(
                      label: AppStrings.bookingCheckIn,
                      date: startDate,
                      scale: scale,
                    ),
                    SizedBox(height: 12 * scale),
                    _DateRow(
                      label: AppStrings.bookingCheckOut,
                      date: endDate,
                      scale: scale,
                    ),
                    SizedBox(height: 12 * scale),
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8 * scale),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 20 * scale,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            package.durationDays != null
                                ? '${package.durationDays} ${AppStrings.bookingDays}'
                                : AppStrings.bookingDays,
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16 * scale),
              // Payment method section
              _SummarySection(
                title: AppStrings.paymentMethod,
                child: Container(
                  padding: EdgeInsets.all(8 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      // PayOS Logo
                      Container(
                        width: 80 * scale,
                        height: 40 * scale,
                        padding: EdgeInsets.all(2 * scale),
                        child: SvgPicture.asset(
                          AppAssets.payosLogo,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(AppColors.verified, BlendMode.srcIn),
                        ),
                      ),
                      // Payment method text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.paymentPayOS,
                              style: AppTextStyles.tinos(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4 * scale),
                            Text(
                              'Thanh toán qua PayOS',
                              style: AppTextStyles.arimo(
                                fontSize: 13 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        size: 24 * scale,
                        color: AppColors.verified,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16 * scale),
              // Price summary
              _SummarySection(
                title: AppStrings.invoicePriceDetails,
                child: Column(
                  children: [
                    _PriceRow(
                      label: AppStrings.bookingTotalPrice,
                      amount: totalPrice,
                      scale: scale,
                    ),
                    SizedBox(height: 8 * scale),
                    _PriceRow(
                      label: AppStrings.bookingDiscount,
                      amount: 0,
                      scale: scale,
                    ),
                    Divider(height: 24 * scale),
                    _PriceRow(
                      label: AppStrings.bookingFinalAmount,
                      amount: totalPrice,
                      scale: scale,
                      isTotal: true,
                    ),
                    SizedBox(height: 16 * scale),
                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.bookingDeposit,
                                style: AppTextStyles.arimo(
                                  fontSize: 14 * scale,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Text(
                                _formatPrice(depositAmount),
                                style: AppTextStyles.tinos(
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.payment,
                            size: 32 * scale,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummarySection extends StatelessWidget {
  final String title;
  final Widget child;

  const _SummarySection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ).copyWith(letterSpacing: 0.5),
          ),
          SizedBox(height: 12 * scale),
          child,
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  final String label;
  final DateTime date;
  final double scale;

  const _DateRow({
    required this.label,
    required this.date,
    required this.scale,
  });

  String _formatDate(DateTime date) {
    final days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return '${days[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8 * scale),
          ),
          child: Text(
            _formatDate(date),
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double amount;
  final double scale;
  final bool isTotal;

  const _PriceRow({
    required this.label,
    required this.amount,
    required this.scale,
    this.isTotal = false,
  });

  String _formatPrice(double price) {
    final priceInt = price.toInt();
    final priceStr = priceInt.toString();
    
    // Format with thousand separators
    final buffer = StringBuffer();
    final length = priceStr.length;
    
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    
    return buffer.toString() + AppStrings.currencyUnit;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: isTotal ? 16 * scale : 14 * scale,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          _formatPrice(amount),
          style: AppTextStyles.arimo(
            fontSize: isTotal ? 18 * scale : 14 * scale,
            fontWeight: FontWeight.bold,
            color: isTotal ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/app_responsive.dart';
import '../../../../../core/utils/app_text_styles.dart';
import '../../../domain/entities/booking_entity.dart';
import '../../bloc/booking_bloc.dart';
import '../../bloc/booking_event.dart';
import '../../bloc/booking_state.dart';
import '../../screens/payment_screen.dart';

class ContractPaymentCard extends StatelessWidget {
  final BookingEntity booking;
  final String Function(double) formatPrice;
  final String Function(String) getContractStatusLabel;

  const ContractPaymentCard({
    super.key,
    required this.booking,
    required this.formatPrice,
    required this.getContractStatusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final contract = booking.contract;
    final remainingAmount = booking.remainingAmount;

    if (contract == null) {
      return const SizedBox.shrink();
    }

    // Calculate deposit paid amount
    final depositPaid = booking.transactions
        .where((t) => t.type == 'Deposit' && t.status == 'Paid')
        .fold<double>(0, (sum, t) => sum + t.amount);

    return Container(
      padding: EdgeInsets.all(20 * scale),
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
          // Header: Contract label and status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.contractTitle,
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: Text(
                  getContractStatusLabel(contract.status),
                  style: AppTextStyles.arimo(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          // Contract code
          Text(
            contract.contractCode,
            style: AppTextStyles.tinos(
              fontSize: 20 * scale,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16 * scale),
          // Deposit paid section
          Container(
            padding: EdgeInsets.all(14 * scale),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.servicesDepositPaid,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    Text(
                      formatPrice(depositPaid),
                      style: AppTextStyles.tinos(
                        fontSize: 20 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.receipt_long_rounded,
                  size: 28 * scale,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),
          // Remaining payment message
          Text(
            AppStrings.servicesRemainingPaymentMessage,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          // Pay remaining button (only show if contract is signed and there's remaining amount)
          if (contract.status == 'Signed' && remainingAmount > 0) ...[
            SizedBox(height: 18 * scale),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handlePayRemaining(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                ),
                child: Text(
                  AppStrings.servicesPayRemaining,
                  style: AppTextStyles.arimo(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handlePayRemaining(BuildContext context) {
    final bookingBloc = context.read<BookingBloc>();
    
    // Ensure BookingBloc has the booking loaded
    final currentState = bookingBloc.state;
    if (currentState is! BookingLoaded) {
      bookingBloc.add(BookingLoadById(booking.id));
    }

    // Navigate to payment screen with Remaining payment type
    // PaymentScreen will automatically create payment link via API
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: bookingBloc,
          child: PaymentScreen(
            booking: booking,
            paymentType: 'Remaining',
          ),
        ),
      ),
    );
  }
}

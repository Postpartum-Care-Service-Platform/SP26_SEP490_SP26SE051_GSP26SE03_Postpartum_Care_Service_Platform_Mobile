import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../auth/data/models/current_account_model.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../booking/presentation/screens/payment_screen.dart';
import 'resort_key_card.dart';
import 'services_formatters.dart';

class CurrentPackageView extends StatelessWidget {
  final NowPackageModel nowPackage;

  const CurrentPackageView({
    super.key,
    required this.nowPackage,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final isFullyPaid = nowPackage.remainingAmount <= 0;

    return SafeArea(
      child: SingleChildScrollView(
        padding:
            EdgeInsets.fromLTRB(20 * scale, 16 * scale, 20 * scale, 24 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, scale),
            if (isFullyPaid)
              Text(
                AppStrings.servicesAwaitingActivationMessage,
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              )
            else
              Text(
                AppStrings.servicesPendingPaymentMessage,
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            SizedBox(height: 20 * scale),
            ResortKeyCard(nowPackage: nowPackage),
            SizedBox(height: 16 * scale),
            AppWidgets.sectionContainer(
              context,
              padding: EdgeInsets.all(18 * scale),
              children: [
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
                        formatContractStatus(nowPackage.contractStatus),
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
                Text(
                  nowPackage.contractCode,
                  style: AppTextStyles.tinos(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Container(
                  padding: EdgeInsets.all(14 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.invoicePaidAmount,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            formatPrice(nowPackage.paidAmount),
                            style: AppTextStyles.tinos(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10 * scale),
                      Divider(height: 1, color: AppColors.borderLight),
                      SizedBox(height: 10 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.invoiceRemainingAmount,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            formatPrice(nowPackage.remainingAmount),
                            style: AppTextStyles.tinos(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  isFullyPaid
                      ? AppStrings.servicesAwaitingActivationMessage
                      : AppStrings.servicesRemainingPaymentMessage,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 18 * scale),
                if (isFullyPaid)
                  AppWidgets.primaryButton(
                    text: 'Chờ check-in',
                    isEnabled: false,
                    onPressed: () {},
                  )
                else
                  _PayRemainingButton(nowPackage: nowPackage),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: Row(
        children: [
          SizedBox(
            width: 52 * scale,
            child: const SizedBox.shrink(),
          ),
          Expanded(
            child: Text(
              AppStrings.bookingTitle,
              style: AppTextStyles.tinos(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 52 * scale),
        ],
      ),
    );
  }
}

class _PayRemainingButton extends StatefulWidget {
  final NowPackageModel nowPackage;

  const _PayRemainingButton({
    required this.nowPackage,
  });

  @override
  State<_PayRemainingButton> createState() => _PayRemainingButtonState();
}

class _PayRemainingButtonState extends State<_PayRemainingButton> {
  bool _isSubmitting = false;
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final nowPackage = widget.nowPackage;
    final isEnabled =
        nowPackage.contractStatus == 'Signed' && nowPackage.remainingAmount > 0;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (!mounted || _hasNavigated == true) return;

        if (state is BookingLoaded && state.booking.id == nowPackage.bookingId) {
          _hasNavigated = true;
          _isSubmitting = false;

          final bookingBloc = context.read<BookingBloc>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bookingBloc,
                child: PaymentScreen(
                  booking: state.booking,
                  paymentType: 'Remaining',
                ),
              ),
            ),
          );
        } else if (state is BookingError && _isSubmitting) {
          setState(() => _isSubmitting = false);
          AppToast.showError(context, message: state.message);
        }
      },
      child: AppWidgets.primaryButton(
        text: _isSubmitting
            ? AppStrings.processing
            : AppStrings.servicesPayRemaining,
        isEnabled: isEnabled && !_isSubmitting,
        onPressed: () {
          if (!isEnabled || _isSubmitting) return;
          setState(() {
            _isSubmitting = true;
            _hasNavigated = false;
          });
          context.read<BookingBloc>().add(BookingLoadById(nowPackage.bookingId));
        },
      ),
    );
  }
}

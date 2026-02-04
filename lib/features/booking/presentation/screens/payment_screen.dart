import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/payment_link_entity.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import 'invoice_screen.dart';
import '../widgets/payment/payment_info_card.dart';
import '../widgets/payment/qr_code_section.dart';
import '../widgets/payment/payment_status_indicator.dart';
import '../widgets/payment/payment_helpers.dart';

class PaymentScreen extends StatefulWidget {
  final BookingEntity booking;
  final String paymentType; // 'Deposit' or 'Remaining'

  const PaymentScreen({
    super.key,
    required this.booking,
    this.paymentType = 'Deposit',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentLinkEntity? _paymentLink;
  Timer? _statusCheckTimer;
  bool _isCheckingStatus = false;
  bool _paymentSuccess = false;
  int? _paidBookingId;

  @override
  void initState() {
    super.initState();
    // Create payment link after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookingBloc>().add(BookingCreatePaymentLink(widget.paymentType));
      }
    });
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusCheck(String orderCode) {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isCheckingStatus) {
        setState(() {
          _isCheckingStatus = true;
        });
        context.read<BookingBloc>().add(BookingCheckPaymentStatus(orderCode));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.paymentTitle,
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
      ),
      body: BlocConsumer<BookingBloc, BookingState>(
        listener: (context, state) {
          if (state is BookingPaymentLinkCreated) {
            setState(() {
              _paymentLink = state.paymentLink;
            });
            _startStatusCheck(state.paymentLink.orderCode);
          } else if (state is BookingPaymentStatusChecked) {
            setState(() {
              _isCheckingStatus = false;
            });

            if (state.paymentStatus.status == 'Paid' && !_paymentSuccess) {
              _statusCheckTimer?.cancel();
              _paymentSuccess = true;
              _paidBookingId = state.paymentStatus.bookingId;

              AppToast.showSuccess(context, message: AppStrings.paymentSuccess);

              // Sau 5s chuyển sang màn hình hóa đơn
              final bookingBloc = context.read<BookingBloc>();
              Timer(const Duration(seconds: 3), () {
                if (!mounted || _paidBookingId == null) return;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: bookingBloc,
                      child: InvoiceScreen(bookingId: _paidBookingId!),
                    ),
                  ),
                );
              });
            }
          } else if (state is BookingError) {
            setState(() {
              _isCheckingStatus = false;
            });
            AppToast.showError(context, message: state.message);
          }
        },
        builder: (context, state) {
          if (state is BookingLoading && _paymentLink == null) {
            return const Center(child: AppLoadingIndicator());
          }

          if (state is BookingError && _paymentLink == null) {
            return Center(
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
                    state.message,
                    style: AppTextStyles.arimo(
                      fontSize: 16 * scale,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24 * scale),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookingBloc>().add(BookingCreatePaymentLink(widget.paymentType));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(AppStrings.retry),
                  ),
                ],
              ),
            );
          }

          if (_paymentLink == null) {
            return const SizedBox();
          }

          // Khi thanh toán thành công: hiển thị màn hình success trong 5s
          if (_paymentSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80 * scale,
                    color: AppColors.verified,
                  ),
                  SizedBox(height: 24 * scale),
                  Text(
                    AppStrings.paymentSuccess,
                    style: AppTextStyles.arimo(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Đang chuyển đến hóa đơn của bạn...',
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 24 * scale),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  PaymentInfoCard(
                    paymentLink: _paymentLink!,
                    formatPrice: PaymentHelpers.formatPrice,
                  ),
                  SizedBox(height: 28 * scale),
                  QRCodeSection(paymentLink: _paymentLink!),
                  SizedBox(height: 28 * scale),
                  const PaymentStatusIndicator(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import 'booking_history_screen.dart';
import '../widgets/invoice/invoice_header.dart';
import '../widgets/invoice/customer_info_card.dart';
import '../widgets/invoice/booking_details_card.dart';
import '../widgets/invoice/price_details_card.dart';
import '../widgets/invoice/invoice_section.dart';
import '../widgets/invoice/transaction_item.dart';
import '../widgets/invoice/invoice_info_row.dart';
import '../widgets/invoice/invoice_helpers.dart';

class InvoiceScreen extends StatefulWidget {
  final int bookingId;

  const InvoiceScreen({
    super.key,
    required this.bookingId,
  });

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
  }

class _InvoiceScreenState extends State<InvoiceScreen> {
  bool _showTransactions = false;
  bool _showContract = false;


  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Always navigate to BookingHistoryScreen when back is pressed
          final bookingBloc = context.read<BookingBloc>();
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: bookingBloc,
                  child: const BookingHistoryScreen(),
                ),
              ),
            );
          }
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          AppStrings.invoiceTitle,
          style: AppTextStyles.tinos(
            fontSize: 24 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => InjectionContainer.bookingBloc
           ..add(BookingLoadById(widget.bookingId)),
        child: BlocBuilder<BookingBloc, BookingState>(
          builder: (context, state) {
            if (state is BookingLoading) {
              return const Center(child: AppLoadingIndicator());
            }

            if (state is BookingError) {
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
                         context.read<BookingBloc>().add(BookingLoadById(widget.bookingId));
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

            if (state is BookingLoaded) {
              final booking = state.booking;

              return SingleChildScrollView(
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InvoiceHeader(
                      bookingId: booking.id,
                      status: booking.status,
                      createdAt: booking.createdAt,
                      getStatusLabel: InvoiceHelpers.getStatusLabel,
                      formatDateTime: InvoiceHelpers.formatDateTime,
                    ),
                    SizedBox(height: 16 * scale),
                    if (booking.customer != null)
                      CustomerInfoCard(customer: booking.customer!),
                    if (booking.customer != null) SizedBox(height: 16 * scale),
                    BookingDetailsCard(
                      package: booking.package,
                      room: booking.room,
                      startDate: booking.startDate,
                      endDate: booking.endDate,
                      formatDate: InvoiceHelpers.formatDate,
                      ),
                    SizedBox(height: 16 * scale),
                    PriceDetailsCard(
                      totalPrice: booking.totalPrice,
                      discountAmount: booking.discountAmount,
                      finalAmount: booking.finalAmount,
                      paidAmount: booking.paidAmount,
                      remainingAmount: booking.remainingAmount,
                      formatPrice: InvoiceHelpers.formatPrice,
                    ),
                    SizedBox(height: 16 * scale),
                    if (booking.transactions.isNotEmpty)
                      InvoiceSection(
                        title: AppStrings.invoiceTransactions,
                        isExpanded: _showTransactions,
                        onToggle: () {
                          setState(() {
                            _showTransactions = !_showTransactions;
                          });
                        },
                        child: Column(
                          children: booking.transactions.map((transaction) {
                            return TransactionItem(
                              transaction: transaction,
                              formatDateTime: InvoiceHelpers.formatDateTime,
                              formatPrice: InvoiceHelpers.formatPrice,
                              getTransactionTypeLabel: InvoiceHelpers.getTransactionTypeLabel,
                              getTransactionStatusLabel: InvoiceHelpers.getTransactionStatusLabel,
                            );
                          }).toList(),
                        ),
                      ),
                    SizedBox(height: 16 * scale),
                    if (booking.contract != null)
                      InvoiceSection(
                        title: AppStrings.invoiceContract,
                        isExpanded: _showContract,
                        onToggle: () {
                          setState(() {
                            _showContract = !_showContract;
                          });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InvoiceInfoRow(
                              icon: Icons.description,
                              label: AppStrings.invoiceContractCode,
                              value: booking.contract!.contractCode,
                            ),
                            SizedBox(height: 8 * scale),
                            InvoiceInfoRow(
                              icon: Icons.info,
                              label: AppStrings.invoiceContractStatus,
                              value: InvoiceHelpers.getContractStatusLabel(booking.contract!.status),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
      ),
    );
  }
}

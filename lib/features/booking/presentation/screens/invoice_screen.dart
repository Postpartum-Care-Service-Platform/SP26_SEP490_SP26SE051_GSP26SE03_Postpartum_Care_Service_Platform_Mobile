import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/invoice/booking_details_card.dart';
import '../widgets/invoice/customer_info_card.dart';
import '../widgets/invoice/invoice_header.dart';
import '../widgets/invoice/invoice_helpers.dart';
import '../widgets/invoice/price_details_card.dart';
import '../widgets/invoice/transaction_item.dart';

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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _paneTitles = [
    'Chi tiết đặt phòng',
    'Thông tin khách hàng',
    'Giao dịch và hợp đồng',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return PopScope(
      canPop: true,
      child: BlocProvider(
        create: (context) => InjectionContainer.bookingBloc
          ..add(BookingLoadById(widget.bookingId)),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppAppBar(
            title: AppStrings.invoiceTitle,
            centerTitle: true,
            titleFontSize: 20 * scale,
            titleFontWeight: FontWeight.w700,
            onBackPressed: _navigateBack,
          ),
          body: BlocBuilder<BookingBloc, BookingState>(
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
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                        child: Text(
                          state.message,
                          style: AppTextStyles.arimo(
                            fontSize: 16 * scale,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 24 * scale),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<BookingBloc>()
                              .add(BookingLoadById(widget.bookingId));
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

                return SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          16 * scale,
                          16 * scale,
                          16 * scale,
                          0,
                        ),
                        child: InvoiceHeader(
                          bookingId: booking.id,
                          status: booking.status,
                          createdAt: booking.createdAt,
                          getStatusLabel: InvoiceHelpers.getStatusLabel,
                          formatDateTime: InvoiceHelpers.formatDateTime,
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                        child: _PaneTabs(
                          currentIndex: _currentPage,
                          onTap: _goToPane,
                          scale: scale,
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          children: [
                            _PaneScaffold(
                              scale: scale,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BookingDetailsCard(
                                    package: booking.package,
                                    room: booking.room,
                                    startDate: booking.startDate,
                                    endDate: booking.endDate,
                                    formatDate: InvoiceHelpers.formatDate,
                                  ),
                                  SizedBox(height: 12 * scale),
                                  PriceDetailsCard(
                                    totalPrice: booking.totalPrice,
                                    discountAmount: booking.discountAmount,
                                    finalAmount: booking.finalAmount,
                                    paidAmount: booking.paidAmount,
                                    remainingAmount: booking.remainingAmount,
                                    formatPrice: InvoiceHelpers.formatPrice,
                                  ),
                                ],
                              ),
                            ),
                            _PaneScaffold(
                              scale: scale,
                              child: booking.customer != null
                                  ? CustomerInfoCard(customer: booking.customer!)
                                  : _PaneEmpty(
                                      label: 'Chưa có thông tin khách hàng',
                                      scale: scale,
                                    ),
                            ),
                            _PaneScaffold(
                              scale: scale,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Transactions
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16 * scale),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius:
                                          BorderRadius.circular(16 * scale),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 12 * scale,
                                          offset: Offset(0, 4 * scale),
                                        ),
                                      ],
                                    ),
                                    child: booking.transactions.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppStrings.invoiceTransactions,
                                                style: AppTextStyles.arimo(
                                                  fontSize: 13 * scale,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              SizedBox(height: 10 * scale),
                                              Column(
                                                children: booking.transactions
                                                    .map((transaction) {
                                                  return TransactionItem(
                                                    transaction: transaction,
                                                    formatDateTime: InvoiceHelpers
                                                        .formatDateTime,
                                                    formatPrice:
                                                        InvoiceHelpers.formatPrice,
                                                    getTransactionTypeLabel:
                                                        InvoiceHelpers
                                                            .getTransactionTypeLabel,
                                                    getTransactionStatusLabel:
                                                        InvoiceHelpers
                                                            .getTransactionStatusLabel,
                                                  );
                                                }).toList(),
                                              ),
                                            ],
                                          )
                                        : _PaneEmpty(
                                            label: 'Chưa có giao dịch',
                                            scale: scale,
                                          ),
                                  ),
                                  SizedBox(height: 12 * scale),
                                  // Contract
                                  if (booking.contract != null &&
                                      booking.contract!.fileUrl != null)
                                    Material(
                                      color: AppColors.white,
                                      borderRadius:
                                          BorderRadius.circular(16 * scale),
                                      child: InkWell(
                                        borderRadius:
                                            BorderRadius.circular(16 * scale),
                                        onTap: () => _openContract(
                                            booking.contract!.fileUrl!),
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(16 * scale),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    EdgeInsets.all(10 * scale),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12 * scale),
                                                ),
                                                child: Icon(
                                                  Icons.receipt_long_rounded,
                                                  color: AppColors.primary,
                                                  size: 20 * scale,
                                                ),
                                              ),
                                              SizedBox(width: 12 * scale),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppStrings.invoiceContract,
                                                      style:
                                                          AppTextStyles.arimo(
                                                        fontSize: 12 * scale,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4 * scale),
                                                    Text(
                                                      booking.contract!
                                                          .contractCode,
                                                      maxLines: 1,
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      style:
                                                          AppTextStyles.tinos(
                                                        fontSize: 18 * scale,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 12 * scale),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                color: AppColors.textSecondary,
                                                size: 22 * scale,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    _PaneEmpty(
                                      label: 'Chưa có hợp đồng',
                                      scale: scale,
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
              }

              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void _goToPane(int index) {
    if (index == _currentPage) return;
    final diff = (index - _currentPage).abs();
    setState(() => _currentPage = index);

    // If jumping across multiple panes, jump directly (no sequential slide)
    if (diff > 1) {
      _pageController.jumpToPage(index);
      return;
    }

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openContract(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateBack() {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}

class _PaneTabs extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final double scale;

  const _PaneTabs({
    required this.currentIndex,
    required this.onTap,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    final items = _InvoiceScreenState._paneTitles;

    return Container(
      padding: EdgeInsets.all(4 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = index == currentIndex;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3 * scale),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12 * scale),
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(
                      vertical: 10 * scale,
                      horizontal: 10 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12 * scale),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      items[index],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.arimo(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w700,
                        color: selected ? AppColors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PaneScaffold extends StatelessWidget {
  final Widget child;
  final double scale;

  const _PaneScaffold({
    required this.child,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16 * scale, 0, 16 * scale, 16 * scale),
      child: child,
    );
  }
}

class _PaneEmpty extends StatelessWidget {
  final String label;
  final double scale;

  const _PaneEmpty({
    required this.label,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}


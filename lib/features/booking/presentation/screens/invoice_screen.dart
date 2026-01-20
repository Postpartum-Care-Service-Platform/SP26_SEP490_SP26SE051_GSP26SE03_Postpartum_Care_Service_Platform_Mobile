import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import 'booking_history_screen.dart';
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
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
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
      child: BlocProvider(
        create: (context) => InjectionContainer.bookingBloc
          ..add(BookingLoadById(widget.bookingId)),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary, size: 22 * scale),
              onPressed: _navigateBack,
              tooltip: 'Quay lại',
            ),
            title: Text(
              AppStrings.invoiceTitle,
              style: AppTextStyles.tinos(
                fontSize: 24 * scale,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
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

                return SingleChildScrollView(
                  padding: EdgeInsets.all(16 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fixed invoice header card
                      InvoiceHeader(
                        bookingId: booking.id,
                        status: booking.status,
                        createdAt: booking.createdAt,
                        getStatusLabel: InvoiceHelpers.getStatusLabel,
                        formatDateTime: InvoiceHelpers.formatDateTime,
                      ),
                      SizedBox(height: 16 * scale),

                      // Pager controls
                      _PaneTabs(
                        currentIndex: _currentPage,
                        onTap: _animateToPage,
                        scale: scale,
                      ),
                      SizedBox(height: 12 * scale),

                      // Pager content
                      SizedBox(
                        height: 520 * scale,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                          },
                          children: [
                            _PaneScaffold(
                              title: _paneTitles[0],
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
                              title: _paneTitles[1],
                              scale: scale,
                              child: booking.customer != null
                                  ? CustomerInfoCard(customer: booking.customer!)
                                  : _PaneEmpty(
                                      label: 'Chưa có thông tin khách hàng',
                                      scale: scale,
                                    ),
                            ),
                            _PaneScaffold(
                              title: _paneTitles[2],
                              scale: scale,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(16 * scale),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.background,
                                          AppColors.white,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16 * scale),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 12 * scale,
                                          offset: Offset(0, 4 * scale),
                                        ),
                                      ],
                                    ),
                                    child: booking.transactions.isNotEmpty
                                        ? Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                                    formatDateTime:
                                                        InvoiceHelpers.formatDateTime,
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
                                  if (booking.contract != null &&
                                      booking.contract!.fileUrl != null)
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(16 * scale),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.background,
                                            AppColors.white,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16 * scale),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 12 * scale,
                                            offset: Offset(0, 4 * scale),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(8 * scale),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(12 * scale),
                                                ),
                                                child: Icon(
                                                  Icons.receipt_long_rounded,
                                                  color: AppColors.primary,
                                                  size: 18 * scale,
                                                ),
                                              ),
                                              SizedBox(width: 10 * scale),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      AppStrings.invoiceContract,
                                                      style: AppTextStyles.arimo(
                                                        fontSize: 13 * scale,
                                                        fontWeight: FontWeight.w700,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4 * scale),
                                                    Text(
                                                      booking.contract!.contractCode,
                                                      style: AppTextStyles.tinos(
                                                        fontSize: 20 * scale,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 10 * scale),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 10 * scale,
                                                  vertical: 5 * scale,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.white,
                                                  borderRadius: BorderRadius.circular(20 * scale),
                                                  border: Border.all(
                                                    color: AppColors.borderLight,
                                                  ),
                                                ),
                                                child: Text(
                                                  InvoiceHelpers.getContractStatusLabel(
                                                    booking.contract!.status,
                                                  ),
                                                  style: AppTextStyles.arimo(
                                                    fontSize: 11 * scale,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8 * scale),
                                              InkWell(
                                                borderRadius: BorderRadius.circular(16 * scale),
                                                onTap: () => _openContract(booking.contract!.fileUrl!),
                                                child: Container(
                                                  padding: EdgeInsets.all(8 * scale),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary.withValues(alpha: 0.12),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.visibility_rounded,
                                                    color: AppColors.primary,
                                                    size: 20 * scale,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 6 * scale),
                                          Divider(height: 1, color: AppColors.borderLight),
                                          SizedBox(height: 8 * scale),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Tap để xem chi tiết',
                                                style: AppTextStyles.arimo(
                                                  fontSize: 11.5 * scale,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.link_rounded,
                                                    size: 14 * scale,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  SizedBox(width: 4 * scale),
                                                  Text(
                                                    'Mở file',
                                                    style: AppTextStyles.arimo(
                                                      fontSize: 12 * scale,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
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

  void _animateToPage(int index) {
    setState(() => _currentPage = index);
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

    return Row(
      children: List.generate(items.length, (index) {
        final selected = index == currentIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onTap(index),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: 10 * scale,
                horizontal: 12 * scale,
              ),
              margin: EdgeInsets.only(right: index == items.length - 1 ? 0 : 8 * scale),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.borderLight,
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                items[index],
                textAlign: TextAlign.center,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _PaneScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final double scale;

  const _PaneScaffold({
    required this.title,
    required this.child,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: SingleChildScrollView(child: child),
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


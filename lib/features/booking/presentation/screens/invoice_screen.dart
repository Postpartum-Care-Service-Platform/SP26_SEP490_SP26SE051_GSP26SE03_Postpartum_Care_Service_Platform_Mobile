import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../widgets/invoice/booking_details_card.dart';
import '../widgets/invoice/customer_info_card.dart';
import '../widgets/invoice/invoice_header.dart';
import '../widgets/invoice/invoice_helpers.dart';
import '../../../contract/presentation/bloc/contract_bloc.dart';
import '../../../contract/presentation/bloc/contract_event.dart';
import '../../../contract/presentation/bloc/contract_state.dart';
import '../widgets/invoice/price_details_card.dart';
import '../widgets/invoice/transaction_item.dart';
import 'booking_history_screen.dart';

class InvoiceScreen extends StatefulWidget {
  final int bookingId;

  const InvoiceScreen({super.key, required this.bookingId});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _paneTitles = [
    AppStrings.invoiceBookingDetails,
    AppStrings.invoiceCustomerInformation,
    AppStrings.invoiceTransactionsAndContract,
  ];

  @override
  void initState() {
    super.initState();
    // Ensure current BookingBloc loads this booking when invoice opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BookingBloc>().add(BookingLoadById(widget.bookingId));
    });
  }

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
                        context.read<BookingBloc>().add(
                          BookingLoadById(widget.bookingId),
                        );
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
                                ? CustomerInfoCard(
                                    customer: booking.customer!,
                                    targetBookings: booking.targetBookings,
                                  )
                                : _PaneEmpty(
                                    label: AppStrings.noCustomerInformation,
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
                                    borderRadius: BorderRadius.circular(
                                      16 * scale,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.05,
                                        ),
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
                                              children: booking.transactions.map((
                                                transaction,
                                              ) {
                                                return TransactionItem(
                                                  transaction: transaction,
                                                  formatDateTime: InvoiceHelpers
                                                      .formatDateTime,
                                                  formatPrice: InvoiceHelpers
                                                      .formatPrice,
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
                                          label: AppStrings.noTransactions,
                                          scale: scale,
                                        ),
                                ),
                                SizedBox(height: 12 * scale),
                                // Contract
                                if (booking.contract != null)
                                  Material(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(
                                      16 * scale,
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                        16 * scale,
                                      ),
                                      onTap: () => _openContract(
                                        booking.id, // pass booking id instead of full url
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(16 * scale),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(
                                                10 * scale,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      12 * scale,
                                                    ),
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
                                                    style: AppTextStyles.arimo(
                                                      fontSize: 12 * scale,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4 * scale),
                                                  Text(
                                                    booking
                                                        .contract!
                                                        .contractCode,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: AppTextStyles.tinos(
                                                      fontSize: 18 * scale,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.textPrimary,
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
                                    label: AppStrings.noContract,
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

  Future<void> _openContract(int bookingId) async {
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ContractHtmlViewerScreen(bookingId: bookingId),
      ),
    );
  }

  void _navigateBack() {
    if (!context.mounted) return;

    // Sau khi xem hóa đơn, luôn quay về lịch sử booking
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
    );
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
                        color: selected
                            ? AppColors.white
                            : AppColors.textSecondary,
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

  const _PaneScaffold({required this.child, required this.scale});

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

  const _PaneEmpty({required this.label, required this.scale});

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

class _ContractHtmlViewerScreen extends StatefulWidget {
  final int bookingId;

  const _ContractHtmlViewerScreen({required this.bookingId});

  @override
  State<_ContractHtmlViewerScreen> createState() => _ContractHtmlViewerScreenState();
}

class _ContractHtmlViewerScreenState extends State<_ContractHtmlViewerScreen> {

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (context) => InjectionContainer.contractBloc
        ..add(ContractLoadByBookingId(widget.bookingId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: 'Hợp đồng',
          centerTitle: true,
          titleFontSize: 20 * scale,
          titleFontWeight: FontWeight.w700,
        ),
        body: BlocBuilder<ContractBloc, ContractState>(
          builder: (context, state) {
            if (state is ContractLoading) {
              return const Center(
                child: AppLoadingIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is ContractError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.red,
                        size: 44 * scale,
                      ),
                      SizedBox(height: 12 * scale),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<ContractBloc>()
                              .add(ContractLoadByBookingId(widget.bookingId));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        child: Text(
                          AppStrings.retry,
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ContractLoaded) {
              final contract = state.contract;
              String contentHtml = contract.htmlContent ?? '';
              
              // Tự động phân tích và đưa phần chữ ký 2 bên ngang hàng nếu nó đang bị dọc
              if (contentHtml.isNotEmpty && 
                  contentHtml.contains('ĐẠI DIỆN BÊN A') && 
                  contentHtml.contains('ĐẠI DIỆN BÊN B')) {
                
                int indexA = contentHtml.indexOf('ĐẠI DIỆN BÊN A');
                int indexB = contentHtml.indexOf('ĐẠI DIỆN BÊN B');
                
                if (indexA != -1 && indexB != -1 && indexA < indexB) {
                  int startIndex = contentHtml.lastIndexOf('<p', indexA);
                  if (startIndex == -1) startIndex = contentHtml.lastIndexOf('<div', indexA);
                  if (startIndex == -1) startIndex = indexA;
                  
                  int signatureTextB = contentHtml.indexOf('(Ký, ghi rõ họ tên)', indexB);
                  if (signatureTextB != -1) {
                    int endIndex = contentHtml.indexOf('</p>', signatureTextB);
                    if (endIndex == -1) endIndex = contentHtml.indexOf('</div>', signatureTextB);
                    if (endIndex != -1) {
                      endIndex += 4; // bỏ qua < / p >
                    } else {
                      endIndex = signatureTextB + '(Ký, ghi rõ họ tên)'.length;
                    }
                    
                    String originalSignaturesBlock = contentHtml.substring(startIndex, endIndex);
                    int startBInBlock = originalSignaturesBlock.indexOf('ĐẠI DIỆN BÊN B');
                    
                    if (startBInBlock > 0) {
                      int splitIndex = originalSignaturesBlock.lastIndexOf('<p', startBInBlock);
                      if (splitIndex == -1) splitIndex = originalSignaturesBlock.lastIndexOf('<div', startBInBlock);
                      if (splitIndex <= 0) splitIndex = startBInBlock;
                      
                      String blockA = originalSignaturesBlock.substring(0, splitIndex).trim();
                      String blockB = originalSignaturesBlock.substring(splitIndex).trim();
                      
                      // Inject class "no-border" to override td borders
                      String tableHtml = '''
                      <table class="signature-table no-border" style="width:100%; margin-top:32px;">
                        <tr class="no-border">
                          <td class="no-border" style="width:50%;">
                            $blockA
                          </td>
                          <td class="no-border" style="width:50%;">
                            $blockB
                          </td>
                        </tr>
                      </table>
                      ''';
                      
                      contentHtml = contentHtml.replaceFirst(originalSignaturesBlock, tableHtml);
                    }
                  }
                }
              }

              if (contentHtml.isEmpty) {
                return Center(
                  child: Text(
                    'Hợp đồng chưa có nội dung chi tiết.',
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 24 * scale,
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10 * scale,
                        offset: Offset(0, 4 * scale),
                      )
                    ],
                  ),
                  child: HtmlWidget(
                    contentHtml,
                    textStyle: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      color: AppColors.textPrimary,
                    ),
                    customStylesBuilder: (element) {
                      final tag = element.localName?.toLowerCase();
                      final className = element.className;
                      
                      switch (tag) {
                        case 'h1':
                          return {
                            'font-weight': 'bold',
                            'font-size': '18px',
                            'margin-top': '16px',
                            'margin-bottom': '12px',
                            'color': '#1a1a1a',
                            'text-align': 'center',
                          };
                        case 'h2':
                        case 'h3':
                          return {
                            'font-weight': 'bold',
                            'font-size': '16px',
                            'margin-top': '12px',
                            'margin-bottom': '8px',
                            'color': '#1a1a1a',
                          };
                        case 'p':
                          return {
                            'margin-top': '8px',
                            'margin-bottom': '8px',
                            'line-height': '1.6',
                            'text-align': 'justify',
                          };
                        case 'table':
                          if (className.contains('no-border')) {
                            return {
                              'width': '100%',
                              'margin-top': '24px',
                            };
                          }
                          return {
                            'width': '100%',
                            'border-collapse': 'collapse',
                            'margin-top': '12px',
                            'margin-bottom': '12px',
                          };
                        case 'th':
                          return {
                            'padding': '10px 8px',
                            'border': '1px solid #d1d5db',
                            'background-color': '#f3f4f6',
                            'font-weight': '600',
                            'text-align': 'left',
                          };
                        case 'td':
                          if (className.contains('no-border')) {
                            return {
                              'padding': '0',
                              'border': 'none',
                              'vertical-align': 'top',
                              'text-align': 'center',
                            };
                          }
                          return {
                            'padding': '10px 8px',
                            'border': '1px solid #e5e7eb',
                            'vertical-align': 'top',
                          };
                        default:
                          if (className.contains('title')) {
                            return {
                              'font-weight': 'bold',
                              'font-size': '16px',
                              'margin-bottom': '8px',
                            };
                          }
                          return null;
                      }
                    },
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

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
import 'invoice_screen.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../widgets/booking_history/booking_card.dart';
import '../widgets/booking_history/booking_history_helpers.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (context) =>
          InjectionContainer.bookingBloc..add(const BookingLoadAll()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: AppStrings.bookingHistory,
          centerTitle: true,
          titleFontSize: 20 * scale,
          titleFontWeight: FontWeight.w700,
          onBackPressed: () {
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) =>
                      const AppScaffold(initialTab: AppBottomTab.profile),
                ),
                (route) => false,
              );
            }
          },
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
                        context.read<BookingBloc>().add(const BookingLoadAll());
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

            if (state is BookingsLoaded) {
              final bookings = state.bookings;

              if (bookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 64 * scale,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        'Chưa có lịch sử đặt phòng',
                        style: AppTextStyles.arimo(
                          fontSize: 16 * scale,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16 * scale),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingCard(
                    booking: booking,
                    formatPrice: BookingHistoryHelpers.formatPrice,
                    formatDate: BookingHistoryHelpers.formatDate,
                    getStatusLabel: BookingHistoryHelpers.getStatusLabel,
                    getStatusColor: BookingHistoryHelpers.getStatusColor,
                    onTap: () {
                      // Get BookingBloc from context to share with InvoiceScreen
                      final bookingBloc = context.read<BookingBloc>();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: bookingBloc,
                            child: InvoiceScreen(bookingId: booking.id),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            // Trạng thái mặc định hoặc chưa xác định: hiển thị loading thay vì màn trắng
            return const Center(child: AppLoadingIndicator());
          },
        ),
      ),
    );
  }
}

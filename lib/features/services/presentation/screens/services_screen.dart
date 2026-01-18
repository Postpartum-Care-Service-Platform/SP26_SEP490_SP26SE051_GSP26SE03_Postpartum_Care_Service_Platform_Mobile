import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../booking/presentation/widgets/booking_step_indicator.dart';
import '../../../booking/presentation/widgets/booking_step1_package_selection.dart';
import '../../../booking/presentation/widgets/booking_step2_room_selection.dart';
import '../../../booking/presentation/widgets/booking_step3_date_selection.dart';
import '../../../booking/presentation/widgets/booking_step4_summary.dart';
import '../../../booking/presentation/screens/payment_screen.dart';
import '../../../booking/presentation/screens/invoice_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  int _currentStep = 0;
  double? _cachedEstimatedPrice;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InjectionContainer.bookingBloc
        ..add(const BookingLoadPackages()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingCreated) {
              // Get BookingBloc from listener context before navigating
              final bookingBloc = context.read<BookingBloc>();
              // Navigate to payment screen
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: bookingBloc,
                    child: PaymentScreen(booking: state.booking),
                  ),
                ),
              );
            } else if (state is BookingPaymentStatusChecked) {
              if (state.paymentStatus.status == 'Paid') {
                // Get BookingBloc from listener context before navigating
                final bookingBloc = context.read<BookingBloc>();
                // Navigate to invoice screen
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: bookingBloc,
                      child: InvoiceScreen(bookingId: state.paymentStatus.bookingId),
                    ),
                  ),
                );
              }
            } else if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                // Custom header
                _buildCustomHeader(context),
                // Step indicator
                BookingStepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 4,
                ),
                // Step content
                Expanded(
                  child: _buildStepContent(context, state),
                ),
                // Navigation buttons
                _buildNavigationButtons(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, BookingState state) {
    // Ensure correct state is loaded when navigating to each step
    switch (_currentStep) {
      case 0:
        // Ensure packages are loaded
        if (state is! BookingPackagesLoaded && state is! BookingSummaryReady) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(const BookingLoadPackages());
            }
          });
        }
        return BookingStep1PackageSelection(
          onPackageSelected: (packageId) {
            context.read<BookingBloc>().add(BookingSelectPackage(packageId));
          },
        );
      case 1:
        // Ensure rooms are loaded
        if (state is! BookingRoomsLoaded && state is! BookingSummaryReady) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(const BookingLoadRooms());
            }
          });
        }
        // Ensure packages are loaded to get estimated price
        if (state is! BookingPackagesLoaded && state is! BookingSummaryReady && _cachedEstimatedPrice == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(const BookingLoadPackages());
            }
          });
        }
        return BookingStep2RoomSelection(
          onRoomSelected: (roomId) {
            context.read<BookingBloc>().add(BookingSelectRoom(roomId));
          },
        );
      case 2:
        // Ensure packages are loaded to get estimated price
        if (state is! BookingPackagesLoaded && state is! BookingSummaryReady && _cachedEstimatedPrice == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(const BookingLoadPackages());
            }
          });
        }
        return BookingStep3DateSelection(
          onDateSelected: (date) {
            context.read<BookingBloc>().add(BookingSelectDate(date));
          },
        );
      case 3:
        return BookingStep4Summary(
          onConfirm: () {
            context.read<BookingBloc>().add(const BookingCreateBooking());
          },
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildNavigationButtons(BuildContext context, BookingState state) {
    final scale = AppResponsive.scaleFactor(context);
    final estimatedPrice = _getEstimatedPrice(state);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(4 * scale, 2 * scale, 4 * scale, 2 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8 * scale,
              offset: Offset(0, -2 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            // Giá tạm tính - 30% width
            Expanded(
              flex: 4,
              child: _buildEstimatedPrice(estimatedPrice, scale),
            ),
            SizedBox(width: 12 * scale),
            // Nút Tiếp theo - 70% width
            Expanded(
              flex: 6,
              child: _buildNextButton(context, state, scale),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedPrice(double? price, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.bookingEstimatedPrice,
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            price != null ? _formatPrice(price) : '--',
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: price != null ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, BookingState state, double scale) {
    return ElevatedButton(
            onPressed: _canProceed(state)
                ? () {
                    if (_currentStep < 3) {
                      setState(() {
                        _currentStep++;
                      });
                      // Load rooms when moving to step 2
                      if (_currentStep == 1) {
                        context.read<BookingBloc>().add(const BookingLoadRooms());
                      }
              } else if (_currentStep == 3) {
                // Step 4: Confirm booking
                context.read<BookingBloc>().add(const BookingCreateBooking());
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.borderLight,
              disabledForegroundColor: AppColors.textSecondary,
              padding: EdgeInsets.symmetric(vertical: 12 * scale),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              minimumSize: Size(0, 48 * scale),
              elevation: _canProceed(state) ? 2 : 0,
            ),
            child: Text(
              _currentStep == 3
                  ? AppStrings.bookingConfirm
                  : AppStrings.bookingNext,
              style: AppTextStyles.arimo(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w600,
                color: _canProceed(state)
                    ? AppColors.white
                    : AppColors.textSecondary,
        ),
      ),
    );
  }

  double? _getEstimatedPrice(BookingState state) {
    // Priority 1: Get from SummaryReady (most complete state)
    if (state is BookingSummaryReady) {
      _cachedEstimatedPrice = state.package.basePrice;
      return _cachedEstimatedPrice;
    }
    
    // Priority 2: Get from PackagesLoaded with selected package
    if (state is BookingPackagesLoaded && 
        state.selectedPackageId != null && 
        state.packages.isNotEmpty) {
      try {
        final package = state.packages.firstWhere(
          (p) => p.id == state.selectedPackageId,
        );
        _cachedEstimatedPrice = package.basePrice;
        return _cachedEstimatedPrice;
      } catch (e) {
        // If package not found but we have cached price, return cached
        return _cachedEstimatedPrice;
      }
    }
    
    // Priority 3: For other states (RoomsLoaded, DateSelected), use cached price
    // If no cached price, trigger package load to get the price
    if (state is BookingRoomsLoaded || state is BookingDateSelected) {
      if (_cachedEstimatedPrice != null) {
        return _cachedEstimatedPrice;
      }
      // Trigger package load to get price (will be handled by step content)
      // For now, return null and let the UI show '--'
      // The price will be updated once packages are loaded
    }
    
    // Fallback: Return cached price if available
    return _cachedEstimatedPrice;
  }

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

  bool _canProceed(BookingState state) {
    switch (_currentStep) {
      case 0:
        return state is BookingPackagesLoaded && state.selectedPackageId != null;
      case 1:
        return (state is BookingRoomsLoaded && state.selectedRoomId != null) ||
               (state is BookingSummaryReady);
      case 2:
        return state is BookingDateSelected || state is BookingSummaryReady;
      case 3:
        return state is BookingSummaryReady;
      default:
        return false;
    }
  }

  Widget _buildCustomHeader(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    return SafeArea(
      bottom: false,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20 * scale,
          vertical: 12 * scale,
        ),
        child: Row(
          children: [
            // Back button area - always reserve space (40 + 12 = 52)
            SizedBox(
              width: 52 * scale,
              child: _currentStep > 0
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      child: Container(
                        width: 30 * scale,
                        height: 30 * scale,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20 * scale,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Title - always centered
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
            // Right spacer - always reserve same space as left (52)
            SizedBox(width: 52 * scale),
          ],
        ),
      ),
    );
  }
}

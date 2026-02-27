import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
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
import 'services_formatters.dart';
import 'service_location_selection.dart';

class ServicesBookingFlow extends StatefulWidget {
  final ServiceLocationType? locationType;
  final VoidCallback? onConfirmOverride;

  const ServicesBookingFlow({
    super.key,
    this.locationType,
    this.onConfirmOverride,
  });

  @override
  State<ServicesBookingFlow> createState() => _ServicesBookingFlowState();
}

class _ServicesBookingFlowState extends State<ServicesBookingFlow> {
  int _currentStep = 0;
  double? _cachedEstimatedPrice;
  bool _packagesLoadRequested = false;
  bool _roomsLoadRequested = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, bookingState) {
        return Column(
          children: [
            _buildCustomHeader(context),
            BookingStepIndicator(
              currentStep: _currentStep,
              totalSteps: 4,
            ),
            Expanded(
              child: _buildStepContent(context, bookingState),
            ),
            _buildNavigationButtons(context, bookingState),
          ],
        );
      },
    );
  }

  Widget _buildStepContent(BuildContext context, BookingState state) {
    switch (_currentStep) {
      case 0:
        if (state is! BookingPackagesLoaded && 
            state is! BookingSummaryReady && 
            !_packagesLoadRequested) {
          _packagesLoadRequested = true;
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
        // Only load rooms if not already loaded
        if (state is! BookingRoomsLoaded && 
            state is! BookingSummaryReady && 
            !_roomsLoadRequested) {
          _roomsLoadRequested = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(const BookingLoadRooms());
            }
          });
        }
        // Don't reload packages here - they should already be loaded from step 0
        return BookingStep2RoomSelection(
          onRoomSelected: (roomId) {
            context.read<BookingBloc>().add(BookingSelectRoom(roomId));
          },
        );
      case 2:
        // Don't reload packages here - they should already be loaded from step 0
        return BookingStep3DateSelection(
          onDateSelected: (date) {
            context.read<BookingBloc>().add(BookingSelectDate(date));
          },
        );
      case 3:
        return BookingStep4Summary(
          onConfirm: () {
            if (widget.onConfirmOverride != null) {
              widget.onConfirmOverride!();
            } else {
              context.read<BookingBloc>().add(const BookingCreateBooking());
            }
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
            Expanded(
              flex: 4,
              child: _buildEstimatedPrice(estimatedPrice, scale),
            ),
            SizedBox(width: 12 * scale),
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
            price != null ? formatPrice(price) : AppStrings.bookingPriceNotAvailable,
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
                  // Reset flags when changing steps
                  if (_currentStep == 1) {
                    _roomsLoadRequested = false;
                  }
                });
                if (_currentStep == 1) {
                  context.read<BookingBloc>().add(const BookingLoadRooms());
                }
              } else if (_currentStep == 3) {
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
        _currentStep == 3 ? AppStrings.bookingConfirm : AppStrings.bookingNext,
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
    if (state is BookingSummaryReady) {
      _cachedEstimatedPrice = state.package.basePrice;
      return _cachedEstimatedPrice;
    }

    if (state is BookingPackagesLoaded &&
        state.selectedPackageId != null &&
        state.packages.isNotEmpty) {
      try {
        final package = state.packages.firstWhere(
          (p) => p.id == state.selectedPackageId,
        );
        _cachedEstimatedPrice = package.basePrice;
        return _cachedEstimatedPrice;
      } catch (_) {
        return _cachedEstimatedPrice;
      }
    }

    if (state is BookingRoomsLoaded || state is BookingDateSelected) {
      if (_cachedEstimatedPrice != null) {
        return _cachedEstimatedPrice;
      }
    }

    return _cachedEstimatedPrice;
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
            SizedBox(
              width: 52 * scale,
              child: _currentStep > 0
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentStep--;
                          // Reset flags when going back
                          if (_currentStep == 0) {
                            _packagesLoadRequested = false;
                          } else if (_currentStep == 1) {
                            _roomsLoadRequested = false;
                          }
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
      ),
    );
  }
}

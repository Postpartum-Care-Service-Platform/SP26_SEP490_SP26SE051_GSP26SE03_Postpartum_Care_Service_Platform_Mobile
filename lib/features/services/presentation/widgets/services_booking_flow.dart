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
import '../../../booking/presentation/widgets/booking_step2_family_profile_selection.dart';
import '../../../booking/presentation/widgets/booking_step2_room_selection.dart';
import '../../../booking/presentation/widgets/booking_step3_date_selection.dart';
import '../../../booking/presentation/widgets/booking_step4_summary.dart';
import 'services_formatters.dart';
import 'service_location_selection.dart';
import '../../../../core/widgets/app_scaffold.dart';

class ServicesBookingFlow extends StatefulWidget {
  final ServiceLocationType? locationType;
  final VoidCallback onBackToLocationSelection;
  final VoidCallback? onConfirmOverride;
  final String? familyProfilesAccountId;

  const ServicesBookingFlow({
    super.key,
    this.locationType,
    required this.onBackToLocationSelection,
    this.onConfirmOverride,
    this.familyProfilesAccountId,
  });

  @override
  State<ServicesBookingFlow> createState() => _ServicesBookingFlowState();
}

class _ServicesBookingFlowState extends State<ServicesBookingFlow> {
  int _currentStep = 0;
  double? _cachedEstimatedPrice;
  bool _packagesLoadRequested = false;
  bool _profilesLoadRequested = false;
  bool _roomsLoadRequested = false;
  bool _configLoadRequested = false;
  bool _showPriceBreakdown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        const ToggleBottomNavNotification(show: false).dispatch(context);
      }
    });
  }

  @override
  void dispose() {
    // Luôn hiển thị lại bottom nav khi thoát khỏi luồng
    const ToggleBottomNavNotification(show: true).dispatch(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, bookingState) {
        return Column(
          children: [
            _buildCustomHeader(context),
            BookingStepIndicator(
              currentStep: _currentStep,
              totalSteps: 5,
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
    if (!_configLoadRequested) {
      _configLoadRequested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<BookingBloc>().add(const BookingLoadConfig());
        }
      });
    }

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
        if (state is! BookingFamilyProfilesLoaded && !_profilesLoadRequested) {
          _profilesLoadRequested = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(
                    BookingLoadFamilyProfiles(
                      accountId: widget.familyProfilesAccountId,
                    ),
                  );
            }
          });
        }
        return BookingStep2FamilyProfileSelection(
          accountId: widget.familyProfilesAccountId,
          onSelectionChanged: (selectedIds) {
            context
                .read<BookingBloc>()
                .add(BookingSelectFamilyProfiles(selectedIds));
          },
        );
      case 2:
        return BookingStep3DateSelection(
          onDateSelected: (date) {
            context.read<BookingBloc>().add(BookingSelectDate(date));
          },
        );
      case 3:
        if (state is! BookingRoomsLoaded &&
            state is! BookingSummaryReady &&
            !_roomsLoadRequested) {
          _roomsLoadRequested = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              context.read<BookingBloc>().add(_createLoadRoomsEvent(context));
            }
          });
        }
        return BookingStep2RoomSelection(
          onRoomSelected: (roomId) {
            context.read<BookingBloc>().add(BookingSelectRoom(roomId));
          },
        );
      case 4:
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

  BookingLoadRooms _createLoadRoomsEvent(BuildContext context) {
    final bookingBloc = context.read<BookingBloc>();
    final startDate = bookingBloc.selectedDate;
    final selectedPackage = bookingBloc.selectedPackage;

    if (startDate == null) {
      return const BookingLoadRooms();
    }

    final durationDays = selectedPackage?.durationDays ?? 0;
    final endDate = durationDays > 0
        ? startDate.add(Duration(days: durationDays))
        : startDate;

    return BookingLoadRooms(startDate: startDate, endDate: endDate);
  }

  Widget _buildNavigationButtons(BuildContext context, BookingState state) {
    final scale = AppResponsive.scaleFactor(context);
    final estimatedPrice = _getEstimatedPrice(state);

    return Container(
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
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              EdgeInsets.fromLTRB(4 * scale, 2 * scale, 4 * scale, 2 * scale),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: _buildEstimatedPrice(estimatedPrice, scale),
              ),
              SizedBox(width: 8 * scale),
              Expanded(
                flex: 5,
                child: _buildNextButton(context, state, scale),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEstimatedPrice(double? price, double scale) {
    final bookingBloc = context.read<BookingBloc>();
    final selectedPackage = bookingBloc.selectedPackage;

    double basePrice = selectedPackage?.basePrice ?? 0;
    final profiles = bookingBloc.familyProfiles ?? [];
    final selectedIds = bookingBloc.selectedFamilyProfileIds;
    final babyCount = profiles
        .where((p) => selectedIds.contains(p.id) && p.memberTypeId == 3)
        .length;

    final extraPercentValue = (bookingBloc.config?.extraChildPricePercent ?? 70.0);
    final extraPercent = extraPercentValue / 100.0;
    double extraSurcharge = 0;
    if (babyCount > 1) {
      extraSurcharge = basePrice * extraPercent * (babyCount - 1);
    }

    return GestureDetector(
      onTap: extraSurcharge > 0
          ? () => setState(() => _showPriceBreakdown = !_showPriceBreakdown)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12 * scale),
          border: _showPriceBreakdown
              ? Border.all(color: AppColors.primary, width: 1.2)
              : Border.all(color: Colors.transparent, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10 * scale,
              offset: Offset(0, 4 * scale),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  AppStrings.bookingEstimatedPrice,
                  style: AppTextStyles.arimo(
                    fontSize: 10 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (extraSurcharge > 0) ...[
                  SizedBox(width: 4 * scale),
                  Icon(
                    _showPriceBreakdown
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_up_rounded,
                    size: 14 * scale,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
            if (_showPriceBreakdown && extraSurcharge > 0) ...[
              SizedBox(height: 6 * scale),
              _buildBreakdownRow(
                'Giá gói',
                formatPrice(basePrice),
                scale,
                isHighlight: false,
              ),
              SizedBox(height: 4 * scale),
              _buildBreakdownRow(
                'Phụ thu thêm (${extraPercentValue.toInt()}%)',
                '+${formatPrice(extraSurcharge)}',
                scale,
                isHighlight: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4 * scale),
                child: Divider(height: 1, color: AppColors.borderLight),
              ),
            ],
            SizedBox(height: 2 * scale),
            Text(
              price != null
                  ? formatPrice(price)
                  : AppStrings.bookingPriceNotAvailable,
              style: AppTextStyles.arimo(
                fontSize: 15 * scale,
                fontWeight: FontWeight.bold,
                color:
                    price != null ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String value,
    double scale, {
    required bool isHighlight,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 4 * scale),
        Text(
          value,
          style: AppTextStyles.arimo(
            fontSize: 11 * scale,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton(BuildContext context, BookingState state, double scale) {
    return ElevatedButton(
      onPressed: _canProceed(state)
          ? () {
              if (_currentStep < 4) {
                setState(() {
                  _currentStep++;
                  if (_currentStep == 1) {
                    _profilesLoadRequested = false;
                  }
                  if (_currentStep == 3) {
                    _roomsLoadRequested = false;
                  }
                });

                if (_currentStep == 1) {
                  context
                      .read<BookingBloc>()
                      .add(
                        BookingLoadFamilyProfiles(
                          accountId: widget.familyProfilesAccountId,
                        ),
                      );
                }

                if (_currentStep == 3) {
                  context.read<BookingBloc>().add(_createLoadRoomsEvent(context));
                }
              } else {
                if (widget.onConfirmOverride != null) {
                  widget.onConfirmOverride!();
                } else {
                  context.read<BookingBloc>().add(const BookingCreateBooking());
                }
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentStep == 4
                ? AppStrings.homeServicePay
                : AppStrings.bookingNext,
            style: AppTextStyles.arimo(
              fontSize: 16 * scale,
              fontWeight: FontWeight.w600,
              color: _canProceed(state) ? AppColors.white : AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 8 * scale),
          Icon(
            Icons.arrow_forward_rounded,
            size: 18 * scale,
            color: _canProceed(state) ? AppColors.white : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  double? _getEstimatedPrice(BookingState state) {
    final bookingBloc = context.read<BookingBloc>();
    final selectedPackage = bookingBloc.selectedPackage;

    if (selectedPackage == null) {
      return _cachedEstimatedPrice;
    }

    final double basePrice = selectedPackage.basePrice;

    // Calculate extra child surcharge
    final profiles = bookingBloc.familyProfiles ?? [];
    final selectedIds = bookingBloc.selectedFamilyProfileIds;
    final babyCount = profiles
        .where((p) => selectedIds.contains(p.id) && p.memberTypeId == 3)
        .length;

    double extraSurcharge = 0;
    if (babyCount > 1) {
      final extraPercent = (bookingBloc.config?.extraChildPricePercent ?? 70.0) / 100.0;
      extraSurcharge = basePrice * extraPercent * (babyCount - 1);
    }

    _cachedEstimatedPrice = basePrice + extraSurcharge;
    return _cachedEstimatedPrice;
  }

  bool _canProceed(BookingState state) {
    final bookingBloc = context.read<BookingBloc>();

    bool hasMomSelected() {
      final selectedIds = bookingBloc.selectedFamilyProfileIds;
      final profiles = bookingBloc.familyProfiles ?? [];
      return selectedIds.isNotEmpty &&
          profiles.any((p) => selectedIds.contains(p.id) && p.memberTypeId == 2);
    }

    switch (_currentStep) {
      case 0:
        return bookingBloc.selectedPackageId != null;
      case 1:
        return hasMomSelected();
      case 2:
        return bookingBloc.selectedDate != null;
      case 3:
        return bookingBloc.selectedRoomId != null;
      case 4:
        return bookingBloc.selectedPackageId != null &&
            hasMomSelected() &&
            bookingBloc.selectedDate != null &&
            bookingBloc.selectedRoomId != null;
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
          vertical: 8 * scale,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52 * scale,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 24 * scale,
                    color: AppColors.textPrimary,
                  ),
                  padding: EdgeInsets.all(8 * scale),
                  constraints: BoxConstraints(
                    minWidth: 40 * scale,
                    minHeight: 40 * scale,
                  ),
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return AppColors.textPrimary.withValues(alpha: 0.10);
                      }
                      return Colors.transparent;
                    }),
                    overlayColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return AppColors.textPrimary.withValues(alpha: 0.06);
                      }
                      return Colors.transparent;
                    }),
                    splashFactory: InkRipple.splashFactory,
                  ),
                  enableFeedback: true,
                  onPressed: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                      return;
                    }

                    widget.onBackToLocationSelection();
                  },
                ),
              ),
            ),
            Expanded(
              child: Text(
                AppStrings.bookingTitle,
                style: AppTextStyles.tinos(
                  fontSize: 28 * scale,
                  fontWeight: FontWeight.w700,
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

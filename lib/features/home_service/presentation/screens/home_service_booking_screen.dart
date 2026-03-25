import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../booking/domain/entities/booking_entity.dart';
import '../../../booking/domain/entities/customer_entity.dart';
import '../../../booking/domain/entities/package_info_entity.dart';
import '../../../booking/domain/entities/room_info_entity.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/screens/payment_screen.dart';
import '../../domain/entities/home_service_booking_entity.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../bloc/home_service_bloc.dart';
import '../bloc/home_service_event.dart';
import '../bloc/home_service_state.dart';
import '../widgets/home_service_step1_activity_selection.dart';
import '../widgets/home_service_step2_time_selection.dart';
import '../widgets/home_service_step3_staff_selection.dart';
import '../widgets/home_service_step4_summary.dart';
import '../widgets/home_service_step_indicator.dart';

class HomeServiceBookingScreen extends StatefulWidget {
  final VoidCallback? onBackToLocationSelection;

  const HomeServiceBookingScreen({
    super.key,
    this.onBackToLocationSelection,
  });

  @override
  State<HomeServiceBookingScreen> createState() => _HomeServiceBookingScreenState();
}

class _HomeServiceBookingScreenState extends State<HomeServiceBookingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  double? _cachedEstimatedPrice;
  bool _isNavigatingToPayment = false;

  static const _stepTitles = [
    AppStrings.homeServiceStepService,
    AppStrings.homeServiceStepDateTime,
    AppStrings.homeServiceStepStaff,
    AppStrings.homeServiceStepConfirm,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step, BuildContext blocContext) {
    if (step == _currentStep) return;

    final bloc = blocContext.read<HomeServiceBloc>();
    if (_currentStep == 2 && step == 1) {
      bloc.add(const HomeServiceClearSelectedStaff());
    }
    if (_currentStep == 1 && step == 2) {
      bloc.add(const HomeServiceLoadFreeStaff());
    }
    if (_currentStep == 2 && step == 3) {
      bloc.add(const HomeServicePrepareSummary());
    }
    if (_currentStep == 3 && step == 2) {
      bloc.add(const HomeServiceBackToStaffSelection());
    }

    setState(() => _currentStep = step);
    _pageController.jumpToPage(step);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (context) => InjectionContainer.homeServiceBloc
        ..add(const HomeServiceLoadActivities()),
      child: Builder(
        builder: (blocContext) => Scaffold(
          backgroundColor: AppColors.background,
          body: BlocConsumer<HomeServiceBloc, HomeServiceState>(
            listener: (context, state) {
              if (state is HomeServiceBookingCreated && !_isNavigatingToPayment) {
                _isNavigatingToPayment = true;
                final booking = _mapHomeBookingToBooking(state.booking);
                final bookingBloc = InjectionContainer.bookingBloc;

                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<BookingBloc>.value(
                      value: bookingBloc,
                      child: PaymentScreen(
                        booking: booking,
                        paymentType: 'Full',
                        isHomeService: true,
                        staffId: state.booking.staffId,
                      ),
                    ),
                  ),
                )
                    .then((_) {
                  if (mounted) {
                    setState(() {
                      _isNavigatingToPayment = false;
                    });
                  } else {
                    _isNavigatingToPayment = false;
                  }
                });
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  _buildCustomHeader(blocContext),
                  HomeServiceStepIndicator(
                    currentStep: _currentStep,
                    totalSteps: 4,
                    stepTitles: _stepTitles,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        setState(() => _currentStep = index);
                      },
                      children: const [
                        HomeServiceStep1ActivitySelection(),
                        HomeServiceStep2TimeSelection(),
                        HomeServiceStep3StaffSelection(),
                        HomeServiceStep4Summary(),
                      ],
                    ),
                  ),
                  _buildBottomBar(state, scale, blocContext),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleBackAction(BuildContext blocContext) {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1, blocContext);
      return;
    }

    if (widget.onBackToLocationSelection != null) {
      widget.onBackToLocationSelection!.call();
      return;
    }

    Navigator.of(context).pop();
  }

  Widget _buildCustomHeader(BuildContext blocContext) {
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
                  onPressed: () => _handleBackAction(blocContext),
                ),
              ),
            ),
            Expanded(
              child: Text(
                AppStrings.homeServiceBookingTitle,
                style: AppTextStyles.tinos(
                  fontSize: 28 * scale,
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

  Widget _buildBottomBar(HomeServiceState state, double scale, BuildContext blocContext) {
    final estimatedPrice = _getEstimatedPrice(state);

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(4 * scale, 2 * scale, 4 * scale, 2 * scale),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.homeServiceShadow,
              blurRadius: 8 * scale,
              offset: Offset(0, -2 * scale),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: _buildEstimatedPriceCard(estimatedPrice, scale),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              flex: 6,
              child: _buildNextButton(state, scale, blocContext),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedPriceCard(double? price, double scale) {
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
            price != null ? _formatPrice(price) : AppStrings.bookingPriceNotAvailable,
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

  Widget _buildNextButton(HomeServiceState state, double scale, BuildContext blocContext) {
    final canProceed = _canProceed(state);

    return ElevatedButton(
      onPressed: canProceed
          ? () {
              if (_currentStep < 3) {
                _goToStep(_currentStep + 1, blocContext);
                return;
              }

              if (_currentStep == 3) {
                blocContext.read<HomeServiceBloc>().add(const HomeServiceCreateBooking());
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
        elevation: canProceed ? 2 : 0,
      ),
      child: Text(
        _currentStep == 3 ? AppStrings.homeServicePay : AppStrings.bookingNext,
        style: AppTextStyles.arimo(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w600,
          color: canProceed ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  double? _getEstimatedPrice(HomeServiceState state) {
    final selections = _extractSelections(state);

    if (selections == null) {
      return _cachedEstimatedPrice;
    }

    if (selections.isEmpty) {
      _cachedEstimatedPrice = null;
      return null;
    }

    final currentEstimatedPrice = selections.fold<double>(0, (sum, selection) {
      final sessionsCount = selection.dateTimeSlots.length;
      final displayCount = sessionsCount > 0 ? sessionsCount : 1;
      final price = selection.activity.price ?? 0;
      final activityTotal = price * displayCount;
      return sum + activityTotal;
    });

    _cachedEstimatedPrice = currentEstimatedPrice;
    return currentEstimatedPrice;
  }

  List<HomeServiceSelectionEntity>? _extractSelections(HomeServiceState state) {
    if (state is HomeServiceActivitiesLoaded) {
      return state.selections;
    }
    if (state is HomeServiceFreeStaffLoaded) {
      return state.selections;
    }
    if (state is HomeServiceSummaryReady) {
      return state.selections;
    }
    return null;
  }

  bool _canProceed(HomeServiceState state) {
    switch (_currentStep) {
      case 0:
        final selections = _extractSelections(state);
        return selections != null && selections.isNotEmpty;
      case 1:
        if (state is HomeServiceActivitiesLoaded) {
          return state.selections.isNotEmpty &&
              state.selections.every((s) => s.dateTimeSlots.isNotEmpty);
        }
        if (state is HomeServiceFreeStaffLoaded || state is HomeServiceSummaryReady) {
          return true;
        }
        return false;
      case 2:
        return state is HomeServiceFreeStaffLoaded && state.selectedStaff != null;
      case 3:
        return state is HomeServiceSummaryReady;
      default:
        return false;
    }
  }

  BookingEntity _mapHomeBookingToBooking(HomeServiceBookingEntity homeBooking) {
    final totalPrice = homeBooking.totalPrice;
    final paidAmount = homeBooking.paidAmount;
    final remainingAmount = homeBooking.remainingAmount;

    final serviceDates = homeBooking.services
        .expand((service) => service.serviceDates)
        .toList()
      ..sort();

    final startDate = serviceDates.isNotEmpty ? serviceDates.first : homeBooking.createdAt;
    final endDate = serviceDates.isNotEmpty ? serviceDates.last : homeBooking.createdAt;

    return BookingEntity(
      id: homeBooking.id,
      startDate: startDate,
      endDate: endDate,
      totalPrice: totalPrice,
      discountAmount: 0,
      finalAmount: totalPrice,
      paidAmount: paidAmount,
      remainingAmount: remainingAmount,
      status: homeBooking.status,
      bookingDate: homeBooking.createdAt,
      createdAt: homeBooking.createdAt,
      customer: const CustomerEntity(
        id: '',
        email: '',
        username: '',
        phone: '',
      ),
      package: PackageInfoEntity(
        id: 0,
        packageName: AppStrings.homeServiceBookingTitle,
        durationDays: 1,
        basePrice: totalPrice,
        roomTypeName: AppStrings.servicesLocationHomeChip,
      ),
      room: const RoomInfoEntity(
        id: 0,
        name: '-',
        floor: null,
        roomTypeName: '-',
      ),
      transactions: const [],
    );
  }

  String _formatPrice(double value) {
    final intValue = value.round();
    final str = intValue.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }

    final reversed = buffer.toString().split('').reversed.join();
    return '$reversed${AppStrings.currencyUnit}';
  }
}

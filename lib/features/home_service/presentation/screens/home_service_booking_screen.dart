import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/home_service_bloc.dart';
import '../bloc/home_service_event.dart';
import '../bloc/home_service_state.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../widgets/home_service_step_indicator.dart';
import '../widgets/home_service_step1_activity_selection.dart';
import '../widgets/home_service_step2_time_selection.dart';
import '../widgets/home_service_step3_staff_selection.dart';
import '../widgets/home_service_step4_summary.dart';

class HomeServiceBookingScreen extends StatefulWidget {
  const HomeServiceBookingScreen({super.key});

  @override
  State<HomeServiceBookingScreen> createState() => _HomeServiceBookingScreenState();
}

class _HomeServiceBookingScreenState extends State<HomeServiceBookingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  static const _stepTitles = [
    'Dịch vụ',
    'Ngày & Giờ',
    'Nhân viên',
    'Xác nhận',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    if (step == _currentStep) return;
    setState(() => _currentStep = step);
    _pageController.jumpToPage(step);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocProvider(
      create: (context) => InjectionContainer.homeServiceBloc
        ..add(const HomeServiceLoadActivities()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppAppBar(
          title: 'Đặt dịch vụ tại nhà',
          centerTitle: true,
          titleFontSize: 20 * scale,
          titleFontWeight: FontWeight.w700,
          onBackPressed: _handleBackAction,
        ),
        body: BlocConsumer<HomeServiceBloc, HomeServiceState>(
          listener: (context, state) {
            if (state is HomeServiceFreeStaffLoaded &&
                _currentStep == 2 &&
                state.selectedStaff != null) {
              _goToStep(3);
            } else if (state is HomeServiceSummaryReady && _currentStep == 2) {
              _goToStep(3);
            } else if (state is HomeServiceBookingCreated) {
              // Navigate to payment screen in step 4 flow.
            }
          },
          builder: (context, state) {
            if (state is HomeServiceLoading && _currentStep == 0) {
              return const Center(child: AppLoadingIndicator());
            }

            return Column(
              children: [
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
                _buildBottomBar(state, scale),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleBackAction() {
    if (_currentStep > 0) {
      _goToStep(_currentStep - 1);
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _buildBottomBar(HomeServiceState state, double scale) {
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
              child: _buildEstimatedPriceCard(estimatedPrice, scale),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              flex: 6,
              child: _buildNextButton(state, scale),
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
            style: TextStyle(
              fontSize: 11 * scale,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            price != null ? _formatPrice(price) : AppStrings.bookingPriceNotAvailable,
            style: TextStyle(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: price != null ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(HomeServiceState state, double scale) {
    final canProceed = _canProceed(state);

    return ElevatedButton(
      onPressed: canProceed
          ? () {
              if (_currentStep < 3) {
                _goToStep(_currentStep + 1);
                return;
              }

              if (_currentStep == 3) {
                context.read<HomeServiceBloc>().add(const HomeServiceCreateBooking());
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
        _currentStep == 3 ? 'Thanh toán' : AppStrings.bookingNext,
        style: TextStyle(
          fontSize: 16 * scale,
          fontWeight: FontWeight.w600,
          color: canProceed ? AppColors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  double? _getEstimatedPrice(HomeServiceState state) {
    final selections = _extractSelections(state);
    if (selections == null || selections.isEmpty) {
      return null;
    }

    return selections.fold<double>(0, (sum, selection) {
      final sessionsCount = selection.dateTimeSlots.length;
      final activityTotal = selection.activity.price * sessionsCount;
      return sum + activityTotal;
    });
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
    return '$reversed đ';
  }
}

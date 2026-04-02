import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/data/models/current_account_model.dart';
import '../../domain/entities/family_schedule_entity.dart';
import '../bloc/family_schedule_bloc.dart';
import '../bloc/family_schedule_event.dart';
import '../bloc/family_schedule_state.dart';
import 'resort_key_card.dart';
import 'schedule_calendar_picker.dart';
import 'schedule_day_view.dart';
import 'service_action_card.dart';

class ServiceDashboard extends StatelessWidget {
  final NowPackageModel nowPackage;

  const ServiceDashboard({
    super.key,
    required this.nowPackage,
  });

  bool get _isCheckoutExpired {
    final checkoutDate = nowPackage.checkoutDate;
    if (checkoutDate == null) return false;

    final localCheckout = checkoutDate.toLocal();
    final normalizedCheckout = DateTime(
      localCheckout.year,
      localCheckout.month,
      localCheckout.day,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return today.isAfter(normalizedCheckout);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final isHomeService = nowPackage.type.toLowerCase() == 'home';

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20 * scale,
            10 * scale,
            20 * scale,
            24 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context, scale),
              SizedBox(height: 8 * scale),
              if (isHomeService) ...[
                _HomeServiceDashboard(nowPackage: nowPackage),
              ] else ...[
                // Key Card - First element after header
                ResortKeyCard(nowPackage: nowPackage),
                SizedBox(height: 18 * scale),

                if (_isCheckoutExpired)
                  _buildCheckoutExpiredBanner(context, scale)
                else
                  _buildServicesSection(context, scale),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context, double scale) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyles.tinos(
            fontSize: 28 * scale,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          AppStrings.servicesResortExperienceDescription,
          style: AppTextStyles.arimo(
            fontSize: 14 * scale,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context, double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Banner Header
        _buildServicesBanner(context, scale),
        SizedBox(height: 20 * scale),
        
        // Services Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16 * scale,
          mainAxisSpacing: 16 * scale,
          childAspectRatio: 1.0,
          children: [
            ServiceActionCard(
              iconWidget: SvgPicture.asset(
                AppAssets.calendarBold,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.servicesDailySchedule,
              onTap: () => AppRouter.push(context, AppRoutes.familySchedule),
            ),
            ServiceActionCard(
              iconWidget: SvgPicture.asset(
                AppAssets.menuFirst,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.servicesTodayMenu,
              onTap: () => AppRouter.push(context, AppRoutes.myMenu),
            ),
            ServiceActionCard(
              iconWidget: SvgPicture.asset(
                AppAssets.menuSecond,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.feedBackForService,
              onTap: () => AppRouter.push(context, AppRoutes.feedback),
            ),
            ServiceActionCard(
              iconWidget: SvgPicture.asset(
                AppAssets.serviceAmenity,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
              title: AppStrings.servicesAmenityRequest,
              onTap: () => AppRouter.push(context, AppRoutes.amenity),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesBanner(BuildContext context, double scale) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1.2 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 16 * scale,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with decorative background
          Container(
            padding: EdgeInsets.all(8 * scale),
            child: SvgPicture.asset(
              AppAssets.helper,
              fit: BoxFit.contain,
              width: 28 * scale,
              height: 28 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          // Title Section - Centered
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.servicesResortAmenities,
                style: AppTextStyles.tinos(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                AppStrings.servicesExploreAmenities,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(width: 12 * scale),
          // Helper icon at the end
          Container(
            padding: EdgeInsets.all(8 * scale),
            child: SvgPicture.asset(
              AppAssets.helper,
              fit: BoxFit.contain,
              width: 28 * scale,
              height: 28 * scale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutExpiredBanner(BuildContext context, double scale) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1.2 * scale,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 20 * scale,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              AppAssets.helper,
              fit: BoxFit.contain,
              width: 28 * scale,
              height: 28 * scale,
              colorFilter: const ColorFilter.mode(
                AppColors.primary,
                BlendMode.srcIn,
              ),
            ),
          ),
          SizedBox(height: 12 * scale),
          Text(
            AppStrings.servicesCheckoutExpiredMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.arimo(
              fontSize: 13 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeServiceDashboard extends StatelessWidget {
  final NowPackageModel nowPackage;

  const _HomeServiceDashboard({
    required this.nowPackage,
  });

  DateTime _normalizeDate(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  List<DateTime> _getServiceDates() {
    return nowPackage.serviceDates
        .map((item) => _normalizeDate(item.date))
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final serviceDates = _getServiceDates();

    if (serviceDates.isEmpty) {
      return AppWidgets.sectionContainer(
        context,
        padding: EdgeInsets.all(16 * scale),
        children: [
          Text(
            AppStrings.scheduleNoScheduleForDay,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return BlocProvider(
      create: (context) => InjectionContainer.familyScheduleBloc
        ..add(const FamilyScheduleLoadRequested()),
      child: _HomeServiceDashboardContent(
        serviceDates: serviceDates,
        nowPackage: nowPackage,
      ),
    );
  }
}

class _HomeServiceDashboardContent extends StatefulWidget {
  final List<DateTime> serviceDates;
  final NowPackageModel nowPackage;

  const _HomeServiceDashboardContent({
    required this.serviceDates,
    required this.nowPackage,
  });

  @override
  State<_HomeServiceDashboardContent> createState() =>
      _HomeServiceDashboardContentState();
}

class _HomeServiceDashboardContentState
    extends State<_HomeServiceDashboardContent> {
  late DateTime _selectedDate;
  bool _isPackageExpanded = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);

    final initialDate = _initialSelectedDate();
    if (initialDate != null) {
      _selectedDate = initialDate;
    }
  }

  void _togglePackageInfo() {
    setState(() {
      _isPackageExpanded = !_isPackageExpanded;
    });
  }

  DateTime _normalizeDate(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  DateTime? _initialSelectedDate() {
    if (widget.serviceDates.isEmpty) return null;

    final today = _normalizeDate(DateTime.now());
    if (widget.serviceDates.any((d) => _normalizeDate(d) == today)) {
      return today;
    }

    final sortedDates = List<DateTime>.from(widget.serviceDates)
      ..sort((a, b) => a.compareTo(b));
    return sortedDates.first;
  }

  void _handleDateSelected(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    setState(() {
      _selectedDate = normalizedDate;
    });
  }

  List<FamilyScheduleEntity> _filterSchedules(
    List<FamilyScheduleEntity> schedules,
  ) {
    final normalizedSelected = _normalizeDate(_selectedDate);
    return schedules.where((schedule) {
      final scheduleDate = _normalizeDate(schedule.workDate);
      return scheduleDate == normalizedSelected;
    }).toList();
  }

  Widget _buildPackageSummary(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final nowPackage = widget.nowPackage;

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16 * scale),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10 * scale,
            offset: Offset(0, 4 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _togglePackageInfo,
            borderRadius: BorderRadius.circular(12 * scale),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10 * scale,
                    vertical: 4 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Text(
                    nowPackage.type,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Expanded(
                  child: Text(
                    nowPackage.packageName,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isPackageExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          if (_isPackageExpanded) ...[
            SizedBox(height: 10 * scale),
            _buildPackageDetailRow(
              AppStrings.homeServiceBookingIdLabel,
              nowPackage.bookingId.toString(),
            ),
            SizedBox(height: 6 * scale),
            _buildPackageDetailRow(
              AppStrings.homeServiceBookingStatusLabel,
              nowPackage.bookingStatus,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageDetailRow(String label, String value) {
    final scale = AppResponsive.scaleFactor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100 * scale,
          child: Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<FamilyScheduleBloc, FamilyScheduleState>(
      builder: (context, state) {
        if (state is FamilyScheduleLoading) {
          final height = MediaQuery.of(context).size.height;
          return SizedBox(
            height: height * 0.45,
            child: const Center(
              child: AppLoadingIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is FamilyScheduleError) {
          return AppWidgets.sectionContainer(
            context,
            padding: EdgeInsets.all(16 * scale),
            children: [
              Text(
                state.message,
                style: AppTextStyles.arimo(
                  fontSize: 12 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12 * scale),
              AppWidgets.primaryButton(
                text: AppStrings.retry,
                onPressed: () {
                  context
                      .read<FamilyScheduleBloc>()
                      .add(const FamilyScheduleLoadRequested());
                },
              ),
            ],
          );
        }

        if (state is FamilyScheduleLoaded) {
          final schedulesForDate = _filterSchedules(state.schedules);
          final dayNo = schedulesForDate.isNotEmpty
              ? schedulesForDate.first.dayNo
              : 0;
          final scheduleDates = state.schedules
              .map((schedule) => _normalizeDate(schedule.workDate))
              .toSet()
              .toList();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPackageSummary(context),
              SizedBox(height: 10 * scale),
              ScheduleCalendarPicker(
                selectedDate: _selectedDate,
                onDateSelected: _handleDateSelected,
                datesWithSchedules: scheduleDates,
                margin: EdgeInsets.zero,
              ),
              SizedBox(height: 16 * scale),
              ScheduleDayView(
                date: _selectedDate,
                schedules: schedulesForDate,
                dayNo: dayNo,
                margin: EdgeInsets.zero,
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../auth/data/models/current_account_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_event.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import '../../../booking/presentation/screens/payment_screen.dart';
import '../../domain/entities/family_schedule_entity.dart';
import '../bloc/family_schedule_bloc.dart';
import '../bloc/family_schedule_event.dart';
import '../bloc/family_schedule_state.dart';
import 'resort_key_card.dart';
import 'schedule_calendar_picker.dart';
import 'schedule_day_view.dart';
import 'services_formatters.dart';

class CurrentPackageView extends StatelessWidget {
  final NowPackageModel nowPackage;

  const CurrentPackageView({
    super.key,
    required this.nowPackage,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final authState = context.read<AuthBloc>().state;
    final account = authState is AuthCurrentAccountLoaded
        ? authState.account
        : null;
    final isFullyPaid = nowPackage.remainingAmount <= 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final checkinDate = nowPackage.checkinDate ?? nowPackage.firstServiceDate;
    final checkin = checkinDate != null
        ? DateTime(checkinDate.year, checkinDate.month, checkinDate.day)
        : todayDate;
    final isOnOrAfterCheckin = !todayDate.isBefore(checkin);
    final showOverdueWarning = !isFullyPaid && isOnOrAfterCheckin;

    return SafeArea(
      child: SingleChildScrollView(
        padding:
            EdgeInsets.fromLTRB(20 * scale, 16 * scale, 20 * scale, 24 * scale),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, scale),
            if (isFullyPaid)
              Text(
                AppStrings.servicesAwaitingActivationMessage,
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              )
            else
              Text(
                AppStrings.servicesPendingPaymentMessage,
                style: AppTextStyles.arimo(
                  fontSize: 13 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
            SizedBox(height: 20 * scale),
            if (showOverdueWarning) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12 * scale),
                  border: Border.all(
                    color: AppColors.red.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20 * scale,
                      color: AppColors.red,
                    ),
                    SizedBox(width: 8 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.servicesRemainingPaymentOverdueTitle,
                            style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.red,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            AppStrings.servicesRemainingPaymentOverdueMessage,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16 * scale),
            ],
            ResortKeyCard(nowPackage: nowPackage),
            SizedBox(height: 16 * scale),
            if (nowPackage.serviceIsActive) ...[
              _AccountQuickInfo(account: account),
              SizedBox(height: 16 * scale),
              _InProgressSection(nowPackage: nowPackage),
              SizedBox(height: 16 * scale),
            ],
            AppWidgets.sectionContainer(
              context,
              padding: EdgeInsets.all(18 * scale),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.contractTitle,
                      style: AppTextStyles.arimo(
                        fontSize: 13 * scale,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10 * scale,
                        vertical: 4 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Text(
                        formatContractStatus(nowPackage.contractStatus),
                        style: AppTextStyles.arimo(
                          fontSize: 11 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8 * scale),
                Text(
                  nowPackage.contractCode ?? '—',
                  style: AppTextStyles.tinos(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Container(
                  padding: EdgeInsets.all(14 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.invoicePaidAmount,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            formatPrice(nowPackage.paidAmount),
                            style: AppTextStyles.tinos(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10 * scale),
                      Divider(height: 1, color: AppColors.borderLight),
                      SizedBox(height: 10 * scale),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.invoiceRemainingAmount,
                            style: AppTextStyles.arimo(
                              fontSize: 12 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            formatPrice(nowPackage.remainingAmount),
                            style: AppTextStyles.tinos(
                              fontSize: 18 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12 * scale),
                Text(
                  isFullyPaid
                      ? AppStrings.servicesAwaitingActivationMessage
                      : AppStrings.servicesRemainingPaymentMessage,
                  style: AppTextStyles.arimo(
                    fontSize: 12 * scale,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 18 * scale),
                if (isFullyPaid)
                  AppWidgets.primaryButton(
                    text: AppStrings.menuWaitingCheckIn,
                    isEnabled: false,
                    onPressed: () {},
                  )
                else if (nowPackage.contractId != null)
                  _PayRemainingButton(nowPackage: nowPackage)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    // Ẩn "Đặt gói dịch vụ" khi dịch vụ đã được kích hoạt
    if (nowPackage.serviceIsActive) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: Row(
        children: [
          SizedBox(
            width: 52 * scale,
            child: const SizedBox.shrink(),
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
    );
  }
}

class _InProgressSection extends StatelessWidget {
  final NowPackageModel nowPackage;

  const _InProgressSection({
    required this.nowPackage,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final isHomeService = nowPackage.type.toLowerCase() == 'home';

    return AppWidgets.sectionContainer(
      context,
      padding: EdgeInsets.all(16 * scale),
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 18 * scale,
              color: AppColors.primary,
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: Text(
                AppStrings.servicesInProgressTitle,
                style: AppTextStyles.tinos(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 4 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20 * scale),
              ),
              child: Text(
                isHomeService
                    ? AppStrings.servicesTypeHome
                    : AppStrings.servicesTypeCenter,
                style: AppTextStyles.arimo(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        Text(
          isHomeService
              ? AppStrings.servicesHomeInProgressHint
              : AppStrings.servicesCenterInProgressHint,
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            color: AppColors.textSecondary,
          ),
        ),
        if (isHomeService) ...[
          SizedBox(height: 16 * scale),
          _HomeServiceScheduleSection(nowPackage: nowPackage),
        ] else ...[
          SizedBox(height: 12 * scale),
          _CenterServiceSummary(nowPackage: nowPackage),
        ],
      ],
    );
  }
}

class _CenterServiceSummary extends StatelessWidget {
  final NowPackageModel nowPackage;

  const _CenterServiceSummary({
    required this.nowPackage,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final checkin = nowPackage.checkinDate;
    final checkout = nowPackage.checkoutDate;

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14 * scale),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: AppStrings.servicesPackageName,
            value: nowPackage.packageName,
          ),
          SizedBox(height: 10 * scale),
          _InfoRow(
            label: AppStrings.servicesBookingStatus,
            value: nowPackage.bookingStatus,
          ),
          SizedBox(height: 10 * scale),
          _InfoRow(
            label: AppStrings.servicesCheckinDate,
            value: checkin != null ? formatDateLocal(checkin) : '—',
          ),
          SizedBox(height: 10 * scale),
          _InfoRow(
            label: AppStrings.servicesCheckoutDate,
            value: checkout != null ? formatDateLocal(checkout) : '—',
          ),
        ],
      ),
    );
  }
}

class _HomeServiceScheduleSection extends StatelessWidget {
  final NowPackageModel nowPackage;

  const _HomeServiceScheduleSection({
    required this.nowPackage,
  });

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

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
      return Text(
        AppStrings.scheduleNoScheduleForDay,
        style: AppTextStyles.arimo(
          fontSize: 12 * scale,
          color: AppColors.textSecondary,
        ),
      );
    }

    return BlocProvider(
      create: (context) => InjectionContainer.familyScheduleBloc
        ..add(const FamilyScheduleLoadRequested()),
      child: _HomeServiceScheduleContent(
        nowPackage: nowPackage,
        serviceDates: serviceDates,
      ),
    );
  }
}

class _AccountQuickInfo extends StatelessWidget {
  final CurrentAccountModel? account;

  const _AccountQuickInfo({
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final accountData = account;
    if (accountData == null) return const SizedBox.shrink();

    final scale = AppResponsive.scaleFactor(context);
    final owner = accountData.ownerProfile;

    return AppWidgets.sectionContainer(
      context,
      padding: EdgeInsets.all(16 * scale),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22 * scale,
              backgroundImage: accountData.avatarUrl != null
                  ? NetworkImage(accountData.avatarUrl!)
                  : null,
              backgroundColor: AppColors.background,
              child: accountData.avatarUrl == null
                  ? Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 22 * scale,
                    )
                  : null,
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountData.displayName,
                    style: AppTextStyles.tinos(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    accountData.email,
                    style: AppTextStyles.arimo(
                      fontSize: 12 * scale,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10 * scale,
                vertical: 4 * scale,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20 * scale),
              ),
              child: Text(
                accountData.roleName,
                style: AppTextStyles.arimo(
                  fontSize: 11 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12 * scale),
        _InfoRow(
          label: AppStrings.accountPhoneNumber,
          value: accountData.phone,
        ),
        if (owner != null) ...[
          SizedBox(height: 8 * scale),
          _InfoRow(
            label: AppStrings.owner,
            value: owner.fullName,
          ),
          if ((owner.address ?? '').isNotEmpty) ...[
            SizedBox(height: 8 * scale),
            _InfoRow(
              label: AppStrings.accountAddress,
              value: owner.address ?? '',
            ),
          ],
        ],
      ],
    );
  }
}

class _HomeServiceScheduleContent extends StatefulWidget {
  final NowPackageModel nowPackage;
  final List<DateTime> serviceDates;

  const _HomeServiceScheduleContent({
    required this.nowPackage,
    required this.serviceDates,
  });

  @override
  State<_HomeServiceScheduleContent> createState() =>
      _HomeServiceScheduleContentState();
}

class _HomeServiceScheduleContentState
    extends State<_HomeServiceScheduleContent> {
  late DateTime _selectedDate;

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

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

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

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<FamilyScheduleBloc, FamilyScheduleState>(
      builder: (context, state) {
        if (state is FamilyScheduleLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 20 * scale),
            child: const Center(
              child: AppLoadingIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is FamilyScheduleError) {
          return _HomeServiceErrorView(message: state.message);
        }

        if (state is FamilyScheduleLoaded) {
          final schedulesForDate = _filterSchedules(state.schedules);
          final dayNo = schedulesForDate.isNotEmpty
              ? schedulesForDate.first.dayNo
              : 0;

          final minDate = widget.serviceDates.isNotEmpty
              ? widget.serviceDates.reduce(
                  (a, b) => a.isBefore(b) ? a : b,
                )
              : null;
          final maxDate = widget.serviceDates.isNotEmpty
              ? widget.serviceDates.reduce(
                  (a, b) => a.isAfter(b) ? a : b,
                )
              : null;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScheduleCalendarPicker(
                selectedDate: _selectedDate,
                onDateSelected: _handleDateSelected,
                datesWithSchedules: widget.serviceDates,
                minDate: minDate,
                maxDate: maxDate,
              ),
              SizedBox(height: 12 * scale),
              ScheduleDayView(
                date: _selectedDate,
                schedules: schedulesForDate,
                dayNo: dayNo,
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _HomeServiceErrorView extends StatelessWidget {
  final String message;

  const _HomeServiceErrorView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      children: [
        Icon(
          Icons.error_outline,
          color: AppColors.textSecondary,
          size: 40 * scale,
        ),
        SizedBox(height: 8 * scale),
        Text(
          message,
          style: AppTextStyles.arimo(
            fontSize: 12 * scale,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
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
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.arimo(
              fontSize: 12 * scale,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
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
}

class _PayRemainingButton extends StatefulWidget {
  final NowPackageModel nowPackage;

  const _PayRemainingButton({
    required this.nowPackage,
  });

  @override
  State<_PayRemainingButton> createState() => _PayRemainingButtonState();
}

class _PayRemainingButtonState extends State<_PayRemainingButton> {
  bool _isSubmitting = false;
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final nowPackage = widget.nowPackage;
    final isEnabled = nowPackage.contractStatus == 'Signed' &&
        nowPackage.remainingAmount > 0 &&
        nowPackage.contractId != null;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (!mounted || _hasNavigated == true) return;

        if (state is BookingLoaded && state.booking.id == nowPackage.bookingId) {
          _hasNavigated = true;
          _isSubmitting = false;

          final bookingBloc = context.read<BookingBloc>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: bookingBloc,
                child: PaymentScreen(
                  booking: state.booking,
                  paymentType: 'Remaining',
                ),
              ),
            ),
          );
        } else if (state is BookingError && _isSubmitting) {
          setState(() => _isSubmitting = false);
          AppToast.showError(context, message: state.message);
        }
      },
      child: AppWidgets.primaryButton(
        text: _isSubmitting
            ? AppStrings.processing
            : AppStrings.servicesPayRemaining,
        isEnabled: isEnabled && !_isSubmitting,
        onPressed: () {
          if (!isEnabled || _isSubmitting) return;
          setState(() {
            _isSubmitting = true;
            _hasNavigated = false;
          });
          context.read<BookingBloc>().add(BookingLoadById(nowPackage.bookingId));
        },
      ),
    );
  }
}

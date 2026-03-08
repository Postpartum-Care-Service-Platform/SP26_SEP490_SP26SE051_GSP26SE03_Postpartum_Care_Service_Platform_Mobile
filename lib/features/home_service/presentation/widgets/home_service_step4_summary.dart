import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../domain/entities/home_service_selection_entity.dart';
import '../bloc/home_service_bloc.dart';
import '../bloc/home_service_state.dart';

class HomeServiceStep4Summary extends StatelessWidget {
  const HomeServiceStep4Summary({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<HomeServiceBloc, HomeServiceState>(
      builder: (context, state) {
        if (state is! HomeServiceSummaryReady) {
          return const Center(child: AppLoadingIndicator());
        }

        final selections = state.selections;
        final subtotal = selections.fold<double>(0, (sum, selection) {
          final sessions = selection.dateTimeSlots.length;
          final count = sessions > 0 ? sessions : 1;
          return sum + (selection.activity.price * count);
        });
        final total = state.totalPrice > 0 ? state.totalPrice : subtotal;
        const discount = 0.0;

        return SafeArea(
          top: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16 * scale, 12 * scale, 16 * scale, 8 * scale),
            children: [
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: AppStrings.homeServiceSectionService,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${selections.length} ${AppStrings.homeServiceSelectedPackages}',
                            style: AppTextStyles.tinos(
                              fontSize: 24 * scale,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            '${_totalSessions(selections)} ${AppStrings.homeServiceSessions}',
                            style: AppTextStyles.arimo(
                              fontSize: 13 * scale,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    flex: 2,
                    child: _InfoCard(
                      title: AppStrings.homeServiceSectionStaff,
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22 * scale,
                            backgroundImage: state.staff.avatarUrl != null
                                ? NetworkImage(state.staff.avatarUrl!)
                                : null,
                            child: state.staff.avatarUrl == null
                                ? Icon(Icons.person, size: 22 * scale)
                                : null,
                          ),
                          SizedBox(width: 10 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.staff.fullName ?? state.staff.username,
                                  style: AppTextStyles.tinos(
                                    fontSize: 21 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  state.staff.phone,
                                  style: AppTextStyles.arimo(
                                    fontSize: 13 * scale,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12 * scale),
              _SectionCard(
                title: AppStrings.homeServiceSectionTime,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...selections.map(
                      (selection) {
                        final entries = selection.dateTimeSlots.entries.toList()
                          ..sort((a, b) => a.key.compareTo(b.key));

                        return Padding(
                          padding: EdgeInsets.only(bottom: 12 * scale),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selection.activity.name,
                                style: AppTextStyles.arimo(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 6 * scale),
                              ...entries.map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 4 * scale),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _formatDate(entry.key),
                                          style: AppTextStyles.arimo(
                                            fontSize: 13 * scale,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${_formatTime(entry.value.startTime)} - ${_formatTime(entry.value.endTime)}',
                                        style: AppTextStyles.arimo(
                                          fontSize: 13 * scale,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 * scale,
                        vertical: 10 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.homeServiceScheduleHighlightBg,
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 18 * scale,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 8 * scale),
                          Text(
                            '${_totalSessions(selections)} ${AppStrings.homeServiceSessionsLabel}',
                            style: AppTextStyles.arimo(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12 * scale),
              _SectionCard(
                title: AppStrings.homeServiceSectionPaymentMethod,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12 * scale,
                    vertical: 10 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppAssets.payosLogo,
                        width: 34 * scale,
                        height: 34 * scale,
                        colorFilter: ColorFilter.mode(AppColors.verified, BlendMode.srcIn),
                      ),
                      SizedBox(width: 10 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.paymentPayOS,
                              style: AppTextStyles.tinos(
                                fontSize: 18 * scale,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              AppStrings.homeServicePayViaPayOS,
                              style: AppTextStyles.arimo(
                                fontSize: 13 * scale,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: AppColors.verified,
                        size: 22 * scale,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12 * scale),
              _SectionCard(
                title: AppStrings.homeServiceSectionPriceDetails,
                child: Column(
                  children: [
                    _PriceRow(
                      label: AppStrings.bookingTotalPrice,
                      value: _formatPrice(subtotal),
                    ),
                    SizedBox(height: 8 * scale),
                    _PriceRow(
                      label: AppStrings.bookingDiscount,
                      value: _formatPrice(discount),
                    ),
                    SizedBox(height: 10 * scale),
                    Divider(color: AppColors.borderLight, height: 1 * scale),
                    SizedBox(height: 10 * scale),
                    _PriceRow(
                      label: AppStrings.bookingFinalAmount,
                      value: _formatPrice(total),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8 * scale),
            ],
          ),
        );
      },
    );
  }

  int _totalSessions(List<HomeServiceSelectionEntity> selections) {
    return selections.fold<int>(0, (sum, selection) {
      final count = selection.dateTimeSlots.length;
      return sum + (count > 0 ? count : 1);
    });
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

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatTime(DateTime t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeServiceShadow,
            blurRadius: 10 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8 * scale),
          child,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeServiceShadow,
            blurRadius: 10 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10 * scale),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: isHighlight ? 16 * scale : 15 * scale,
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.arimo(
            fontSize: isHighlight ? 16 * scale : 15 * scale,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

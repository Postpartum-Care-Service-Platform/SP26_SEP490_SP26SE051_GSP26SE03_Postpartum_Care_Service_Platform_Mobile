import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../package/presentation/bloc/package_bloc.dart';
import '../../../package/presentation/bloc/package_event.dart';
import '../../../package/presentation/bloc/package_state.dart';
import '../../../package/presentation/widgets/package_card.dart';
import '../../../../core/di/injection_container.dart';
import '../../../booking/presentation/bloc/booking_bloc.dart';
import '../../../booking/presentation/bloc/booking_state.dart';
import 'package_detail_bottom_sheet.dart';

class BookingStep1PackageSelection extends StatelessWidget {
  final Function(int) onPackageSelected;

  const BookingStep1PackageSelection({
    super.key,
    required this.onPackageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, bookingState) {
        int? selectedPackageId;
        if (bookingState is BookingPackagesLoaded) {
          selectedPackageId = bookingState.selectedPackageId;
        } else if (bookingState is BookingSummaryReady) {
          selectedPackageId = bookingState.packageId;
        } else {
          selectedPackageId = context.read<BookingBloc>().selectedPackageId;
        }
        
        PackageBloc? existingPackageBloc;
        try {
          existingPackageBloc = context.read<PackageBloc>();
        } catch (_) {}

        return DefaultTabController(
          length: 2,
          child: existingPackageBloc != null
              ? BlocProvider.value(
                  value: existingPackageBloc..add(const PackageLoadRequested()),
                  child: _buildPackageContent(context, bookingState, selectedPackageId, scale),
                )
              : BlocProvider(
                  create: (context) {
                    final bloc = InjectionContainer.packageBloc;
                    bloc.add(const PackageLoadRequested());
                    return bloc;
                  },
                  child: _buildPackageContent(context, bookingState, selectedPackageId, scale),
                ),
        );
      },
    );
  }

  Widget _buildPackageContent(
    BuildContext context,
    BookingState bookingState,
    int? selectedPackageId,
    double scale,
  ) {
    return BlocBuilder<PackageBloc, PackageState>(
      builder: (context, packageState) {
        if (packageState is PackageLoading) {
          return const Center(child: AppLoadingIndicator());
        }

        if (packageState is PackageError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48 * scale, color: AppColors.red),
                SizedBox(height: 16 * scale),
                Text(
                  packageState.message,
                  style: AppTextStyles.arimo(fontSize: 14 * scale, color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (packageState is PackageLoaded) {
          return Column(
            children: [
              // Tab Selector
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                child: Container(
                  height: 46 * scale,
                  padding: EdgeInsets.all(4 * scale),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: TabBar(
                    onTap: (index) {
                      context.read<PackageBloc>().add(
                        PackageFilterChanged(index == 0 ? PackageFilter.center : PackageFilter.personalized),
                      );
                    },
                    indicator: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: AppTextStyles.arimo(fontSize: 14 * scale, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: AppTextStyles.arimo(fontSize: 14 * scale, fontWeight: FontWeight.w500),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Gói trung tâm'),
                      Tab(text: 'Gói cá nhân hoá'),
                    ],
                  ),
                ),
              ),

              // Hint
              Padding(
                padding: EdgeInsets.fromLTRB(16 * scale, 4 * scale, 16 * scale, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14 * scale,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                    SizedBox(width: 4 * scale),
                    Text(
                      'Nhấn giữ để xem chi tiết',
                      style: AppTextStyles.arimo(
                        fontSize: 11.5 * scale,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: Builder(
                  builder: (context) {
                    final packages = packageState.filteredPackages;
                    
                    if (packages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64 * scale, color: AppColors.textSecondary),
                            SizedBox(height: 16 * scale),
                            Text(
                              'Không có gói dịch vụ nào trong mục này',
                              style: AppTextStyles.arimo(fontSize: 16 * scale, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.all(16 * scale),
                      itemCount: packages.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12 * scale),
                      itemBuilder: (context, index) {
                        final package = packages[index];
                        final isSelected = selectedPackageId == package.id;
                        final isUnavailable = (package.availableRooms ?? 0) <= 0 ||
                            package.hasRoomAvailabilityWarning;

                        return SizedBox(
                          height: 220 * scale,
                          child: GestureDetector(
                            onTap: isUnavailable ? null : () => onPackageSelected(package.id),
                            onLongPress: () => PackageDetailBottomSheet.show(context, package: package),
                            child: AnimatedScale(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              scale: isSelected && !isUnavailable ? 1.01 : 1.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16 * scale),
                                  border: Border.all(
                                    color: isUnavailable
                                        ? AppColors.textSecondary.withValues(alpha: 0.35)
                                        : isSelected
                                            ? AppColors.primary
                                            : AppColors.borderLight,
                                    width: isSelected && !isUnavailable ? 2.2 : 1,
                                  ),
                                  boxShadow: isSelected && !isUnavailable
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(alpha: 0.28),
                                            blurRadius: 12 * scale,
                                            spreadRadius: 1 * scale,
                                            offset: Offset(0, 4 * scale),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: isUnavailable ? 0.02 : 0.05),
                                            blurRadius: 4 * scale,
                                            offset: Offset(0, 2 * scale),
                                          ),
                                        ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: PackageCard(
                                        package: package,
                                        isUnavailable: isUnavailable,
                                        onTap: isUnavailable ? null : () => onPackageSelected(package.id),
                                      ),
                                    ),
                                    if (isSelected && !isUnavailable)
                                      Positioned(
                                        right: 10 * scale,
                                        bottom: 10 * scale,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(16 * scale),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.2),
                                                blurRadius: 6 * scale,
                                                offset: Offset(0, 2 * scale),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.check_circle, size: 13 * scale, color: AppColors.white),
                                              SizedBox(width: 5 * scale),
                                              Text(
                                                AppStrings.bookingSelecting,
                                                style: AppTextStyles.arimo(
                                                  fontSize: 11 * scale,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}

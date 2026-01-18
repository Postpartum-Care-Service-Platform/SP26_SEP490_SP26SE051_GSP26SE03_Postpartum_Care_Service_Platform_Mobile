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
        // Get selected package ID from various states
        int? selectedPackageId;
        if (bookingState is BookingPackagesLoaded) {
          selectedPackageId = bookingState.selectedPackageId;
        } else if (bookingState is BookingSummaryReady) {
          selectedPackageId = bookingState.packageId;
        }
        
        return BlocProvider(
          create: (context) => InjectionContainer.packageBloc
            ..add(const PackageLoadRequested()),
          child: BlocBuilder<PackageBloc, PackageState>(
            builder: (context, packageState) {
              if (packageState is PackageLoading) {
                return const Center(child: AppLoadingIndicator());
              }

              if (packageState is PackageError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48 * scale,
                        color: AppColors.red,
                      ),
                      SizedBox(height: 16 * scale),
                      Text(
                        packageState.message,
                        style: AppTextStyles.arimo(
                          fontSize: 14 * scale,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (packageState is PackageLoaded) {
                if (packageState.packages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64 * scale,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(height: 16 * scale),
                        Text(
                          AppStrings.bookingNoPackages,
                          style: AppTextStyles.arimo(
                            fontSize: 16 * scale,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Use selectedPackageId from outer scope

                return GridView.builder(
                  padding: EdgeInsets.all(16 * scale),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12 * scale,
                    mainAxisSpacing: 12 * scale,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: packageState.packages.length,
                  itemBuilder: (context, index) {
                    final package = packageState.packages[index];
                    final isSelected = selectedPackageId == package.id;

                    return GestureDetector(
                      onTap: () {
                        onPackageSelected(package.id);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.2),
                                    blurRadius: 8 * scale,
                                    offset: Offset(0, 4 * scale),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 4 * scale,
                                    offset: Offset(0, 2 * scale),
                                  ),
                                ],
                        ),
                        child: PackageCard(
                          package: package,
                          onTap: () {
                            onPackageSelected(package.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox();
            },
          ),
        );
      },
    );
  }
}

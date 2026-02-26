import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_app_bar.dart';
import '../../domain/entities/package_entity.dart';
import '../bloc/package_bloc.dart';
import '../bloc/package_event.dart';
import '../bloc/package_state.dart';
import '../widgets/package_card.dart';
import '../widgets/package_filter_tabs.dart';
import '../../../../features/care_plan/presentation/widgets/care_plan_bottom_sheet.dart';

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PackageBloc>().add(const PackageLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: AppStrings.promotions,
        centerTitle: true,
        titleFontSize: 20 * scale,
        titleFontWeight: FontWeight.w700,
      ),
      body: BlocBuilder<PackageBloc, PackageState>(
        builder: (context, state) {
          if (state is PackageLoading) {
            return const Center(
              child: AppLoadingIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (state is PackageError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64 * scale,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    state.message,
                    style: AppTextStyles.arimo(
                      fontSize: 14 * scale,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24 * scale),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PackageBloc>().add(const PackageLoadRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: Text(
                      AppStrings.retry,
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is PackageLoaded) {
            final hasAnyPackages =
                state.centerPackages.isNotEmpty || state.homePackages.isNotEmpty;

            if (!hasAnyPackages) {
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
                      AppStrings.noPackages,
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                // Filter tabs
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20 * scale,
                    16 * scale,
                    20 * scale,
                    12 * scale,
                  ),
                  color: AppColors.background,
                  child: PackageFilterTabs(
                    currentFilter: state.currentFilter,
                    onFilterChanged: (filter) {
                      context.read<PackageBloc>().add(PackageFilterChanged(filter));
                    },
                  ),
                ),
                // Packages grid
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<PackageBloc>().add(const PackageRefresh());
                    },
                    color: AppColors.primary,
                    child: _buildPackageGrid(
                      context,
                      scale,
                      state.filteredPackages,
                      state.currentFilter == PackageFilter.center
                          ? AppStrings.noCenterPackages
                          : AppStrings.noHomePackages,
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPackageGrid(
    BuildContext context,
    double scale,
    List<PackageEntity> packages,
    String emptyMessage,
  ) {
    if (packages.isEmpty) {
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
              emptyMessage,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16 * scale),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16 * scale,
        mainAxisSpacing: 16 * scale,
        childAspectRatio: 0.75,
      ),
      itemCount: packages.length,
      itemBuilder: (context, index) {
        final package = packages[index];
        return PackageCard(
          package: package,
          onTap: () {
            CarePlanBottomSheet.show(
              context,
              packageId: package.id,
              packageName: package.packageName,
            );
          },
        );
      },
    );
  }
}

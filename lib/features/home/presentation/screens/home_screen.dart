import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/package/presentation/bloc/package_bloc.dart';
import '../../../../features/package/presentation/bloc/package_event.dart';
import '../../../../features/package/presentation/bloc/package_state.dart';
import '../../../../features/package/presentation/widgets/package_carousel.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../widgets/home_header.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_header.dart';
import '../widgets/upcoming_schedule_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.packageBloc..add(const PackageLoadRequested()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          String? username;
          String? avatarUrl;
          bool isEmailVerified = false;
          bool isLoading = true;

          if (authState is AuthCurrentAccountLoaded) {
            username = authState.account.displayName;
            avatarUrl = authState.account.avatarUrl;
            isEmailVerified = authState.account.isEmailVerified;
            isLoading = false;
          } else if (authState is AuthLoading) {
            isLoading = true;
          } else if (authState is AuthError) {
            username = 'User'; // Fallback to default
            isLoading = false;
          } else {
            isLoading = true;
          }

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: AppResponsive.pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top inset is already handled by SafeArea.
                  const SizedBox(height: 8),
                  HomeHeader(
                    userName: username,
                    avatarUrl: avatarUrl,
                    isEmailVerified: isEmailVerified,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Quick Actions Section
                  const SectionHeader(title: AppStrings.quickActions),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      QuickActionCard(
                        icon: Icons.spa_outlined,
                        title: AppStrings.spaAndCare,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        icon: Icons.child_care_outlined,
                        title: AppStrings.babyActivities,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        icon: Icons.restaurant_menu_outlined,
                        title: AppStrings.nutritionMenu,
                        onTap: () {},
                      ),
                      QuickActionCard(
                        icon: Icons.map_outlined,
                        title: AppStrings.resortMap,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Upcoming Schedule Section
                  SectionHeader(
                    title: AppStrings.upcomingSchedule,
                    actionText: AppStrings.viewAll,
                    onActionPressed: () {},
                  ),
                  const SizedBox(height: 16),
                  const UpcomingScheduleCard(
                    time: '10:00 AM',
                    title: 'Yoga cho mẹ bầu',
                    location: 'Phòng Zen',
                  ),
                  const SizedBox(height: 32),

                  // Promotions Section
                  Builder(
                    builder: (homeContext) => SectionHeader(
                      title: AppStrings.promotions,
                      actionText: AppStrings.viewAll,
                      onActionPressed: () {
                        AppRouter.push(context, AppRoutes.package);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<PackageBloc, PackageState>(
                    builder: (context, state) {
                      if (state is PackageLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: AppLoadingIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      if (state is PackageError) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[300]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  AppStrings.loadPackagesError,
                                  style: AppTextStyles.arimo(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (state is PackageLoaded) {
                        if (state.packages.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              AppStrings.noPackages,
                              style: AppTextStyles.arimo(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }

                        // Show packages in carousel slides
                        return PackageCarousel(
                          packages: state.packages,
                          onViewAll: () {
                            AppRouter.push(context, AppRoutes.package);
                          },
                          onPackageTap: (package) {
                            AppRouter.push(context, AppRoutes.package);
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

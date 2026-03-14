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
import '../widgets/section_header.dart';
import '../widgets/home_experience_sections.dart';

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
          final scale = AppResponsive.scaleFactor(context);
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

          final isHomeNurse = _isHomeNurse(authState);
          final quickActionsTitle = isHomeNurse
              ? AppStrings.quickActionsHomeNurse
              : AppStrings.quickActionsCenterNurse;
          final quickActions = _buildQuickActions(context, isHomeNurse);

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: AppResponsive.pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top inset is already handled by SafeArea.
                  SizedBox(height: 8 * scale),
                  HomeHeader(
                    userName: username,
                    avatarUrl: avatarUrl,
                    isEmailVerified: isEmailVerified,
                    isLoading: isLoading,
                  ),
                  SizedBox(height: 24 * scale),

                  // Quick Actions Section
                  SectionHeader(title: quickActionsTitle),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: quickActions,
                  ),
                  const SizedBox(height: 32),
                  // 1) Welcome section
                  const HomeWelcomeSection(),
                  SizedBox(height: 28 * scale),

                  // 2) Service / facility / cuisine gallery
                  const HomeServiceGallerySection(),
                  SizedBox(height: 28 * scale),

                  // 3) Hero banner
                  const HomeExperienceBanner(),
                  SizedBox(height: 28 * scale),

                  // 4) Testimonial banner with slide
                  const HomeTestimonialBanner(),
                  SizedBox(height: 28 * scale),

                  // 5) Continuous feedback image slider
                  const HomeLoveWallSection(),
                  SizedBox(height: 32 * scale),

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
                        if (state.centerPackages.isEmpty) {
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
                          packages: state.centerPackages,
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

  bool _isHomeNurse(AuthState authState) {
    if (authState is! AuthCurrentAccountLoaded) {
      return false;
    }

    final memberTypeName = authState.account.ownerProfile?.memberTypeName
        ?.toLowerCase()
        .trim();

    if (memberTypeName == null || memberTypeName.isEmpty) {
      return false;
    }

    return memberTypeName.contains('tại nhà') ||
        memberTypeName.contains('tai nha');
  }

  List<Widget> _buildQuickActions(BuildContext context, bool isHomeNurse) {
    if (isHomeNurse) {
      return [
        QuickActionCard(
          icon: Icons.map_outlined,
          title: AppStrings.quickActionRouteMap,
          onTap: () {
            AppRouter.push(context, AppRoutes.employeeCheckInOut);
          },
        ),
        QuickActionCard(
          icon: Icons.schedule_outlined,
          title: AppStrings.quickActionVisits,
          onTap: () {
            AppRouter.push(context, AppRoutes.employeeTasks);
          },
        ),
        QuickActionCard(
          icon: Icons.support_agent_outlined,
          title: AppStrings.quickActionSupport,
          onTap: () {
            AppRouter.push(context, AppRoutes.employeeRequests);
          },
        ),
        QuickActionCard(
          icon: Icons.assignment_outlined,
          title: AppStrings.quickActionReports,
          onTap: () {
            AppRouter.push(context, AppRoutes.employeeAppointmentList);
          },
        ),
      ];
    }

    return [
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
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/package/presentation/bloc/package_bloc.dart';
import '../../../../features/package/presentation/bloc/package_event.dart';
import '../../../../features/package/presentation/bloc/package_state.dart';
import '../../../../features/package/presentation/widgets/package_carousel.dart';
import '../../../../features/package/presentation/widgets/package_carousel_skeleton.dart';
import '../widgets/home_experience_sections.dart';
import '../widgets/home_header.dart';
import '../widgets/section_header.dart';

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
        builder: (context, _) {
          final scale = AppResponsive.scaleFactor(context);

          return SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sticky Header Section
                Container(
                  color: AppColors.background, // Ensure the header naturally masks the content below
                  padding: AppResponsive.pagePadding(context),
                  child: Column(
                    children: [
                      SizedBox(height: 4 * scale),
                      const HomeHeader(),
                      SizedBox(height: 2 * scale),
                      _ArtDivider(scale: scale),
                      SizedBox(height: 8 * scale),
                    ],
                  ),
                ),
                // Scrollable Content Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppResponsive.pagePadding(context).copyWith(top: 10 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HomeWelcomeSection(),
                        SizedBox(height: 28 * scale),

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
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0),
                          child: PackageCarouselSkeleton(),
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
                  SizedBox(height: 28 * scale),

                  const HomeLoveWallSection(),
                  SizedBox(height: 28 * scale),
                  const HomeTestimonialBanner(),

                  SizedBox(height: 28 * scale),
                  const HomeExperienceBanner(),

                  SizedBox(height: 32 * scale),

                  const HomeServiceGallerySection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  },
      ),
    );
  }
}

class _ArtDivider extends StatelessWidget {
  final double scale;

  const _ArtDivider({required this.scale});

  @override
  Widget build(BuildContext context) {
    final stroke = 1.2 * scale;
    final waveHeight = 14 * scale;
    final iconSize = 26 * scale;

    return SizedBox(
      height: 34 * scale,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: waveHeight,
              child: CustomPaint(
                painter: _SideWavePainter(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  strokeWidth: stroke,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          SvgPicture.asset(
            AppAssets.appIconFourth,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(3.141592653589793),
              child: SizedBox(
                height: waveHeight,
                child: CustomPaint(
                  painter: _SideWavePainter(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    strokeWidth: stroke,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideWavePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _SideWavePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final centerY = size.height / 2;

    final path = Path()
      ..moveTo(0, centerY)
      ..cubicTo(
        size.width * 0.18,
        centerY - size.height * 0.60,
        size.width * 0.38,
        centerY + size.height * 0.65,
        size.width * 0.56,
        centerY,
      )
      ..cubicTo(
        size.width * 0.74,
        centerY - size.height * 0.65,
        size.width * 0.88,
        centerY + size.height * 0.45,
        size.width,
        centerY,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SideWavePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

/// 1) Welcome information section with intro text and small icons row.
class HomeWelcomeSection extends StatelessWidget {
  const HomeWelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeWelcomeTitle,
          style: AppTextStyles.tinos(
            fontSize: 21 * scale,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          AppStrings.homeWelcomeSubtitle,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 20 * scale),
        Text(
          AppStrings.homeWelcomeDescription,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ).copyWith(
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 28 * scale),
        Center(
          child: SvgPicture.asset(
            AppAssets.appIconFourth,
            height: 40 * scale,
          ),
        ),
      ],
    );
  }
}

/// 2) Service / facility / cuisine image collage section.
class HomeServiceGallerySection extends StatelessWidget {
  const HomeServiceGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeServiceGalleryTitle,
          style: AppTextStyles.tinos(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12 * scale),
        Text(
          AppStrings.homeServiceGallerySubtitle,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16 * scale),
        ClipRRect(
          borderRadius: BorderRadius.circular(18 * scale),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              AppAssets.homeServiceMain,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 12 * scale),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18 * scale),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    AppAssets.homeServiceCuisine,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8 * scale),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18 * scale),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    AppAssets.homeServiceCare,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8 * scale),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            AppStrings.homeServiceGalleryNote,
            style: AppTextStyles.arimo(
              fontSize: 11 * scale,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

/// 3) Large hero banner "The Joyful Experience".
class HomeExperienceBanner extends StatelessWidget {
  const HomeExperienceBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24 * scale),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              AppAssets.homeExperienceBanner,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 20 * scale,
            right: 20 * scale,
            top: 24 * scale,
            bottom: 24 * scale,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppStrings.homeExperienceTitle,
                  style: AppTextStyles.tinos(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  AppStrings.homeExperienceSubtitle,
                  style: AppTextStyles.arimo(
                    fontSize: 13 * scale,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 10 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(999 * scale),
                  ),
                  child: Text(
                    AppStrings.homeExperienceCta,
                    style: AppTextStyles.arimo(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple testimonial model for mock data.
class _HomeTestimonial {
  final String name;
  final String location;
  final String message;

  const _HomeTestimonial({
    required this.name,
    required this.location,
    required this.message,
  });
}

/// 4) Banner with feedback slide (mock data, no API yet).
class HomeTestimonialBanner extends StatefulWidget {
  const HomeTestimonialBanner({super.key});

  @override
  State<HomeTestimonialBanner> createState() => _HomeTestimonialBannerState();
}

class _HomeTestimonialBannerState extends State<HomeTestimonialBanner> {
  late final PageController _pageController;
  late final List<_HomeTestimonial> _testimonials;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _testimonials = const [
      _HomeTestimonial(
        name: 'H\'Hen Niê',
        location: 'TP. Hồ Chí Minh',
        message: AppStrings.homeTestimonialSample1,
      ),
      _HomeTestimonial(
        name: 'Tuyết Lan',
        location: 'TP. Hồ Chí Minh',
        message: AppStrings.homeTestimonialSample2,
      ),
      _HomeTestimonial(
        name: 'Gia đình Quỳnh & bé N.' ,
        location: 'Hà Nội',
        message: AppStrings.homeTestimonialSample3,
      ),
    ];

    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!_pageController.hasClients || _testimonials.isEmpty) return;
      final nextPage =
          (_pageController.page ?? 0).round() + 1 >= _testimonials.length
              ? 0
              : (_pageController.page ?? 0).round() + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeTestimonialTitle,
          style: AppTextStyles.tinos(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12 * scale),
        SizedBox(
          height: 240 * scale,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18 * scale),
            child: Stack(
              children: [
                // Single shared background image for all feedback slides
                Positioned.fill(
                  child: Image.asset(
                    AppAssets.homeTestimonialBackground,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                // Sliding feedback cards on top of background
                PageView.builder(
                  controller: _pageController,
                  itemCount: _testimonials.length,
                  itemBuilder: (context, index) {
                    final item = _testimonials[index];
                    final initials = item.name.trim().isNotEmpty
                        ? item.name.trim().characters.first
                        : '?';

                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(
                          20 * scale,
                          24 * scale,
                          24 * scale,
                          24 * scale,
                        ),
                        padding: EdgeInsets.all(20 * scale),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18 * scale,
                              offset: Offset(0, 6 * scale),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Text(
                                  '"${item.message}"',
                                  style: AppTextStyles.arimo(
                                    fontSize: 13 * scale,
                                    color: AppColors.textPrimary,
                                  ).copyWith(height: 1.5),
                                ),
                              ),
                            ),
                            SizedBox(height: 16 * scale),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18 * scale,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    initials.toUpperCase(),
                                    style: AppTextStyles.tinos(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10 * scale),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: AppTextStyles.tinos(
                                        fontSize: 14 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      item.location,
                                      style: AppTextStyles.arimo(
                                        fontSize: 12 * scale,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 5) Love-wall style continuous slider with feedback images.
class HomeLoveWallSection extends StatefulWidget {
  const HomeLoveWallSection({super.key});

  @override
  State<HomeLoveWallSection> createState() => _HomeLoveWallSectionState();
}

class _HomeLoveWallSectionState extends State<HomeLoveWallSection> {
  late final PageController _pageController;
  late final List<String> _imagePaths;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _imagePaths = const [
      AppAssets.homeLoveWall1,
      AppAssets.homeLoveWall2,
      AppAssets.homeLoveWall3,
      AppAssets.homeLoveWall4,
      AppAssets.homeLoveWall5,
    ];
    _pageController = PageController(
      viewportFraction: 0.6,
      initialPage: _imagePaths.length * 1000,
    );

    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_pageController.hasClients || _imagePaths.isEmpty) return;
      final nextPage = (_pageController.page ?? 0) + 1;
      _pageController.animateToPage(
        nextPage.toInt(),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.homeLoveWallTitle,
          style: AppTextStyles.tinos(
            fontSize: 20 * scale,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          AppStrings.homeLoveWallSubtitle,
          style: AppTextStyles.arimo(
            fontSize: 13 * scale,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 16 * scale),
        SizedBox(
          height: 180 * scale,
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              final imageIndex = index % _imagePaths.length;
              final path = _imagePaths[imageIndex];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 6 * scale),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18 * scale),
                  child: Image.asset(
                    path,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


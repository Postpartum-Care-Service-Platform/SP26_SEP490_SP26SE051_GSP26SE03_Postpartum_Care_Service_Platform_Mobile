import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../domain/entities/package_entity.dart';
import 'package_card.dart';
import '../../../care_plan/presentation/widgets/care_plan_bottom_sheet.dart';

class PackageCarousel extends StatefulWidget {
  final List<PackageEntity> packages;
  final VoidCallback? onViewAll;
  final Function(PackageEntity)? onPackageTap;

  const PackageCarousel({
    super.key,
    required this.packages,
    this.onViewAll,
    this.onPackageTap,
  });

  @override
  State<PackageCarousel> createState() => _PackageCarouselState();
}

class _PackageCarouselState extends State<PackageCarousel> {
  late PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.packages.isEmpty) return;

    // Create PageController with initial page in the middle for infinite scroll
    _pageController = PageController(
      initialPage: widget.packages.length * 1000, // Start in the middle
      viewportFraction: 0.85,
    );

    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.packages.isEmpty) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_pageController.hasClients) return;

      final nextPage = _currentPage + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    if (widget.packages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 220 * scale,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: widget.packages.length * 2000, // Infinite scroll
            itemBuilder: (context, index) {
              final packageIndex = index % widget.packages.length;
              final package = widget.packages[packageIndex];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: PackageCard(
                  package: package,
                  onTap: () {
                    if (widget.onPackageTap != null) {
                      widget.onPackageTap!.call(package);
                    } else {
                      // Default: show care plan bottom sheet
                      CarePlanBottomSheet.show(
                        context,
                        packageId: package.id,
                        packageName: package.packageName,
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12 * scale),
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.packages.length,
            (index) => _buildPageIndicator(
              index == (_currentPage % widget.packages.length),
              scale,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive, double scale) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4 * scale),
      width: isActive ? 24 * scale : 8 * scale,
      height: 8 * scale,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4 * scale),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import 'package_skeleton_card.dart';

class PackageCarouselSkeleton extends StatelessWidget {
  const PackageCarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return Column(
      children: [
        SizedBox(
          height: 220 * scale,
          child: PageView.builder(
            itemCount: 3,
            controller: PageController(viewportFraction: 0.85),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale),
                child: const PackageSkeletonCard(),
              );
            },
          ),
        ),
        SizedBox(height: 12 * scale),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.symmetric(horizontal: 4 * scale),
              width: 8 * scale,
              height: 8 * scale,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4 * scale),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

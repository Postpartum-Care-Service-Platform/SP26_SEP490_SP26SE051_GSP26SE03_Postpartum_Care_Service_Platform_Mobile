import 'package:flutter/material.dart';
import '../../../../core/utils/app_responsive.dart';
import 'package_skeleton_card.dart';

class PackageGridSkeleton extends StatelessWidget {
  const PackageGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GridView.builder(
      padding: EdgeInsets.all(16 * scale),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 16 * scale,
        mainAxisSpacing: 16 * scale,
        childAspectRatio: 2.2,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const PackageSkeletonCard();
      },
    );
  }
}

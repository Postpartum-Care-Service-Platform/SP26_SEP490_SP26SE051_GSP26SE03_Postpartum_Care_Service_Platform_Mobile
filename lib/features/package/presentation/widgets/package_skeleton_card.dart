import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';

class PackageSkeletonCard extends StatefulWidget {
  const PackageSkeletonCard({super.key});

  @override
  State<PackageSkeletonCard> createState() => _PackageSkeletonCardState();
}

class _PackageSkeletonCardState extends State<PackageSkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 0.8).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          color: AppColors.background,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16 * scale),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Skeleton shapes
                Positioned(
                  top: 12 * scale,
                  right: 8 * scale,
                  child: _SkeletonBar(width: 50 * scale, height: 20 * scale),
                ),
                Positioned(
                  top: 12 * scale,
                  left: 12 * scale,
                  child: _SkeletonBar(width: 80 * scale, height: 20 * scale),
                ),
                Positioned(
                  left: 10 * scale,
                  bottom: 8 * scale,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBar(width: 150 * scale, height: 24 * scale),
                      SizedBox(height: 6 * scale),
                      _SkeletonBar(width: 100 * scale, height: 16 * scale),
                    ],
                  ),
                ),
                Positioned(
                  right: 10 * scale,
                  bottom: 8 * scale,
                  child: _SkeletonBar(width: 70 * scale, height: 16 * scale),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

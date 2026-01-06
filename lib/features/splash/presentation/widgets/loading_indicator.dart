import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        backgroundColor: AppColors.loadingBackground, // A bit more visible on light background
      ),
    );
  }
}

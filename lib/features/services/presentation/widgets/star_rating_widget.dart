import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/app_responsive.dart';

/// Star Rating Widget
/// Allows user to select rating from 1-5 stars
class StarRatingWidget extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;
  final bool interactive;

  const StarRatingWidget({
    super.key,
    this.initialRating = 0,
    required this.onRatingChanged,
    this.starSize = 32,
    this.interactive = true,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  late int _currentRating;
  final Map<int, double> _starScales = {};

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
    // Initialize all star scales to 1.0
    for (int i = 1; i <= 5; i++) {
      _starScales[i] = 1.0;
    }
  }

  @override
  void didUpdateWidget(StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRating != widget.initialRating) {
      _currentRating = widget.initialRating;
    }
  }

  void _onStarTap(int rating) {
    if (!widget.interactive) return;
    
    setState(() {
      _currentRating = rating;
      // Animate the tapped star
      _starScales[rating] = 1.15;
    });
    
    // Smooth animation back to normal size
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _starScales[rating] = 1.0;
        });
      }
    });
    
    widget.onRatingChanged(rating);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final size = widget.starSize * scale;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final isFilled = starIndex <= _currentRating;
        final starScale = _starScales[starIndex] ?? 1.0;

        return GestureDetector(
          onTap: widget.interactive ? () => _onStarTap(starIndex) : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2 * scale),
            child: AnimatedScale(
              scale: starScale,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              child: SvgPicture.asset(
                AppAssets.starRating,
                width: size,
                height: size,
                colorFilter: ColorFilter.mode(
                  isFilled
                      ? AppColors.starRating
                      : AppColors.textSecondary.withValues(alpha: 0.3),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

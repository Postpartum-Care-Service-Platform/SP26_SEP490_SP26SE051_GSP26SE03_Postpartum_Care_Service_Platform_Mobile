import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class ServiceActionCard extends StatefulWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final VoidCallback onTap;

  const ServiceActionCard({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    required this.onTap,
  }) : assert(icon != null || iconWidget != null,
            'Either icon or iconWidget must be provided');

  @override
  State<ServiceActionCard> createState() => _ServiceActionCardState();
}

class _ServiceActionCardState extends State<ServiceActionCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
            borderRadius: BorderRadius.circular(20 * scale),
            border: Border.all(
              color: _isPressed
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.borderLight,
              width: 1.2 * scale,
            ),
          boxShadow: [
            BoxShadow(
                color: _isPressed
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _isPressed ? 16 * scale : 12 * scale,
                offset: Offset(0, _isPressed ? 6 * scale : 4 * scale),
                spreadRadius: _isPressed ? 2 * scale : 0,
            ),
          ],
        ),
          padding: EdgeInsets.all(20 * scale),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              // Icon Section
              widget.iconWidget != null
                  ? SizedBox(
                      width: 44 * scale,
                      height: 44 * scale,
                      child: widget.iconWidget,
                    )
                  : Icon(
                      widget.icon,
                      size: 44 * scale,
                      color: AppColors.primary,
                    ),
              SizedBox(height: 16 * scale),
              
              // Title - Centered
            Text(
                widget.title,
              style: AppTextStyles.arimo(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
                textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            ],
            ),
        ),
      ),
    );
  }
}

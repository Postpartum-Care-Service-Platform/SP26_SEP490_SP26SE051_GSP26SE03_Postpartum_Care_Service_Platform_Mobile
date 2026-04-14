import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';
import '../../../../core/utils/app_text_styles.dart';

class ServiceActionCard extends StatefulWidget {
  final IconData? icon;
  final Widget? iconWidget;
  final String title;
  final VoidCallback onTap;
  final bool isEnabled;

  const ServiceActionCard({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    required this.onTap,
    this.isEnabled = true,
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
      onTapDown: widget.isEnabled
          ? (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            }
          : null,
      onTapUp: widget.isEnabled
          ? (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: widget.isEnabled
          ? () {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Opacity(
          opacity: widget.isEnabled ? 1.0 : 0.6,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20 * scale),
              border: Border.all(
                color: _isPressed && widget.isEnabled
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.borderLight,
                width: 1.2 * scale,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isPressed && widget.isEnabled
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  blurRadius: _isPressed && widget.isEnabled ? 16 * scale : 12 * scale,
                  offset: Offset(0, _isPressed && widget.isEnabled ? 6 * scale : 4 * scale),
                  spreadRadius: _isPressed && widget.isEnabled ? 2 * scale : 0,
                ),
              ],
            ),
            padding: EdgeInsets.all(20 * scale),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Section
                    widget.iconWidget != null
                        ? SizedBox(
                            width: 44 * scale,
                            height: 44 * scale,
                            child: widget.isEnabled
                                ? widget.iconWidget
                                : GreyscaleWidget(child: widget.iconWidget!),
                          )
                        : Icon(
                            widget.icon,
                            size: 44 * scale,
                            color: widget.isEnabled
                                ? AppColors.primary
                                : AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                    SizedBox(height: 16 * scale),

                    // Title - Centered
                    Text(
                      widget.title,
                      style: AppTextStyles.arimo(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w700,
                        color: widget.isEnabled
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                if (!widget.isEnabled)
                  Positioned(
                    top: -10 * scale,
                    right: -10 * scale,
                    child: Container(
                      padding: EdgeInsets.all(4 * scale),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 14 * scale,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GreyscaleWidget extends StatelessWidget {
  final Widget child;
  const GreyscaleWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0,      0,      0,      1, 0,
      ]),
      child: child,
    );
  }
}

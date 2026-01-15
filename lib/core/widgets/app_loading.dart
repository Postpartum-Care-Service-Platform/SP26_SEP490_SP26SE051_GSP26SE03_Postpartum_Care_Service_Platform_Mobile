import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';

/// Loading overlay widget - Full screen loading cover
class AppLoading {
  AppLoading._();

  static OverlayEntry? _currentEntry;

  /// Show loading overlay
  static void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    // Remove existing loading if any
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _LoadingWidget(
        message: message,
        barrierDismissible: barrierDismissible,
        onDismiss: () {
          overlayEntry.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = overlayEntry;
    overlay.insert(overlayEntry);
  }

  /// Hide loading overlay
  static void hide(BuildContext context) {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

/// Reusable loading indicator widget with rotating icon
class AppLoadingIndicator extends StatefulWidget {
  final double? size;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.size,
    this.color,
  });

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final size = widget.size ?? (48 * scale);

    return RotationTransition(
      turns: _rotationAnimation,
      child: SvgPicture.asset(
        'assets/images/app_icon_3.svg',
        width: size,
        height: size,
        colorFilter: widget.color != null
            ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
            : null,
      ),
    );
  }
}

class _LoadingWidget extends StatefulWidget {
  final String? message;
  final bool barrierDismissible;
  final VoidCallback onDismiss;

  const _LoadingWidget({
    this.message,
    required this.barrierDismissible,
    required this.onDismiss,
  });

  @override
  State<_LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<_LoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    // Fade animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Rotation animation controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    if (widget.barrierDismissible) {
      _controller.reverse().then((_) {
        if (mounted) {
          widget.onDismiss();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return FadeTransition(
      opacity: _opacityAnimation,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: widget.barrierDismissible ? _handleDismiss : null,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24 * scale),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 16 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: SvgPicture.asset(
                        'assets/images/app_icon_3.svg',
                        width: 64 * scale,
                        height: 64 * scale,
                      ),
                    ),
                    if (widget.message != null) ...[
                      SizedBox(height: 16 * scale),
                      Text(
                        widget.message!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


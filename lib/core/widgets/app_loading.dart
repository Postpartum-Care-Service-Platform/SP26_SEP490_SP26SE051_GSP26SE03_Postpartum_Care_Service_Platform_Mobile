import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
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

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    SizedBox(
                      width: 48 * scale,
                      height: 48 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 4 * scale,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
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


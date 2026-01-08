import 'package:flutter/material.dart';

/// Toast notification types
enum ToastType {
  success,
  error,
  warning,
  info,
}

/// Toast notification widget
class AppToast {
  AppToast._();

  static OverlayEntry? _currentEntry;

  /// Show toast notification
  static void show(
    BuildContext context, {
    required String message,
    required ToastType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Remove existing toast if any
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          overlayEntry.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = overlayEntry;
    overlay.insert(overlayEntry);
  }

  /// Show success toast
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, type: ToastType.success, duration: duration);
  }

  /// Show error toast
  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, type: ToastType.error, duration: duration);
  }

  /// Show warning toast
  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, type: ToastType.warning, duration: duration);
  }

  /// Show info toast
  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(context, message: message, type: ToastType.info, duration: duration);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    Future.delayed(widget.duration - const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) {
            widget.onDismiss();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


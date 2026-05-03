import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_responsive.dart';

/// A draggable floating action button with AI sparkle icon
class AiRecommendFab extends StatefulWidget {
  final VoidCallback onTap;

  const AiRecommendFab({super.key, required this.onTap});

  @override
  State<AiRecommendFab> createState() => _AiRecommendFabState();
}

class _AiRecommendFabState extends State<AiRecommendFab>
    with SingleTickerProviderStateMixin {
  double _xPos = double.infinity; // will be clamped on first build
  double _yPos = double.infinity;
  bool _initialized = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final fabSize = 56.0 * scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        // Initialize position if not set
        if (!_initialized) {
          _xPos = maxWidth - fabSize - 16 * scale;
          _yPos = maxHeight * 0.7; // Start near bottom-right of content area
          _initialized = true;
        }

        // Clamp to parent constraints with extra padding for safety
        // This ensures it stays within the Stack (which is inside the Expanded area)
        _xPos = _xPos.clamp(8 * scale, maxWidth - fabSize - 8 * scale);
        _yPos = _yPos.clamp(8 * scale, maxHeight - fabSize - 8 * scale);

        return Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              left: _xPos,
              top: _yPos,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _xPos += details.delta.dx;
                    _yPos += details.delta.dy;
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    // Snap to closest side
                    if (_xPos < maxWidth / 2) {
                      _xPos = 8 * scale;
                    } else {
                      _xPos = maxWidth - fabSize - 8 * scale;
                    }
                  });
                },
                onTap: widget.onTap,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    width: fabSize,
                    height: fabSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFF8C00).withValues(alpha: 0.85),
                          const Color(0xFFFF6B00).withValues(alpha: 0.85),
                          const Color(0xFFE85D04).withValues(alpha: 0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12 * scale,
                          spreadRadius: 1 * scale,
                          offset: Offset(0, 4 * scale),
                        ),
                        BoxShadow(
                          color: const Color(
                            0xFFFF8C00,
                          ).withValues(alpha: 0.15),
                          blurRadius: 16 * scale,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 28 * scale,
                        ),
                        Positioned(
                          right: 6 * scale,
                          top: 6 * scale,
                          child: Container(
                            width: 10 * scale,
                            height: 10 * scale,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.greenAccent.withValues(alpha: 0.9),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.8),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

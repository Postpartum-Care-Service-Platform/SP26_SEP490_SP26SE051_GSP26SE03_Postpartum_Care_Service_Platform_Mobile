import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';
import '../utils/app_text_styles.dart';

/// Optimized reusable drawer form widget with smooth animations
class AppDrawerForm extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;
  final bool isLoading;
  final bool isDisabled;
  final String? saveButtonText;
  final bool isCompact;

  const AppDrawerForm({
    super.key,
    required this.title,
    required this.children,
    this.onSave,
    this.isLoading = false,
    this.isDisabled = false,
    this.saveButtonText,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    
    // Pre-calculate values to avoid recalculation during rebuilds
    final handleBarColor = AppColors.textSecondary.withValues(alpha: 0.3);
    final borderRadius = 24 * scale;
    final shadowBlur = 24 * scale;
    final shadowOffset = -8 * scale;

    return DraggableScrollableSheet(
      initialChildSize: isCompact ? 0.5 : 0.9,
      minChildSize: isCompact ? 0.3 : 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: shadowBlur,
                offset: Offset(0, shadowOffset),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
              // Handle bar - optimized with const
              _HandleBar(scale: scale, color: handleBarColor),
              
              // Header - separated for better repaint optimization
              _Header(
                title: title,
                scale: scale,
                onClose: () => Navigator.of(context).pop(),
              ),

              // Form Content - optimized scroll view
              Flexible(
                child: _Content(
                  scrollController: scrollController,
                  children: children,
                  scale: scale,
                  isCompact: isCompact,
                ),
              ),

              // Footer with Save Button - separated widget for optimization
              if (onSave != null)
                _Footer(
                  onSave: onSave!,
                  isLoading: isLoading,
                  isDisabled: isDisabled,
                  saveButtonText: saveButtonText,
                  scale: scale,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Handle bar widget - optimized with const and RepaintBoundary
class _HandleBar extends StatelessWidget {
  final double scale;
  final Color color;

  const _HandleBar({
    required this.scale,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
              padding: EdgeInsets.only(top: 12 * scale, bottom: 8 * scale),
              child: Container(
                width: 48 * scale,
                height: 5 * scale,
                decoration: BoxDecoration(
            color: color,
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
            ),
    );
  }
}

/// Header widget - optimized with RepaintBoundary
class _Header extends StatelessWidget {
  final String title;
  final double scale;
  final VoidCallback onClose;

  const _Header({
    required this.title,
    required this.scale,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 8 * scale,
              ),
              child: Row(
                children: [
            // Close button - optimized tap target
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onClose,
                borderRadius: BorderRadius.circular(20 * scale),
                child: Container(
                  width: 40 * scale,
                  height: 40 * scale,
                  alignment: Alignment.center,
                  child: Icon(
                      Icons.close_rounded,
                      color: AppColors.textPrimary,
                      size: 20 * scale,
                    ),
                ),
                    ),
                  ),
            // Title - centered
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tinos(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
            // Balance spacer
            SizedBox(width: 40 * scale),
                ],
              ),
            ),
    );
  }
}

/// Content widget - optimized scroll performance
class _Content extends StatelessWidget {
  final ScrollController scrollController;
  final List<Widget> children;
  final double scale;
  final bool isCompact;

  const _Content({
    required this.scrollController,
    required this.children,
    required this.scale,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16 * scale,
                  vertical: 8 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: children,
                ),
      );
    }

    return SingleChildScrollView(
      controller: scrollController,
      physics: const ClampingScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 8 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
    );
  }
}

/// Footer widget - optimized button rendering
class _Footer extends StatelessWidget {
  final VoidCallback onSave;
  final bool isLoading;
  final bool isDisabled;
  final String? saveButtonText;
  final double scale;

  const _Footer({
    required this.onSave,
    required this.isLoading,
    required this.isDisabled,
    required this.saveButtonText,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  12 * scale,
                  16 * scale,
                  16 * scale,
                ),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8 * scale,
              offset: Offset(0, -2 * scale),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48 * scale,
            child: _OptimizedButton(
              onPressed: (isLoading || isDisabled) ? null : onSave,
              isLoading: isLoading,
              text: saveButtonText ?? 'Lưu',
              scale: scale,
            ),
          ),
        ),
      ),
    );
  }
}

/// Optimized button widget with better performance
class _OptimizedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final double scale;

  const _OptimizedButton({
    required this.onPressed,
    required this.isLoading,
    required this.text,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: onPressed != null ? AppColors.primary : AppColors.third,
                        borderRadius: BorderRadius.circular(16 * scale),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16 * scale),
          child: Container(
            alignment: Alignment.center,
                    child: isLoading
                        ? SizedBox(
                            width: 22 * scale,
                            height: 22 * scale,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : Text(
                    text,
                            style: AppTextStyles.arimo(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
          ),
        ),
      ),
    );
  }
}

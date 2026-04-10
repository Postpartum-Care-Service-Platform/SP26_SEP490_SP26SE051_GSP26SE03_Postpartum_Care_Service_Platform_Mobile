import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';
import '../utils/app_text_styles.dart';

/// Optimized reusable drawer form widget with smooth animations
/// Automatically adjusts size based on content
class AppDrawerForm extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;
  final bool isLoading;
  final bool isDisabled;
  final String? saveButtonText;
  final IconData? saveButtonIcon;
  final bool isCompact;

  const AppDrawerForm({
    super.key,
    required this.title,
    required this.children,
    this.onSave,
    this.isLoading = false,
    this.isDisabled = false,
    this.saveButtonText,
    this.saveButtonIcon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    
    // Pre-calculate values to avoid recalculation during rebuilds
    final borderRadius = 24 * scale;
    final shadowBlur = 24 * scale;
    final shadowOffset = -8 * scale;
    
    // Make drawer wrap its content smoothly without taking full screen or redundant height
    return Padding(
      // Add padding for keyboard to push it up
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 24 * scale,
        ),
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
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Hug content closely
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Optionally some spacing can be added here if needed, but keeping it compact
              SizedBox(height: 8 * scale),
              
              // Header
              _Header(
                title: title,
                scale: scale,
                onClose: () => Navigator.of(context).pop(),
              ),

              // Form Content - scrollable if too tall
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 8 * scale,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: children,
                  ),
                ),
              ),

              // Footer with Save Button
              if (onSave != null)
                _Footer(
                  onSave: onSave!,
                  isLoading: isLoading,
                  isDisabled: isDisabled,
                  saveButtonText: saveButtonText,
                  saveButtonIcon: saveButtonIcon,
                  scale: scale,
                ),
            ],
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

/// Footer widget - optimized button rendering
class _Footer extends StatelessWidget {
  final VoidCallback onSave;
  final bool isLoading;
  final bool isDisabled;
  final String? saveButtonText;
  final IconData? saveButtonIcon;
  final double scale;

  const _Footer({
    required this.onSave,
    required this.isLoading,
    required this.isDisabled,
    required this.saveButtonText,
    required this.saveButtonIcon,
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
              icon: saveButtonIcon,
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
  final IconData? icon;
  final double scale;

  const _OptimizedButton({
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.icon,
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
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (icon != null) ...[
                                Icon(
                                  icon,
                                  size: 20 * scale,
                                  color: AppColors.white,
                                ),
                                SizedBox(width: 8 * scale),
                              ],
                              Text(
                                text,
                                style: AppTextStyles.arimo(
                                  fontSize: 17 * scale,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
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

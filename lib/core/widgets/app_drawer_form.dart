import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';
import '../utils/app_text_styles.dart';

/// Reusable drawer form widget
class AppDrawerForm extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onSave;
  final bool isLoading;
  final String? saveButtonText;

  const AppDrawerForm({
    super.key,
    required this.title,
    required this.children,
    this.onSave,
    this.isLoading = false,
    this.saveButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);

    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24 * scale)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 24 * scale,
              offset: Offset(0, -8 * scale),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Handle bar
            Padding(
              padding: EdgeInsets.only(top: 12 * scale, bottom: 8 * scale),
              child: Container(
                width: 48 * scale,
                height: 5 * scale,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16 * scale,
                vertical: 8 * scale,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textPrimary,
                      size: 20 * scale,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20 * scale,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 40 * scale,
                      minHeight: 40 * scale,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.tinos(
                        fontSize: 18 * scale,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 40 * scale), // balance with close button space
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
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

            // Footer with Save Button (only show when onSave is provided)
            if (onSave != null)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  12 * scale,
                  16 * scale,
                  16 * scale,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48 * scale,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.third,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16 * scale),
                      ),
                      elevation: 2,
                    ),
                    child: isLoading
                        ? SizedBox(
                            width: 22 * scale,
                            height: 22 * scale,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                        : Text(
                            saveButtonText ?? 'Lưu',
                            style: AppTextStyles.arimo(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

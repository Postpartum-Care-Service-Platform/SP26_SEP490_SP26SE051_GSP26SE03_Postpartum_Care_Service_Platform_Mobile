import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_responsive.dart';

/// App Widgets - Reusable widgets following clean architecture principles
class AppWidgets {
  AppWidgets._();

  /// Primary Button - Orange background with white text
  static Widget primaryButton({
    required String text,
    required VoidCallback onPressed,
    double? width,
    double? height,
    bool isEnabled = true,
    Widget? icon,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.third,
          foregroundColor: AppColors.textOnPrimary,
          disabledForegroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          animationDuration: const Duration(milliseconds: 200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTextStyles.arimo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Secondary Button - White background with black border
  static Widget secondaryButton({
    required String text,
    required VoidCallback onPressed,
    Widget? icon,
    double? width,
    double? height,
    bool isEnabled = true,
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.googleButtonBackground,
          disabledBackgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.third,
          side: BorderSide(
            color: isEnabled 
                ? AppColors.googleButtonBorder 
                : AppColors.borderLight,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          animationDuration: const Duration(milliseconds: 200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: AppTextStyles.arimo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Text Input Field - Reusable text field with label.
  ///
  /// Refactor note:
  /// - Responsive behavior should be handled at screen/layout level (max width, padding).
  /// - This widget only guarantees a stable *field box size* and shows error text below,
  ///   without affecting the field's width/height.
  static Widget textInput({
    required String label,
    required String placeholder,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Field box: fixed height, full width of its parent.
        SizedBox(
          width: double.infinity,
          height: 52,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            obscureText: isPassword && obscureText,
            validator: validator,
            maxLines: 1,
            minLines: 1,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textSecondary,
              ),
              filled: true,
              fillColor: AppColors.white,
              // Add subtle shadow
              // Note: InputDecoration doesn't support boxShadow directly,
              // but we can wrap the TextFormField in a Container if needed

              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),

              border: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.borderLight,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),

              // Hide Flutter's built-in error text to prevent it affecting layout.
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              errorMaxLines: 1,

              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off,
                        size: 19.993,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: onTogglePassword,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  /// Link Text - Clickable text with primary color
  static Widget linkText({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: AppTextStyles.arimo(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Section header text with consistent padding and style
  static Widget sectionHeader(
    BuildContext context, {
    required String title,
    EdgeInsets? padding,
    Color? color,
    double? fontSize,
  }) {
    final scale = AppResponsive.scaleFactor(context);
    return Padding(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 20 * scale,
            vertical: 8 * scale,
          ),
      child: Text(
        title,
        style: AppTextStyles.arimo(
          fontSize: (fontSize ?? 12) * scale,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textSecondary,
        ).copyWith(letterSpacing: 0.5),
      ),
    );
  }

  /// Section container card with shadow and radius
  static Widget sectionContainer(
    BuildContext context, {
    required List<Widget> children,
    EdgeInsets? margin,
    EdgeInsets? padding,
    double? radius,
    bool withShadow = true,
    Color? color,
  }) {
    final scale = AppResponsive.scaleFactor(context);
    return Container(
      margin: margin ??
          EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 4 * scale),
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular((radius ?? 16) * scale),
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ]
            : null,
      ),
      child: Column(children: children),
    );
  }

  /// Pill badge for small labels (e.g., role, relationship)
  static Widget pillBadge(
    BuildContext context, {
    required String text,
    Color? background,
    Color? textColor,
    Color? borderColor,
    IconData? icon,
    double? fontSize,
    double? radius,
    EdgeInsets? padding,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    final scale = AppResponsive.scaleFactor(context);
    return Container(
      padding: padding ??
          EdgeInsets.symmetric(
            horizontal: 8 * scale,
            vertical: 4 * scale,
          ),
      decoration: BoxDecoration(
        color: background ?? AppColors.textSecondary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular((radius ?? 6) * scale),
        border: Border.all(
          color: borderColor ?? AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11 * scale, color: textColor ?? AppColors.textPrimary),
            SizedBox(width: 4 * scale),
          ],
          Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: (fontSize ?? 10) * scale,
              fontWeight: fontWeight,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Divider with "or" text in the middle
  static Widget orDivider() {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(
          color: AppColors.borderLight,
          thickness: 1.207,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15.99),
          color: AppColors.background,
          child: Text(
            AppStrings.or,
            style: AppTextStyles.arimo(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// OTP Input Row - Reusable 1-line OTP input with fixed-length boxes
  static Widget otpInputRow({
    required int length,
    required List<TextEditingController> controllers,
    required List<FocusNode> focusNodes,
    required void Function(int index, String value) onChanged,
    double boxWidth = 48,
    double boxHeight = 56,
    double spacing = 4,
  }) {
    assert(controllers.length >= length, 'controllers length must be >= length');
    assert(focusNodes.length >= length, 'focusNodes length must be >= length');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (index) => Container(
          width: boxWidth,
          height: boxHeight,
          margin: EdgeInsets.symmetric(horizontal: spacing),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: AppTextStyles.arimo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => onChanged(index, value),
          ),
        ),
      ),
    );
  }

  /// Reusable confirmation dialog (returns true if confirmed, false/null otherwise)
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    Color? confirmColor,
    IconData? icon,
  }) {
    final themeConfirmColor = confirmColor ?? AppColors.primary;
    final scale = AppResponsive.scaleFactor(context);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 24 * scale),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18 * scale),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(20 * scale, 20 * scale, 20 * scale, 12 * scale),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18 * scale),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (icon != null) ...[
                Container(
                  width: 44 * scale,
                  height: 44 * scale,
                  decoration: BoxDecoration(
                    color: themeConfirmColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: themeConfirmColor, size: 22 * scale),
                ),
                SizedBox(height: 12 * scale),
              ],
              Text(
                title,
                style: AppTextStyles.tinos(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 10 * scale),
              Text(
                message,
                style: AppTextStyles.arimo(
                  fontSize: 14 * scale,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16 * scale),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: BorderSide(
                          color: AppColors.borderLight,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        animationDuration: const Duration(milliseconds: 200),
                      ),
                      child: Text(
                        cancelText ?? AppStrings.cancel,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12 * scale),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeConfirmColor,
                        foregroundColor: AppColors.white,
                        elevation: 2,
                        shadowColor: themeConfirmColor.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14 * scale),
                        animationDuration: const Duration(milliseconds: 200),
                      ),
                      child: Text(
                        confirmText ?? AppStrings.logout,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

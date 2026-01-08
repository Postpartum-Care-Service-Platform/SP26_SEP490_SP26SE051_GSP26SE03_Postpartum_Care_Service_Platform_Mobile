import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../utils/app_text_styles.dart';

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
  }) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 47.984,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.third,
          foregroundColor: AppColors.textOnPrimary,
          disabledForegroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: AppTextStyles.arimo(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: AppColors.textOnPrimary,
          ),
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
      height: height ?? 50.398,
      child: OutlinedButton(
        onPressed: isEnabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.googleButtonBackground,
          disabledBackgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.third,
          side: BorderSide(
            color: AppColors.googleButtonBorder,
            width: 1.207,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon,
              const SizedBox(width: 7.997),
            ],
            Text(
              text,
              style: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
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
  }) {
    return FormField<String>(
      validator: validator,
      builder: (fieldState) {
        final hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.arimo(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 7.997),

            // Field box: fixed height, full width of its parent.
            SizedBox(
              width: double.infinity,
              height: 39.986,
              child: TextFormField(
                controller: controller,
                obscureText: isPassword && obscureText,
                // Keep the same validator so Form.validate() triggers error state.
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

                  // Keep layout stable
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),

                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : AppColors.border,
                      width: 1.207,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : AppColors.border,
                      width: 1.207,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: hasError ? Colors.red : AppColors.border,
                      width: 1.207,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.207,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 1.207,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),

                  // Hide Flutter's built-in error text to prevent it affecting layout.
                  errorStyle: const TextStyle(height: 0, fontSize: 0),
                  errorMaxLines: 1,

                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 19.993,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: onTogglePassword,
                        )
                      : null,
                ),

                // Keep FormField<String> in sync with TextFormField changes.
                onChanged: (v) {
                  fieldState.didChange(v);
                },
              ),
            ),

            // Error message (outside the field box)
            if (hasError) ...[
              const SizedBox(height: 4),
              Text(
                fieldState.errorText ?? '',
                style: AppTextStyles.arimo(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.red,
                ),
              ),
            ],
          ],
        );
      },
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
}

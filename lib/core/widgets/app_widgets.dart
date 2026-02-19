import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../constants/app_assets.dart';
import '../utils/app_text_styles.dart';
import '../utils/app_responsive.dart';
import '../utils/app_formatters.dart';

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
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.arimo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textOnPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Primary Floating Action Button - icon only
  static Widget primaryFabIcon({
    required BuildContext context,
    IconData? icon,
    Widget? iconWidget,
    required VoidCallback onPressed,
    EdgeInsets? margin,
  }) {
    assert(icon != null || iconWidget != null,
        'Either icon or iconWidget must be provided');
    final scale = AppResponsive.scaleFactor(context);
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 12 * scale, right: 4 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 14 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: SizedBox(
        width: 56 * scale,
        height: 56 * scale,
        child: FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18 * scale),
          ),
          child: iconWidget ?? Icon(icon, size: 24 * scale),
        ),
      ),
    );
  }

  /// Primary Extended FAB - pill button with icon + label
  static Widget primaryFabExtended({
    required BuildContext context,
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    EdgeInsets? margin,
  }) {
    final scale = AppResponsive.scaleFactor(context);
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: 12 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 14 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: SizedBox(
        height: 44 * scale,
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: AppColors.primary,
          elevation: 0,
          icon: Icon(
            icon,
            color: AppColors.white,
            size: 20 * scale,
          ),
          label: Text(
            text,
            style: AppTextStyles.arimo(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
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
                      icon: SvgPicture.asset(
                        obscureText ? AppAssets.eyeDisable : AppAssets.eye,
                        width: 20,
                        height: 20,
                        colorFilter: ColorFilter.mode(
                          AppColors.textPrimary,
                          BlendMode.srcIn,
                        ),
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

  /// Week Calendar Picker - Reusable calendar widget showing week view
  /// Shows 7 days (Monday to Sunday) with navigation and date selection
  static Widget weekCalendarPicker({
    required BuildContext context,
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateSelected,
    required bool Function(DateTime date) hasData,
  }) {
    return _AppWeekCalendarPicker(
      selectedDate: selectedDate,
      onDateSelected: onDateSelected,
      hasData: hasData,
    );
  }
}

/// Internal stateful widget for week calendar picker
class _AppWeekCalendarPicker extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool Function(DateTime date) hasData;

  const _AppWeekCalendarPicker({
    required this.selectedDate,
    required this.onDateSelected,
    required this.hasData,
  });

  @override
  State<_AppWeekCalendarPicker> createState() => _AppWeekCalendarPickerState();
}

class _AppWeekCalendarPickerState extends State<_AppWeekCalendarPicker> {
  late DateTime _currentWeekStart; // Monday of current week
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _currentWeekStart = _getMondayOfWeek(widget.selectedDate);
  }

  @override
  void didUpdateWidget(_AppWeekCalendarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
      _currentWeekStart = _getMondayOfWeek(widget.selectedDate);
    }
  }

  /// Get Monday of the week containing the given date
  DateTime _getMondayOfWeek(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final daysFromMonday = (date.weekday - 1) % 7;
    return date.subtract(Duration(days: daysFromMonday));
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentWeekStart = _getMondayOfWeek(date);
    });
    widget.onDateSelected(date);
  }

  /// Get 7 days of the current week (Monday to Sunday)
  List<DateTime> _getDaysInWeek() {
    final days = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      days.add(_currentWeekStart.add(Duration(days: i)));
    }
    return days;
  }

  String _getWeekText() {
    final monday = _currentWeekStart;
    final sunday = _currentWeekStart.add(const Duration(days: 6));
    
    // If same month, show "day - day month"
    if (monday.month == sunday.month) {
      return '${monday.day} - ${sunday.day} ${AppFormatters.getMonthName(monday.month)}';
    } else {
      // Different months, show "day month - day month"
      return '${monday.day} ${AppFormatters.getMonthName(monday.month)} - ${sunday.day} ${AppFormatters.getMonthName(sunday.month)}';
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final days = _getDaysInWeek();
    final weekDays = AppFormatters.getWeekDayAbbreviations();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20 * scale),
      padding: EdgeInsets.all(20 * scale),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24 * scale),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20 * scale,
            offset: Offset(0, 6 * scale),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with week range and navigation arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _getWeekText(),
                  style: AppTextStyles.tinos(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 20 * scale,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _previousWeek,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24 * scale,
                      minHeight: 24 * scale,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 20 * scale,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _nextWeek,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(
                      minWidth: 24 * scale,
                      minHeight: 24 * scale,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16 * scale),

          // Calendar days with day labels - only 7 days (Monday to Sunday)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.asMap().entries.map((entry) {
              final index = entry.key;
              final date = entry.value;
              final dayLabel = weekDays[index];
              final isSelected = _isSameDay(date, _selectedDate);
              final hasData = widget.hasData(date);
              final isToday = _isToday(date);

              return GestureDetector(
                onTap: () => _selectDate(date),
                child: Container(
                  width: 44 * scale,
                  padding: EdgeInsets.only(
                    top: 8 * scale,
                    bottom: 8 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? Colors.grey.shade200
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Day label (T2, T3, etc.)
                      Text(
                        dayLabel,
                        style: AppTextStyles.arimo(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.normal,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      // Date number - fixed height container
                      SizedBox(
                        height: 20 * scale,
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: AppTextStyles.tinos(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.white
                                  : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      // Fixed space below date number
                      SizedBox(height: 6 * scale),
                      // Dot indicator - always reserve same space
                      SizedBox(
                        height: 4 * scale,
                        child: hasData && !isSelected
                            ? Container(
                                width: 4 * scale,
                                height: 4 * scale,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

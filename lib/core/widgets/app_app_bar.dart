import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';
import '../utils/app_text_styles.dart';

/// Standardized AppBar widget for consistent UI across the app
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final Color? backgroundColor;
  final Color? titleColor;
  final Widget? leading;
  final double? elevation;

  const AppAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.centerTitle = false,
    this.titleFontSize,
    this.titleFontWeight,
    this.backgroundColor,
    this.titleColor,
    this.leading,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppResponsive.scaleFactor(context);
    final fontSize = titleFontSize ?? (18 * scale);
    final fontWeight = titleFontWeight ?? FontWeight.w600;
    final bgColor = backgroundColor ?? AppColors.background;
    final textColor = titleColor ?? AppColors.textPrimary;

    Widget? leadingWidget;
    if (leading != null) {
      leadingWidget = leading;
    } else if (showBackButton) {
      leadingWidget = IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 24 * scale,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    return AppBar(
      backgroundColor: bgColor,
      elevation: elevation,
      surfaceTintColor: Colors.transparent,
      leading: leadingWidget,
      title: Text(
        title,
        style: AppTextStyles.arimo(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: textColor,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
